#if canImport(AppKit)
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
#endif
