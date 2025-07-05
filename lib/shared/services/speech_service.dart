import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:genlite/shared/utils/logger.dart';

/// Service for handling speech recognition functionality
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final available = await _speechToText.initialize(
        onError: (error) {
          Logger.error(LogTags.speechService,
              'Speech recognition error: ${error.errorMsg}');
        },
        onStatus: (status) {
          Logger.debug(
              LogTags.speechService, 'Speech recognition status: $status');
        },
      );

      _isInitialized = available;
      return available;
    } catch (e) {
      Logger.error(
          LogTags.speechService, 'Failed to initialize speech recognition',
          error: e);
      return false;
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String text) onResult,
    required Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Speech recognition not available');
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      _isListening = false;
      Logger.error(LogTags.speechService, 'Failed to start listening',
          error: e);
      onError(e.toString());
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized;

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  /// Check if speech recognition is supported on this device
  Future<bool> isSpeechRecognitionAvailable() async {
    if (!_isInitialized) {
      return await initialize();
    }
    return _isInitialized;
  }

  /// Dispose of resources
  void dispose() {
    if (_isListening) {
      stopListening();
    }
  }
}
