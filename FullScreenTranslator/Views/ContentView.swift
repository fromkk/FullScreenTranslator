import SwiftUI

#if canImport(UIKit)
  struct ContentView: View {
    // true の場合には `SubtitlesView` が180度回転する
    @State private var isRotating: Bool = false

    var text: String?
    var translated: String?

    var body: some View {
      HStack(spacing: 16) {
        SubtitlesView(text: text ?? "", translated: translated)
          .rotationEffect(.degrees(isRotating ? 180 : 0))
          .animation(.easeInOut(duration: 0.5))

        Button {
          isRotating.toggle()
        } label: {
          Image(systemName: "arrow.trianglehead.clockwise.rotate.90")
        }
        .accessibilityLabel("Rotate")
      }
    }
  }
#elseif canImport(AppKit)
  struct ContentView: View {
    var text: String?
    var translated: String?

    var body: some View {
      ZStack {
        if let text {
          SubtitlesView(text: text, translated: translated)
        }
        WindowAccessor(text: text) { window in
          if let window = window {
            window.isOpaque = false
            window.backgroundColor = .clear
            window.styleMask = [.borderless]
            window.level = .screenSaver
            window.ignoresMouseEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            if let screenFrame = NSScreen.main?.frame {
              window.setFrame(screenFrame, display: true)
            }
          }
        }
      }
      .ignoresSafeArea()
    }
  }
#endif
