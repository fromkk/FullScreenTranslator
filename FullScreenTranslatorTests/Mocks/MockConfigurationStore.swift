import Foundation

@testable import FullScreenTranslator

@Observable class MockConfigurationStore: ConfigurationStore {
  var storedLocaleReturnValue: Locale? = .current
  var storedLocaleThrowsError = false
  var storedTranslateLanguageReturnValue: Locale.Language? = Locale.current.language
  var storedTranslateLanguageThrowsError = false
  var storedDurationReturnValue: TimeInterval = 2.0

  var storeLocaleCalled = false
  var storeTranslateLanguageCalled = false
  var storeDurationCalled = false

  var lastStoredLocale: Locale?
  var lastStoredTranslateLanguage: Locale.Language?
  var lastStoredDuration: TimeInterval?

  enum MockError: Error {
    case error
  }

  var storedLocale: Locale? {
    get throws {
      if storedLocaleThrowsError {
        throw MockError.error
      }
      return storedLocaleReturnValue
    }
  }

  func store(locale: Locale) throws {
    storeLocaleCalled = true
    lastStoredLocale = locale
    if storedLocaleThrowsError {
      throw MockError.error
    }
  }

  var storedTranslateLanguage: Locale.Language? {
    get throws {
      if storedTranslateLanguageThrowsError {
        throw MockError.error
      }
      return storedTranslateLanguageReturnValue
    }
  }

  func store(translateLanguage: Locale.Language) throws {
    storeTranslateLanguageCalled = true
    lastStoredTranslateLanguage = translateLanguage
    if storedTranslateLanguageThrowsError {
      throw MockError.error
    }
  }

  var storedDuration: TimeInterval {
    storedDurationReturnValue
  }

  func store(duration: TimeInterval) {
    storeDurationCalled = true
    lastStoredDuration = duration
  }
}
