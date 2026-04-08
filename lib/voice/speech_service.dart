import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/model_storage_service.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();
  bool _initialized = false;
  bool _isListening = false;
  String _language = 'en';
  String _lastTranscript = '';

  bool get isListening => _isListening;
  String get language => _language;
  String get lastTranscript => _lastTranscript;

  void setLanguage(String lang) {
    _language = lang;
  }

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    if (!kIsWeb) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) return false;
      // iOS requires a separate speech recognition permission
      if (!kIsWeb && Platform.isIOS) {
        final speechStatus = await Permission.speech.request();
        if (!speechStatus.isGranted) return false;
      }
    }
    _initialized = await _stt.initialize(
      onError: (error) => debugPrint('STT error: ${error.errorMsg}'),
    );
    return _initialized;
  }

  /// Start listening for speech input.
  Future<void> startListening({
    required Function(String transcript) onResult,
    Function(String error)? onError,
  }) async {
    final ready = await _ensureInitialized();
    if (!ready) {
      onError?.call('Microphone permission denied or STT unavailable');
      return;
    }

    _isListening = true;
    _lastTranscript = '';

    // Map language code to locale ID used by speech_to_text
    final localeId = _language == 'ta' ? 'ta_IN' : 'en_US';

    await _stt.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _lastTranscript = result.recognizedWords;
          onResult(_lastTranscript);
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        partialResults: false,
      ),
    );
  }

  /// Stop listening.
  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
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
  static List<Map<String, String>> get availableLanguages =>
      [...ModelStorageService.supportedLanguages];
}
