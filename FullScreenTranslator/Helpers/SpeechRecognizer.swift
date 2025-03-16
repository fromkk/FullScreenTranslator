import AVFoundation
import Speech

protocol SpeechRecognizerProtocol: Observable {
  var isRecognizing: Bool { get }
  var isAuthorized: Bool { get }
  var text: String? { get set }
  var resetDuration: TimeInterval { get set }

  func requestAuthorization()
  func startRecognition() throws
  func stopRecognition() throws
}

@Observable final class SpeechRecognizer: SpeechRecognizerProtocol {
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
      // メインスレッドでObservableプロパティを更新
      DispatchQueue.main.async {
        self?.isAuthorized = status == .authorized
      }
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

      // UIに影響を与えるプロパティ更新はメインスレッドで実行
      DispatchQueue.main.async {
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
    audioEngine.inputNode.removeTap(onBus: 0)
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
            // メインスレッドで実行する必要があるメソッドを安全に呼び出す
            await MainActor.run {
              do {
                try self.stopRecognition()
              } catch {
                print("\(Self.self) stopRecognition error \(error.localizedDescription)")
              }
            }

            try await Task.sleep(for: .seconds(0.1))

            await MainActor.run {
              do {
                try self.startRecognition()
              } catch {
                print("\(Self.self) startRecognition error \(error.localizedDescription)")
              }
            }
          } catch {
            print("\(Self.self) error \(error.localizedDescription)")
          }
        }
      })
  }
}
