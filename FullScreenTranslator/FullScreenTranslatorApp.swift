import AppKit
import SwiftUI

// NSWindowへアクセスするためのNSViewRepresentable
struct WindowAccessor: NSViewRepresentable {
  var text: String?
  var callback: (NSWindow?) -> Void

  func makeNSView(context: Context) -> NSView {
    let view = NSView()
    // 次のRunLoopでwindowプロパティにアクセス
    DispatchQueue.main.async {
      self.callback(view.window)
    }
    return view
  }

  func updateNSView(_ nsView: NSView, context: Context) {
    guard let window = nsView.window else { return }
    if text?.isEmpty ?? true {
      window.orderOut(nil)
    } else {
      window.orderFront(nil)
    }
  }
}

// 下部に固定された字幕風テキストを表示するビュー
struct SubtitlesView: View {
  var text: String

  var body: some View {
    VStack {
      Spacer()  // 画面上部の余白
      Text(text)
        .font(.system(size: 48, weight: .bold))
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        // 背景を半透明の黒にして視認性を向上
        .background(Color.black.opacity(0.6))
    }
    .ignoresSafeArea()
  }
}

// メインコンテンツ。WindowAccessorでNSWindowの設定を変更してオーバーレイウィンドウにする
struct ContentView: View {
  var text: String?

  var body: some View {
    ZStack {
      if let text {
        SubtitlesView(text: text)
      }
      WindowAccessor(text: text) { window in
        if let window = window {
          window.isOpaque = false
          window.backgroundColor = .clear
          window.styleMask = [.borderless]
          // 他のアプリより前面に表示するため、ウィンドウレベルを設定
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

@main
struct FullScreenTranslatorApp: App {
  @State var error: (any Error)?
  @State var speechRecognizer = SpeechRecognizer()

  var body: some Scene {
    WindowGroup {
      ContentView(text: speechRecognizer.text)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    // タイトルバーを非表示にするなど、ウィンドウスタイルを設定
    .windowStyle(HiddenTitleBarWindowStyle())

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
