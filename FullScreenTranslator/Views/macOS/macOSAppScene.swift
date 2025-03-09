import SwiftUI

#if canImport(AppKit)
  import Translation
  /// macOS向けのアプリ画面実装
  struct macOSAppScene: Scene {
    @Bindable var viewModel: TranslatorViewModel

    var body: some Scene {
      WindowGroup {
        ContentView(
          text: viewModel.speechRecognizer.text,
          translated: viewModel.translator.translated
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .translatorViewModifiers(viewModel: viewModel)
      }
      .windowStyle(HiddenTitleBarWindowStyle())

      MenuBarExtra(
        content: {
          TranslatorControlButtons(viewModel: viewModel)

          ConfigurationView(
            supportedLanguageCodes: viewModel.supportedLanguageCodes,
            localeIdentifier: $viewModel.localeIdentifier,
            translateLanguageCode: $viewModel.translateLanguageCode,
            resetDuration: $viewModel.speechRecognizer.resetDuration
          )

          Button {
            exit(1)
          } label: {
            Text("Quit")
          }
        },
        label: {
          HStack {
            if !viewModel.speechRecognizer.isAuthorized {
              Image(systemName: "microphone.badge.xmark.fill")
            } else if viewModel.speechRecognizer.isRecognizing {
              Image(systemName: "progress.indicator")
            } else {
              Image(systemName: "translate")
            }
          }
        }
      )
    }
  }
#endif
