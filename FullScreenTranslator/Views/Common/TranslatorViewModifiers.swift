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
        "Unsupported Language",
        isPresented: $viewModel.notSupportedAlertPresented,
        actions: {},
        message: {
          Text(
            "The selected language combination is not supported for translation. Please choose different languages in settings."
          )
        }
      )
      .alert(
        item: $viewModel.alertMessage,
        content: { (alertMessage: AlertMessage) in
          Alert(
            title: Text("Warning"),
            message: Text(alertMessage.message),
            dismissButton: .default(Text("OK"))
          )
        }
      )
  }
}

extension View {
  func translatorViewModifiers(viewModel: TranslatorViewModel) -> some View {
    modifier(TranslatorViewModifiers(viewModel: viewModel))
  }
}
