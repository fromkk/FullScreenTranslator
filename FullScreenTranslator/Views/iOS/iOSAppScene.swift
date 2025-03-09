import SwiftUI

#if canImport(UIKit)
  import Translation
  /// iOS向けのアプリ画面実装
  struct iOSAppScene: Scene {
    @Bindable var viewModel: TranslatorViewModel

    var body: some Scene {
      WindowGroup {
        NavigationStack {
          ScrollView {
            VStack(spacing: 32) {
              if !viewModel.speechRecognizer.isAuthorized {
                WarningMessage(systemName: "mic.slash.fill", text: "Microphone access required")
              } else if !viewModel.isSupported {
                WarningMessage(
                  systemName: "exclamationmark.triangle.fill",
                  text: "Unsupported language combination")
              }

              ContentView(
                text: viewModel.speechRecognizer.text,
                translated: viewModel.translator.translated
              )
              .frame(maxWidth: .infinity)

              if viewModel.speechRecognizer.isAuthorized, viewModel.isSupported {
                TranslatorControlButtons(viewModel: viewModel)
              }

              Spacer()
            }
            .padding(16)
          }
          .navigationTitle(Text("FullScreenTranslator"))
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              Button {
                viewModel.showSettings()
              } label: {
                Image(systemName: "gear")
              }
              .accessibilityLabel("Settings")
            }
          }
        }
        .translatorViewModifiers(viewModel: viewModel)
        .sheet(isPresented: $viewModel.isPresentedSettings) {
          NavigationStack {
            ScrollView {
              ConfigurationView(
                supportedLanguageCodes: viewModel.supportedLanguageCodes,
                localeIdentifier: $viewModel.localeIdentifier,
                translateLanguageCode: $viewModel.translateLanguageCode,
                resetDuration: $viewModel.speechRecognizer.resetDuration
              )
            }
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
          }
        }
      }
    }
  }
#endif
