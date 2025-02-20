import SwiftUI

@main
struct FullScreenTranslatorApp: App {
  @State var isAuthorized: Bool = false
  @State var isTranslating: Bool = false

  private let audioRecorder = AudioRecorder()

  var body: some Scene {
    MenuBarExtra(
      content: {
        if isAuthorized {
          if isTranslating {
            Button {
              isTranslating = false
            } label: {
              HStack {
                Image(systemName: "stop.circle.fill")
                Text("Stop")
              }
            }
          } else {
            Button {
              isTranslating = true
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
          if !isAuthorized {
            Image(systemName: "microphone.badge.xmark.fill")
          } else if isTranslating {
            Image(systemName: "progress.indicator")
          } else {
            Image(systemName: "translate")
          }
        }
        .task {
          isAuthorized = await audioRecorder.requestAuthorization()
        }
      })
  }
}
