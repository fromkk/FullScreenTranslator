import Foundation
import Speech
import SwiftUI
import Translation

@Observable final class TranslatorViewModel {
  // MARK: - Properties
  var alertMessage: AlertMessage?
  var speechRecognizer: SpeechRecognizer
  var localeIdentifier: String
  var translateLanguageCode: String
  var supportedLanguageCodes: [String] = []
  var translator: Translator = .init()
  var configuration: TranslationSession.Configuration?
  private let languageAvailability = LanguageAvailability()
  var isSupported: Bool = false
  var notSupportedAlertPresented: Bool = false

  // iOS specific state
  var isPresentedSettings: Bool = false

  private let configurationStore: ConfigurationStore

  // MARK: - Initialization
  init(configurationStore: ConfigurationStore = ConfigurationStoreImpl()) {
    self.configurationStore = configurationStore

    // 先に localeIdentifier を初期化
    let initialLocaleIdentifier: String
    do {
      initialLocaleIdentifier =
        try configurationStore.storedLocale?.identifier ?? Locale.current.identifier
    } catch {
      initialLocaleIdentifier = Locale.current.identifier
      self.alertMessage = .init(message: error.localizedDescription)
    }
    self.localeIdentifier = initialLocaleIdentifier

    // 次に translateLanguageCode を初期化
    do {
      translateLanguageCode =
        try configurationStore.storedTranslateLanguage?.languageCode?.identifier ?? "en"
    } catch {
      translateLanguageCode = "en"
      self.alertMessage = .init(message: error.localizedDescription)
    }

    // SpeechRecognizer の初期化に localeIdentifier を使用
    speechRecognizer = SpeechRecognizer(locale: Locale(identifier: initialLocaleIdentifier))

    // 保存されたresetDurationを取得して設定
    let duration = configurationStore.storedDuration
    speechRecognizer.resetDuration = duration > 0 ? duration : 2.0
    speechRecognizer.requestAuthorization()
  }

  // MARK: - Functions
  func startRecognition() {
    do {
      try speechRecognizer.startRecognition()
    } catch {
      self.alertMessage = .init(message: error.localizedDescription)
    }
  }

  func stopRecognition() {
    do {
      try speechRecognizer.stopRecognition()
      speechRecognizer.text = nil
    } catch {
      self.alertMessage = .init(message: error.localizedDescription)
    }
  }

  func loadSupportedLanguages() async {
    let availability = LanguageAvailability()
    let supportedCodes = Set(
      await availability.supportedLanguages.compactMap { $0.languageCode?.identifier }
    )
    .sorted(using: KeyPathComparator(\.self))

    // UI更新に関わるプロパティをメインスレッドで更新
    await MainActor.run {
      supportedLanguageCodes = supportedCodes
    }

    // 設定の更新はメインスレッドでの処理を含む
    updateTranslateConfiguration()
  }

  func updateTranslateConfiguration() {
    Task {
      let locale = Locale(identifier: localeIdentifier)
      let translateLanguage = Locale.Language(identifier: translateLanguageCode)
      let status = await languageAvailability.status(from: locale.language, to: translateLanguage)
      print("\(Self.self).updateTranslateConfiguration status: \(status)")

      // UI更新に関連する処理はメインスレッドで実行
      await MainActor.run {
        switch status {
        case .installed, .supported:
          configuration?.invalidate()
          configuration = .init(source: locale.language, target: translateLanguage)
          isSupported = true
        case .unsupported:
          notSupportedAlertPresented = true
          isSupported = false
        @unknown default:
          return
        }
      }
    }
  }

  func save() {
    do {
      try configurationStore.store(locale: Locale(identifier: localeIdentifier))
      try configurationStore.store(
        translateLanguage: Locale.Language(identifier: translateLanguageCode))
    } catch {
      print("\(Self.self) error \(error.localizedDescription)")
    }
    configurationStore.store(duration: speechRecognizer.resetDuration)
  }

  func updateLocale(_ newValue: String) {
    // 現在の resetDuration を保持
    let currentResetDuration = speechRecognizer.resetDuration

    // 新しい SpeechRecognizer を作成
    speechRecognizer = SpeechRecognizer(locale: Locale(identifier: newValue))

    // 以前の resetDuration を設定
    speechRecognizer.resetDuration = currentResetDuration

    speechRecognizer.requestAuthorization()
    save()
    updateTranslateConfiguration()
  }

  func translateText(_ text: String?) {
    guard let text = text, !text.isEmpty else { return }
    translator.translate(text)
  }

  func prepareTranslation(session: TranslationSession) async {
    do {
      try await session.prepareTranslation()
      // UI更新に関わる可能性があるため、メインスレッドで実行
      await MainActor.run {
        translator.setSession(session)
      }
    } catch {
      print("translationTask.error \(error.localizedDescription)")
    }
  }

  // Settings visibility control (for iOS)
  func showSettings() {
    isPresentedSettings = true
  }

  func hideSettings() {
    isPresentedSettings = false
  }
}
