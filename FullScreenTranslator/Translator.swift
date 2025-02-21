import Translation

@Observable class Translator {
  private var session: TranslationSession?

  func setSession(_ session: TranslationSession) {
    self.session = session
  }

  private var lastTask: Task<Void, any Error>?

  var translated: String?

  func translate(_ text: String) {
    guard let session else {
      return
    }
    lastTask?.cancel()
    self.lastTask = Task {
      self.translated = try await session.translate(text).targetText
    }
  }
}
