import Foundation

protocol ConfigurationStore: AnyObject, Observable, Sendable {
  var storedLocale: Locale? { get throws }
  func store(locale: Locale) throws
  var storedTranslateLanguage: Locale.Language? { get throws }
  func store(translateLanguage: Locale.Language) throws
  var storedDuration: TimeInterval { get }
  func store(duration: TimeInterval)
}

@Observable final class ConfigurationStoreImpl: ConfigurationStore {
  private let baseLocaleKey = "baseLocale"
  private let translateLanguageKey = "translateLanguage"
  private let durationKey = "silent_duration"

  var storedLocale: Locale? {
    get throws {
      if let data = UserDefaults.standard.data(forKey: baseLocaleKey) {
        return try JSONDecoder().decode(Locale.self, from: data)
      } else {
        return Locale.current
      }
    }
  }

  func store(locale: Locale) throws {
    let localeData = try JSONEncoder().encode(
      Locale(identifier: locale.identifier))
    UserDefaults.standard.set(localeData, forKey: baseLocaleKey)
  }

  var storedTranslateLanguage: Locale.Language? {
    get throws {
      if let data = UserDefaults.standard.data(forKey: translateLanguageKey) {
        return try JSONDecoder().decode(Locale.Language.self, from: data)
      } else {
        return Locale.current.language
      }
    }
  }

  func store(translateLanguage: Locale.Language) throws {
    guard let translateLanguageCode = translateLanguage.languageCode?.identifier
    else { return }
    let translateLanguageData = try JSONEncoder().encode(
      Locale.Language(identifier: translateLanguageCode))
    UserDefaults.standard.set(
      translateLanguageData, forKey: translateLanguageKey)
  }

  var storedDuration: TimeInterval {
    UserDefaults.standard.double(forKey: durationKey)
  }

  func store(duration: TimeInterval) {
    UserDefaults.standard.set(duration, forKey: durationKey)
  }
}
