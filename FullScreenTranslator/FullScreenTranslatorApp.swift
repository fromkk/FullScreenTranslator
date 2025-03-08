import Speech
import SwiftUI
import Translation

@main
struct FullScreenTranslatorApp: App {
  @State private var viewModel = TranslatorViewModel()

  var body: some Scene {
    #if canImport(UIKit)
      // iOS implementation
      WindowGroup {
        NavigationStack {
          ScrollView {
            VStack(spacing: 32) {
              ContentView(
                text: viewModel.speechRecognizer.text,
                translated: viewModel.translator.translated
              )
              .frame(maxWidth: .infinity)

              if viewModel.speechRecognizer.isAuthorized {
                if !viewModel.isSupported {
                  Text("Not supported language")
                } else if viewModel.speechRecognizer.isRecognizing {
                  Button {
                    viewModel.stopRecognition()
                  } label: {
                    HStack {
                      Image(systemName: "stop.circle.fill")
                      Text("Stop")
                    }
                  }
                } else {
                  Button {
                    viewModel.startRecognition()
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
        .task {
          await viewModel.loadSupportedLanguages()
        }
        .onChange(of: viewModel.localeIdentifier) { oldValue, newValue in
          viewModel.updateLocale(newValue)
        }
        .onChange(of: viewModel.translateLanguageCode) { oldValue, newValue in
          viewModel.save()
          viewModel.updateTranslateConfiguration()
        }
        .onChange(of: viewModel.speechRecognizer.resetDuration) { oldValue, newValue in
          viewModel.save()
        }
        .onChange(of: viewModel.speechRecognizer.text) { oldValue, newValue in
          viewModel.translateText(newValue)
        }
        .translationTask(viewModel.configuration) { session in
          Task {
            await viewModel.prepareTranslation(session: session)
          }
        }
        .alert(
          "Not supported language",
          isPresented: $viewModel.notSupportedAlertPresented,
          actions: {}
        )
        .alert(
          item: $viewModel.alertMessage,
          content: { alertMessage in
            Alert(title: Text(alertMessage.message))
          }
        )
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
    #elseif canImport(AppKit)
      // macOS implementation
      WindowGroup {
        ContentView(
          text: viewModel.speechRecognizer.text,
          translated: viewModel.translator.translated
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .translationTask(viewModel.configuration) { session in
          Task {
            await viewModel.prepareTranslation(session: session)
          }
        }
        .alert(
          "Not supported language",
          isPresented: $viewModel.notSupportedAlertPresented,
          actions: {}
        )
        .alert(
          item: $viewModel.alertMessage,
          content: { alertMessage in
            Alert(title: Text(alertMessage.message))
          }
        )
      }
      .windowStyle(HiddenTitleBarWindowStyle())

      MenuBarExtra(
        content: {
          if viewModel.speechRecognizer.isAuthorized {
            if !viewModel.isSupported {
              Text("Not supported language")
            } else if viewModel.speechRecognizer.isRecognizing {
              Button {
                viewModel.stopRecognition()
              } label: {
                HStack {
                  Image(systemName: "stop.circle.fill")
                  Text("Stop")
                }
              }
            } else {
              Button {
                viewModel.startRecognition()
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
          .task {
            await viewModel.loadSupportedLanguages()
          }
          .onChange(of: viewModel.localeIdentifier) { oldValue, newValue in
            viewModel.updateLocale(newValue)
          }
          .onChange(of: viewModel.translateLanguageCode) { oldValue, newValue in
            viewModel.save()
            viewModel.updateTranslateConfiguration()
          }
          .onChange(of: viewModel.speechRecognizer.resetDuration) { oldValue, newValue in
            viewModel.save()
          }
          .onChange(of: viewModel.speechRecognizer.text) { oldValue, newValue in
            viewModel.translateText(newValue)
          }
        }
      )
    #endif
  }
}
