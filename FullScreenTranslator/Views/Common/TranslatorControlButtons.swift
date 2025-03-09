import SwiftUI


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