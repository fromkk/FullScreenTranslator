import SwiftUI

#if canImport(UIKit)
  struct SubtitlesView: View {
    var text: String
    var translated: String?

    var body: some View {
      VStack {
        VStack(spacing: 16) {
          VStack(spacing: 8) {
            Text("Original")
              .font(.caption)
              .foregroundStyle(.secondary)

            Text(text)
              .font(.system(.body, weight: .medium))
              .frame(maxWidth: .infinity, alignment: .center)
              .multilineTextAlignment(.center)
              .textSelection(.enabled)
              .padding()
              .background(Color(.systemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
          }

          if let translated {
            VStack(spacing: 8) {
              Text("Translation")
                .font(.caption)
                .foregroundStyle(.secondary)

              Text(translated)
                .font(.system(.headline, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
          }
        }
      }
      .padding(.horizontal)
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
