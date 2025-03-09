import SwiftUI

#if canImport(UIKit)
  struct ContentView: View {
    var text: String?
    var translated: String?

    var body: some View {
      SubtitlesView(text: text ?? "", translated: translated)
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
