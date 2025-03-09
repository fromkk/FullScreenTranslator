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

/// 共通のコントロールボタンを表示するビュー
struct TranslatorControlButtons: View {
  @Bindable var viewModel: TranslatorViewModel

  var body: some View {
    if viewModel.speechRecognizer.isAuthorized {
      if !viewModel.isSupported {
        warningMessage(
          text: "Unsupported language combination", systemName: "exclamationmark.triangle.fill")
      } else if viewModel.speechRecognizer.isRecognizing {
        Button {
          viewModel.stopRecognition()
        } label: {
          HStack {
            Image(systemName: "stop.circle.fill")
              .font(.title2)
            Text("Stop")
              .font(.headline)
          }
          .frame(minWidth: 150, minHeight: 50)
          .foregroundColor(.white)
          .background(Color.red)
          .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .buttonStyle(ScaleButtonStyle())
      } else {
        Button {
          viewModel.startRecognition()
        } label: {
          HStack {
            Image(systemName: "play.fill")
              .font(.title2)
            Text("Start")
              .font(.headline)
          }
          .frame(minWidth: 150, minHeight: 50)
          .foregroundColor(.white)
          .background(Color.blue)
          .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .buttonStyle(ScaleButtonStyle())
      }
    } else {
      warningMessage(text: "Microphone access required", systemName: "mic.slash.fill")
    }
  }

  @ViewBuilder
  private func warningMessage(text: LocalizedStringKey, systemName: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: systemName)
        .font(.headline)
        .foregroundColor(.red)
      Text(text)
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.red.opacity(0.1))
    .foregroundColor(.primary)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.red.opacity(0.3), lineWidth: 1)
    )
  }
}

/// ボタンがタップされたときにアニメーションするボタンスタイル
struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}
