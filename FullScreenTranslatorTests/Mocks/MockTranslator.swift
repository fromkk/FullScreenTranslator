import Foundation
import Translation

@testable import FullScreenTranslator

@Observable class MockTranslator: TranslatorProtocol {
  var translated: String?
  var setSessionCalled = false
  var translateCalled = false
  var lastTranslatedText: String?
  var translationDelay: TimeInterval = 0

  func setSession(_ session: TranslationSession) {
    setSessionCalled = true
  }

  func translate(_ text: String) {
    translateCalled = true
    lastTranslatedText = text

    if translationDelay > 0 {
      Task {
        try? await Task.sleep(for: .seconds(translationDelay))
        await MainActor.run {
          translated = "translated: \(text)"
        }
      }
    } else {
      translated = "translated: \(text)"
    }
  }
}
