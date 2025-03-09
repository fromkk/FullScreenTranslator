import SwiftUI

struct WarningMessage: View {
  let systemName: String
  let text: LocalizedStringKey

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemName)
        .font(.headline)
        .foregroundColor(.red)
      Text(text)
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.red.opacity(0.1))
    .foregroundColor(.primary)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.red.opacity(0.3), lineWidth: 1)
    )
  }
}
