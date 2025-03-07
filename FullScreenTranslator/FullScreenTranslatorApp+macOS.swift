#if canImport(AppKit)
  import AppKit
  import Speech
  import SwiftUI
  import Translation

  // NSWindowへアクセスするためのNSViewRepresentable
  struct WindowAccessor: NSViewRepresentable {
    var text: String?
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
      let view = NSView()
      // 次のRunLoopでwindowプロパティにアクセス
      DispatchQueue.main.async {
        self.callback(view.window)
      }
      return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      guard let window = nsView.window else { return }
      if text?.isEmpty ?? true {
        window.orderOut(nil)
      } else {
        window.orderFront(nil)
      }
    }
  }

  @main
  struct FullScreenTranslatorApp: App {
    @State var alertMessage: AlertMessage?
    @State var speechRecognizer: SpeechRecognizer = .init()
    @State var localeIdentifier: String
    @State var translateLanguageCode: String
    @State var supportedLanguageCodes: [String] = []
    @State var translator: Translator = .init()
    @State var configuration: TranslationSession.Configuration?
    private let languageAvailability = LanguageAvailability()
    @State var isSupported: Bool = false
    @State var notSupportedAlertPresented: Bool = false

    private let configurationStore = ConfigurationStoreImpl()

    init() {
      do {
        localeIdentifier =
          try configurationStore.storedLocale?.identifier ?? Locale.current.identifier
      } catch {
        localeIdentifier = Locale.current.identifier
        self.alertMessage = .init(message: error.localizedDescription)
      }

      do {
        translateLanguageCode =
          try configurationStore.storedTranslateLanguage?.languageCode?.identifier ?? "en"
      } catch {
        translateLanguageCode = "en"
        self.alertMessage = .init(message: error.localizedDescription)
      }

      let duration = configurationStore.storedDuration
      if duration > 0 {
        speechRecognizer.resetDuration = TimeInterval(duration)
      } else {
        speechRecognizer.resetDuration = 2.0  // Default value
      }

      speechRecognizer = SpeechRecognizer(locale: Locale(identifier: localeIdentifier))
      speechRecognizer.requestAuthorization()
    }

    var body: some Scene {
      WindowGroup {
        ContentView(text: speechRecognizer.text, translated: translator.translated)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
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
          .alert("Not supported language", isPresented: $notSupportedAlertPresented, actions: {})
          .alert(
            item: $alertMessage,
            content: { alertMessage in
              Alert(title: Text(alertMessage.message))
            })
      }
      .windowStyle(HiddenTitleBarWindowStyle())

      MenuBarExtra(
        content: {
          if speechRecognizer.isAuthorized {
            if !isSupported {
              Text("Not supported language")
            } else if speechRecognizer.isRecognizing {
              Button {
                do {
                  try speechRecognizer.stopRecognition()
                  speechRecognizer.text = nil
                } catch {
                  self.alertMessage = .init(message: error.localizedDescription)
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
                  self.alertMessage = .init(message: error.localizedDescription)
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

          ConfigurationView(
            supportedLanguageCodes: supportedLanguageCodes,
            localeIdentifier: $localeIdentifier,
            translateLanguageCode: $translateLanguageCode,
            resetDuration: $speechRecognizer.resetDuration
          )

          Button {
            exit(1)
          } label: {
            Text("Quit")
          }
        },
        label: {
          HStack {
            if !speechRecognizer.isAuthorized {
              Image(systemName: "microphone.badge.xmark.fill")
            } else if speechRecognizer.isRecognizing {
              Image(systemName: "progress.indicator")
            } else {
              Image(systemName: "translate")
            }
          }
          .task {
            let availability = LanguageAvailability()
            supportedLanguageCodes = Set(
              await availability.supportedLanguages.compactMap { $0.languageCode?.identifier }
            )
            .sorted(using: KeyPathComparator(\.self))
            updateTranslateConfiguration()
          }
          .onChange(of: localeIdentifier) { oldValue, newValue in
            speechRecognizer = SpeechRecognizer(locale: Locale(identifier: newValue))
            speechRecognizer.requestAuthorization()
            save()
            updateTranslateConfiguration()
          }
          .onChange(of: translateLanguageCode) { oldValue, newValue in
            save()
            updateTranslateConfiguration()
          }
          .onChange(of: speechRecognizer.text) { oldValue, newValue in
            guard let text = newValue, !text.isEmpty else { return }
            translator.translate(text)
          }
        }
      )
    }

    private func updateTranslateConfiguration() {
      Task {
        let locale = Locale(identifier: localeIdentifier)
        let translateLanguage = Locale.Language(identifier: translateLanguageCode)
        let status = await languageAvailability.status(from: locale.language, to: translateLanguage)
        print("\(Self.self).updateTranslateConfiguration status: \(status)")
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

    private func save() {
      do {
        try configurationStore.store(locale: Locale(identifier: localeIdentifier))
        try configurationStore.store(
          translateLanguage: Locale.Language(identifier: translateLanguageCode))
      } catch {
        print("\(Self.self) error \(error.localizedDescription)")
      }
      configurationStore.store(duration: speechRecognizer.resetDuration)
    }
  }
#endif
