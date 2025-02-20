import SwiftUI

@main
struct FullScreenTranslatorApp: App {
  @State var error: (any Error)?
  @State var speechRecognizer = SpeechRecognizer()

  var body: some Scene {
    MenuBarExtra(
      content: {
        if speechRecognizer.isAuthorized {
          if speechRecognizer.isRecognizing {
            Button {
              do {
                try speechRecognizer.stopRecognition()
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
          speechRecognizer.requestAuthorization()
        }
      })
  }
}
