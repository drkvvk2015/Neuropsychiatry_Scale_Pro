import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Voice Service for speech-to-text input
/// Supports both English and Tamil languages
class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _localeId = 'en_US';
  String? _lastError;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String? get lastError => _lastError;
  String get currentLocale => _localeId;

  /// Initialize the voice service
  Future<bool> initialize() async {
    try {
      // Request microphone permission
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          _lastError = 'Microphone permission denied';
          return false;
        }
      }

      _isInitialized = await _speech.initialize(
        onError: (error) {
          _lastError = error?.errorMsg;
        },
      );

      if (_isInitialized) {
        debugPrint('Voice service initialized');
      } else {
        _lastError = 'Speech recognition not available';
      }

      return _isInitialized;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Error initializing voice service: $e');
      return false;
    }
  }

  /// Set the language for speech recognition
  /// Supported: 'en_US' (English), 'ta_IN' (Tamil)
  Future<void> setLanguage(String localeId) async {
    if (!_isInitialized) {
      await initialize();
    }

    final locales = await _speech.locales();
    final locale = locales.firstWhere(
      (l) => l.localeId == localeId,
      orElse: () => locales.first,
    );

    _localeId = locale.localeId;
    debugPrint('Voice language set to: $_localeId');
  }

  /// Start listening for speech
  void startListening({
    void Function(String)? onResult,
    void Function()? onComplete,
    void Function(String)? onError,
  }) {
    if (!_isInitialized) {
      throw Exception('Voice service not initialized');
    }

    if (_isListening) {
      stopListening();
    }

    _isListening = true;

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onComplete?.call();
        }
        onResult?.call(result.recognizedWords);
      },
      localeId: _localeId,
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speech.locales();
  }

  /// Check if a specific language is available
  Future<bool> isLanguageAvailable(String localeId) async {
    final locales = await getAvailableLocales();
    return locales.any((l) => l.localeId == localeId);
  }

  /// Parse voice input for scale scoring
  /// Returns a map of item IDs to scores
  Map<String, int> parseScaleResponse({
    required String response,
    required List<String> itemIds,
    required int maxScore,
  }) {
    final scores = <String, int>{};
    final lowerResponse = response.toLowerCase();

    // Common keywords for score levels
    final scoreKeywords = {
      0: ['not at all', 'none', 'no', 'never', 'zero', 'illai', 'வேண்டாம்'],
      1: ['slight', 'a little', 'sometimes', 'few days', 'mild', 'ஒரு சில', 'சிறிது'],
      2: ['moderate', 'often', 'more than half', 'several days', 'medium', 'பெரும்பாலும்'],
      3: ['severe', 'always', 'nearly every day', 'extreme', 'heavy', 'எப்போதும்', 'கடுமையான'],
    };

    // Simple parsing - in production, this would be more sophisticated
    for (int i = 0; i < itemIds.length; i++) {
      int score = 0;
      
      for (final entry in scoreKeywords.entries) {
        if (entry.value.any((keyword) => lowerResponse.contains(keyword))) {
          score = entry.key.clamp(0, maxScore);
          break;
        }
      }
      
      scores[itemIds[i]] = score;
    }

    return scores;
  }

  /// Convert numbers spoken as words to integers
  int? parseSpokenNumber(String words) {
    final numberWords = {
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9,
      'ten': 10, 'eleven': 11, 'twelve': 12,
    };

    final lowerWords = words.toLowerCase().trim();
    
    if (numberWords.containsKey(lowerWords)) {
      return numberWords[lowerWords];
    }

    // Try to parse as direct number
    try {
      return int.parse(lowerWords);
    } catch (e) {
      return null;
    }
  }

  /// Get status message for UI display
  String getStatusMessage() {
    if (!_isInitialized) {
      return 'Voice service not available';
    }
    if (_isListening) {
      return 'Listening...';
    }
    return 'Tap to speak';
  }

  /// Dispose of voice service resources
  void dispose() {
    if (_isListening) {
      stopListening();
    }
    _speech.cancel();
    _isInitialized = false;
  }
}