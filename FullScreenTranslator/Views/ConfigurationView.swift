import Speech
import SwiftUI

struct ConfigurationView: View {
  let supportedLanguageCodes: [String]
  @Binding var localeIdentifier: String
  @Binding var translateLanguageCode: String
  @Binding var resetDuration: TimeInterval

  private let durations: [TimeInterval] = [0.5, 1, 2, 3]

  var body: some View {
    VStack(spacing: 8) {
      Picker(
        "Base locale", selection: $localeIdentifier,
        content: {
          ForEach(
            Array(
              SFSpeechRecognizer.supportedLocales().sorted(
                using: KeyPathComparator(\.identifier))
            ).map(\.identifier), id: \.self
          ) { currentLocale in
            Text(currentLocale).tag(currentLocale)
          }
        }
      )

      Picker(
        "Translate language", selection: $translateLanguageCode,
        content: {
          ForEach(supportedLanguageCodes, id: \.self) { language in
            Text(language).tag(language)
          }
        }
      )

      Picker(
        "Silent duration",
        selection: $resetDuration,
        content: {
          ForEach(durations, id: \.self) { duration in
            Text("\(duration)").tag(duration)
          }
        }
      )
    }
  }
}
