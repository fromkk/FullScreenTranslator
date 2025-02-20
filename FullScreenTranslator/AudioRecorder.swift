import AVFoundation
import Speech

final actor AudioRecorder {
  private let recognizer: SFSpeechRecognizer = .init(locale: Locale.current)!
  func requestAuthorization() async -> Bool {
    await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status == .authorized)
      }
    }
  }
}
