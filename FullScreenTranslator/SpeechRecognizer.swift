import AVFoundation
import Speech

@Observable final class SpeechRecognizer {
  var isRecognizing: Bool = false
  var isAuthorized: Bool = false

  enum Errors: Error {
    case notAuthorized
    case alreadyRecognizing
    case notRecognizing
  }

  private let recognizer: SFSpeechRecognizer = .init(locale: Locale.current)!
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
  }

  func stopRecognition() throws {
    guard isAuthorized else {
      throw Errors.notAuthorized
    }
    guard isRecognizing else {
      throw Errors.notRecognizing
    }
    isRecognizing = false
  }
}
