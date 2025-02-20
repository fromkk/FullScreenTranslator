import AVFoundation
import Speech

@Observable final class SpeechRecognizer {
  var isRecognizing: Bool = false
  var isAuthorized: Bool = false
  var text: String?

  enum Errors: Error {
    case notAuthorized
    case alreadyRecognizing
    case notRecognizing
  }

  private let recognizer: SFSpeechRecognizer = .init(locale: Locale(identifier: "ja_JP"))!
  private let audioEngine = AVAudioEngine()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?

  private let resetDuration: TimeInterval = 2.0
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
    recognitionRequest.shouldReportPartialResults = true

    // 認識タスクを開始し、結果を受け取る
    recognitionTask = recognizer.recognitionTask(with: recognitionRequest) {
      [weak self] result, error in
      guard let self = self else { return }
      if let result = result {
        // 認識したテキストを text プロパティに反映
        self.text = result.bestTranscription.formattedString
        print(self.text ?? "no text")
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

    // オーディオ入力のタップを設定してバッファをリクエストに渡す
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
            print("error \(error.localizedDescription)")
          }
        }
      })
  }
}
