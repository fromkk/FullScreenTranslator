import SwiftUI

/// 共通のコントロールボタンを表示するビュー
struct TranslatorControlButtons: View {
  @Bindable var viewModel: TranslatorViewModel

  var body: some View {
    if viewModel.speechRecognizer.isRecognizing {
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
  }
}
