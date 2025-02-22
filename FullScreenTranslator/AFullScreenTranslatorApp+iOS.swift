#if canImport(UIKit)

import UIKit
import Speech
import SwiftUI
import Translation

struct SubtitlesView: View {
  var text: String
  var translated: String?

  var body: some View {
    VStack {
      VStack(spacing: 8) {
        Text(text)
          .font(.system(size: 24, weight: .bold))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, alignment: .center)
          .multilineTextAlignment(.center)

        if let translated {
          Text(translated)
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
        }
      }
        .background(Color.black.opacity(0.6))
    }
  }
}

struct ContentView: View {
  var text: String?
  var translated: String?

  var body: some View {
    if let text {
      SubtitlesView(text: text, translated: translated)
    }
  }
}

@main
struct FullScreenTranslatorApp: App {
  @State var error: (any Error)?
  @State var speechRecognizer: SpeechRecognizer = .init()
  @State var locale: Locale = .current
  @State var translateLanguage: Locale.Language = .init(identifier: "en")
  @State var supportedLanguages: [Locale.Language] = []
  @State var translator: Translator = .init()
  @State var configuration: TranslationSession.Configuration?
  private let languageAvailability = LanguageAvailability()
  @State var notSupported: Bool = false

  init() {
    if let data = UserDefaults.standard.data(forKey: baseLocaleKey) {
      do {
        locale = try JSONDecoder().decode(Locale.self, from: data)
      } catch {
        print("\(Self.self) error \(error.localizedDescription)")
      }
    }

    if let data = UserDefaults.standard.data(forKey: translateLanguageKey) {
      do {
        translateLanguage = try JSONDecoder().decode(Locale.Language.self, from: data)
      } catch {
        print("\(Self.self)error \(error.localizedDescription)")
      }
    }

    speechRecognizer = SpeechRecognizer(locale: locale)
    speechRecognizer.requestAuthorization()
  }

  var body: some Scene {
    WindowGroup {
      ScrollView {
        VStack(spacing: 32) {
          ContentView(text: speechRecognizer.text, translated: translator.translated)
            .frame(maxWidth: .infinity)

          VStack(spacing: 8) {
            if speechRecognizer.isAuthorized {
              if speechRecognizer.isRecognizing {
                Button {
                  do {
                    try speechRecognizer.stopRecognition()
                    speechRecognizer.text = nil
                  } catch {
                    self.error = error
                  }
                } label: {
                  HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("Stop")
                  }
                }
              } else {
                Button {
                  do {
                    try speechRecognizer.startRecognition()
                  } catch {
                    self.error = error
                  }
                } label: {
                  HStack {
                    Image(systemName: "play.fill")
                    Text("Start")
                  }
                }
              }
            } else {
              Text("Please allow permission")
            }

            Picker(
              "Base locale", selection: $locale,
              content: {
                ForEach(Array(SFSpeechRecognizer.supportedLocales()), id: \.self) { currentLocale in
                  Text(currentLocale.identifier).tag(currentLocale.identifier)
                }
              }
            )

            Picker(
              "Translate language", selection: $translateLanguage,
              content: {
                ForEach(supportedLanguages, id: \.self) { language in
                  Text(language.languageCode?.identifier ?? "unknown").tag(language.languageCode?.identifier ?? "unknown")
                }
              }
            )
          }
        }
      }
      .task {
        let availability = LanguageAvailability()
        supportedLanguages = await availability.supportedLanguages.sorted(using: KeyPathComparator(\.languageCode?.identifier))
        updateTranslateConfiguration()
      }
      .onChange(of: locale) { oldValue, newValue in
        speechRecognizer = SpeechRecognizer(locale: newValue)
        speechRecognizer.requestAuthorization()
        save()
        updateTranslateConfiguration()
      }
      .onChange(of: translateLanguage) { oldValue, newValue in
        save()
        updateTranslateConfiguration()
      }
      .onChange(of: speechRecognizer.text) { oldValue, newValue in
        guard let text = newValue, !text.isEmpty else { return }
        translator.translate(text)
      }
      .translationTask(configuration) { session in
        Task {
          do {
            try await session.prepareTranslation()
            translator.setSession(session)
          } catch {
            print("translationTask.error \(error.localizedDescription)")
          }
        }
      }
      .alert("Not supported language", isPresented: $notSupported, actions: {})
    }
  }

  private func updateTranslateConfiguration() {
    Task {
      let status = await languageAvailability.status(from: locale.language, to: translateLanguage)
      print("\(Self.self).updateTranslateConfiguration status: \(status)")
      switch status {
      case .installed, .supported:
        configuration?.invalidate()
        configuration = .init(source: locale.language, target: translateLanguage)
      case .unsupported:
        notSupported = true
      @unknown default:
        return
      }
    }
  }

  private let baseLocaleKey = "baseLocale"
  private let translateLanguageKey = "translateLanguage"

  private func save() {
    do {
      let localeData = try JSONEncoder().encode(locale)
      UserDefaults.standard.set(localeData, forKey: baseLocaleKey)

      let translateLanguageData = try JSONEncoder().encode(translateLanguage)
      UserDefaults.standard.set(translateLanguageData, forKey: translateLanguageKey)
    } catch {
      print("\(Self.self) error \(error.localizedDescription)")
    }
  }
}

#endif
