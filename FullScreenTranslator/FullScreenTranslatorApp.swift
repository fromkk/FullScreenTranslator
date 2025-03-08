import SwiftUI

@main
struct FullScreenTranslatorApp: App {
  @State private var viewModel = TranslatorViewModel()

  var body: some Scene {
    #if canImport(UIKit)
      iOSAppScene(viewModel: viewModel)
    #elseif canImport(AppKit)
      macOSAppScene(viewModel: viewModel)
    #endif
  }
}
