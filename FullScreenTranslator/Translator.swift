import Translation

@Observable class Translator {
  private var session: TranslationSession?

  func setSession(_ session: TranslationSession) {
    print("\(Self.self).\(#function)")
    self.session = session
  }

  private var lastTask: Task<Void, any Error>?

  var translated: String?

  func translate(_ text: String) {
    print("\(Self.self).\(#function) \(text)")
    guard let session else {
      return
    }
    lastTask?.cancel()
    self.lastTask = Task {
      do {
        self.translated = try await session.translate(text).targetText
        print("\(Self.self).translate \(self.translated ?? "no result")")
      } catch {
        print("\(Self.self).error \(error.localizedDescription)")
      }
    }
  }
}
