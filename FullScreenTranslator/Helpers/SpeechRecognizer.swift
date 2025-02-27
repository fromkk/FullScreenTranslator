import AVFoundation
import Speech

@Observable final class SpeechRecognizer {
  init(locale: Locale = .current) {
    self.recognizer = SFSpeechRecognizer(locale: locale)!
  }

  var isRecognizing: Bool = false
  var isAuthorized: Bool = false
  var text: String?

  enum Errors: Error {
    case notAuthorized
    case alreadyRecognizing
    case notRecognizing
  }

  private var recognizer: SFSpeechRecognizer
  private let audioEngine = AVAudioEngine()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?

  var resetDuration: TimeInterval = 2.0
  private var resetTimer: Timer?

  func requestAuthorization() {
    SFSpeechRecognizer.requestAuthorization { [weak self] status in
      self?.isAuthorized = status == .authorized
    }
  }

  func startRecognition() throws {
    guard isAuthorized else {
      throw Errors.notAuthorized
    }
    guard !isRecognizing else {
      throw Errors.alreadyRecognizing
    }

    isRecognizing = true

    // 既存の認識タスクがあればキャンセルする
    recognitionTask?.cancel()
    recognitionTask = nil

    // 入力ノードを取得
    let node = audioEngine.inputNode

    // 認識リクエストを生成
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    guard let recognitionRequest = recognitionRequest else {
      return
    }
    if recognizer.supportsOnDeviceRecognition {
      recognitionRequest.requiresOnDeviceRecognition = true
    }
    recognitionRequest.shouldReportPartialResults = true

    recognitionTask = recognizer.recognitionTask(with: recognitionRequest) {
      [weak self] result, error in
      guard let self = self else { return }
      if let result = result {
        self.text = result.bestTranscription.formattedString
        print("recognized: \(self.text ?? "no text")")
        self.resetTimerStart()
      }
      if error != nil || (result?.isFinal ?? false) {
        self.audioEngine.stop()
        node.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.isRecognizing = false
      }
    }

    let recordingFormat = node.outputFormat(forBus: 0)
    node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      self.recognitionRequest?.append(buffer)
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  func stopRecognition() throws {
    guard isAuthorized else {
      throw Errors.notAuthorized
    }
    guard isRecognizing else {
      throw Errors.notRecognizing
    }
    audioEngine.stop()
    recognitionRequest?.endAudio()
    isRecognizing = false
  }

  private func resetTimerStart() {
    resetTimer?.invalidate()
    resetTimer = Timer.scheduledTimer(
      withTimeInterval: resetDuration, repeats: false,
      block: { [weak self] timer in
        guard let self else { return }
        Task {
          do {
            try self.stopRecognition()
            try await Task.sleep(for: .seconds(0.1))
            try self.startRecognition()
          } catch {
            print("\(Self.self) error \(error.localizedDescription)")
          }
        }
      })
  }
}
