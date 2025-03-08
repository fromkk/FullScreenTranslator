import SwiftUI
import Translation

/// TranslatorViewModelに関連する共通のViewModifierを定義
struct TranslatorViewModifiers: ViewModifier {
  @Bindable var viewModel: TranslatorViewModel

  func body(content: Content) -> some View {
    content
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
        content: { (alertMessage: AlertMessage) in
          Alert(title: Text(alertMessage.message))
        }
      )
  }
}

extension View {
  func translatorViewModifiers(viewModel: TranslatorViewModel) -> some View {
    modifier(TranslatorViewModifiers(viewModel: viewModel))
  }
}

/// 共通のコントロールボタンを表示するビュー
struct TranslatorControlButtons: View {
  @Bindable var viewModel: TranslatorViewModel

  var body: some View {
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
  }
}
