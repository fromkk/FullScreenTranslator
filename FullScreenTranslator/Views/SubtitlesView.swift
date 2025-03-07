import SwiftUI

#if canImport(UIKit)
  struct SubtitlesView: View {
    var text: String
    var translated: String?

    var body: some View {
      VStack {
        VStack(spacing: 8) {
          Text(text)
            .font(.system(.body, weight: .regular))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            .textSelection(.enabled)

          if let translated {
            Text(translated)
              .font(.system(.headline, weight: .medium))
              .frame(maxWidth: .infinity, alignment: .center)
              .multilineTextAlignment(.center)
              .textSelection(.enabled)
          }
        }
      }
    }
  }
#elseif canImport(AppKit)
  struct SubtitlesView: View {
    var text: String
    var translated: String?

    var body: some View {
      VStack {
        Spacer()
        VStack(spacing: 8) {
          Text(text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)

          if let translated {
            Text(translated)
              .font(.system(size: 48, weight: .bold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity, alignment: .center)
              .multilineTextAlignment(.center)
          }
        }
        .background(Color.black.opacity(0.6))
      }
      .ignoresSafeArea()
    }
  }
#endif
