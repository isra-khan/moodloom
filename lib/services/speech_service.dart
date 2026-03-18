import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;

  /// Initialize speech recognition. Returns true if available.
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  /// Start listening. Calls [onResult] with the recognized text (translated to English).
  /// [onListening] is called when listening state changes.
  Future<void> startListening({
    required void Function(String translatedText) onResult,
    void Function(bool isListening)? onListening,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    await _speech.listen(
      onResult: (result) async {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          final raw = result.recognizedWords;
          // Translate to English
          try {
            final translation = await _translator.translate(raw, to: 'en');
            onResult(translation.text);
          } catch (_) {
            // If translation fails, return raw text
            onResult(raw);
          }
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: false,
      ),
    );
    onListening?.call(true);
  }

  /// Stop listening.
  Future<void> stopListening({void Function(bool isListening)? onListening}) async {
    await _speech.stop();
    onListening?.call(false);
  }

  /// Get available locales for speech recognition.
  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }
}
