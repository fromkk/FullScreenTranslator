import Foundation
import Translation

@testable import FullScreenTranslator

class MockLanguageAvailabilityProvider: LanguageAvailabilityProviding {
  var supportedLanguagesReturnValue: [Locale.Language] = [
    Locale.Language(identifier: "en"),
    Locale.Language(identifier: "ja"),
    Locale.Language(identifier: "fr"),
    Locale.Language(identifier: "de"),
    Locale.Language(identifier: "es"),
  ]

  var statusReturnValue: AvailabilityStatus = .supported
  var lastSourceLanguage: Locale.Language?
  var lastTargetLanguage: Locale.Language?

  var supportedLanguages: [Locale.Language] {
    get async {
      supportedLanguagesReturnValue
    }
  }

  func status(from sourceLanguage: Locale.Language, to targetLanguage: Locale.Language) async
    -> AvailabilityStatus
  {
    lastSourceLanguage = sourceLanguage
    lastTargetLanguage = targetLanguage
    return statusReturnValue
  }
}
