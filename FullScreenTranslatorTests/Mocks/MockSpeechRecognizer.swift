import Foundation
import Speech

@testable import FullScreenTranslator

@Observable class MockSpeechRecognizer: SpeechRecognizerProtocol {
  var isRecognizing: Bool = false
  var isAuthorized: Bool = true
  var text: String?
  var resetDuration: TimeInterval = 2.0

  var requestAuthorizationCalled = false
  var startRecognitionCalled = false
  var stopRecognitionCalled = false
  var shouldThrowError = false

  func requestAuthorization() {
    requestAuthorizationCalled = true
  }

  func startRecognition() throws {
    if shouldThrowError {
      throw MockError.error
    }
    startRecognitionCalled = true
    isRecognizing = true
  }

  func stopRecognition() throws {
    if shouldThrowError {
      throw MockError.error
    }
    stopRecognitionCalled = true
    isRecognizing = false
  }

  enum MockError: Error {
    case error
  }
}
