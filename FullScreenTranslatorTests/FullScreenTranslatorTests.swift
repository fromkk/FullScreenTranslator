//

import Foundation
import Speech
import Testing
import Translation

@testable import FullScreenTranslator

struct TranslatorViewModelTest {
  @Test func testInitialization() throws {
    // Simple test to verify that the test framework is working
    #expect(1 + 1 == 2)
  }

  @Test func testSpeechRecognizerMock() throws {
    let mockSpeechRecognizer = MockSpeechRecognizer()
    #expect(mockSpeechRecognizer.isAuthorized)
    #expect(mockSpeechRecognizer.resetDuration == 2.0)
  }

  @Test func testViewModelInitialization() throws {
    // Setup
    let mockConfigStore = MockConfigurationStore()
    let mockSpeechRecognizer = MockSpeechRecognizer()
    let mockTranslator = MockTranslator()
    let mockLangAvailabilityProvider = MockLanguageAvailabilityProvider()

    let viewModel = TranslatorViewModel(
      configurationStore: mockConfigStore,
      speechRecognizerFactory: { _ in mockSpeechRecognizer },
      translator: mockTranslator,
      languageAvailabilityProvider: mockLangAvailabilityProvider
    )

    // Verify
    #expect(mockSpeechRecognizer.requestAuthorizationCalled)
  }

  @Test func testStartRecognition() throws {
    // Setup
    let mockSpeechRecognizer = MockSpeechRecognizer()
    let viewModel = TranslatorViewModel(
      configurationStore: MockConfigurationStore(),
      speechRecognizerFactory: { _ in mockSpeechRecognizer },
      translator: MockTranslator(),
      languageAvailabilityProvider: MockLanguageAvailabilityProvider()
    )

    // Execute
    viewModel.startRecognition()

    // Verify
    #expect(mockSpeechRecognizer.startRecognitionCalled)
    #expect(mockSpeechRecognizer.isRecognizing)
  }

  @Test func testStopRecognition() throws {
    // Setup
    let mockSpeechRecognizer = MockSpeechRecognizer()
    mockSpeechRecognizer.isRecognizing = true
    mockSpeechRecognizer.text = "Hello world"

    let viewModel = TranslatorViewModel(
      configurationStore: MockConfigurationStore(),
      speechRecognizerFactory: { _ in mockSpeechRecognizer },
      translator: MockTranslator(),
      languageAvailabilityProvider: MockLanguageAvailabilityProvider()
    )

    // Execute
    viewModel.stopRecognition()

    // Verify
    #expect(mockSpeechRecognizer.stopRecognitionCalled)
    #expect(!mockSpeechRecognizer.isRecognizing)
    #expect(mockSpeechRecognizer.text == nil)
  }

  @Test func testSaveConfig() throws {
    // Setup
    let mockConfigStore = MockConfigurationStore()
    let mockSpeechRecognizer = MockSpeechRecognizer()
    mockSpeechRecognizer.resetDuration = 3.0

    let viewModel = TranslatorViewModel(
      configurationStore: mockConfigStore,
      speechRecognizerFactory: { _ in mockSpeechRecognizer },
      translator: MockTranslator(),
      languageAvailabilityProvider: MockLanguageAvailabilityProvider()
    )

    // Set values to save
    viewModel.localeIdentifier = "en_US"
    viewModel.translateLanguageCode = "ja"

    // Execute
    viewModel.save()

    // Verify basic calls
    #expect(mockConfigStore.storeLocaleCalled)
    #expect(mockConfigStore.storeTranslateLanguageCalled)
    #expect(mockConfigStore.storeDurationCalled)
  }
}
