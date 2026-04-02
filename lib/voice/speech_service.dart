/// Voice/Speech service interface.
/// Provides offline speech recognition using Vosk (Tamil + English).
/// In production, integrate with vosk_flutter package.
class SpeechService {
  bool _isListening = false;
  String _language = 'en';
  String _lastTranscript = '';

  bool get isListening => _isListening;
  String get language => _language;
  String get lastTranscript => _lastTranscript;

  void setLanguage(String lang) {
    _language = lang;
  }

  /// Start listening for speech input.
  /// In production, initializes the Vosk model and starts recognition.
  Future<void> startListening({
    required Function(String transcript) onResult,
    Function(String error)? onError,
  }) async {
    _isListening = true;
    // Stub: in production, connect to Vosk offline ASR engine
    // vosk_flutter would call onResult with recognized text
    _lastTranscript = '';
    onResult('');
  }

  /// Stop listening.
  Future<void> stopListening() async {
    _isListening = false;
  }

  /// Parse a spoken score from transcript (e.g., "three" → 3).
  static int? parseScore(String transcript) {
    final t = transcript.trim().toLowerCase();
    const wordMap = {
      'zero': 0, 'one': 1, 'two': 2, 'three': 3,
      'four': 4, 'five': 5, 'six': 6, 'seven': 7,
      // Tamil numerals (transliterated)
      'sifar': 0, 'onru': 1, 'irandu': 2, 'moondru': 3,
      'naangu': 4, 'ainthu': 5, 'aaru': 6, 'yezhu': 7,
    };
    if (wordMap.containsKey(t)) return wordMap[t];
    return int.tryParse(t);
  }

  /// Available language models.
  static List<Map<String, String>> get availableLanguages => [
        {'code': 'en', 'name': 'English', 'path': 'assets/models/en'},
        {'code': 'ta', 'name': 'Tamil', 'path': 'assets/models/ta'},
      ];
}
