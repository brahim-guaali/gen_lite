import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling text-to-speech functionality
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // Default settings
  String _language = 'en-US';
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  /// Initialize the text-to-speech service
  Future<void> initialize() async {
    try {
      // Set default language
      await _flutterTts.setLanguage(_language);

      // Set default speech rate
      await _flutterTts.setSpeechRate(_speechRate);

      // Set default volume
      await _flutterTts.setVolume(_volume);

      // Set default pitch
      await _flutterTts.setPitch(_pitch);

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Set up error handler
      _flutterTts.setErrorHandler((msg) {
        print('TTS Error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize TTS: $e');
      _isInitialized = false;
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      // Remove emojis before speaking
      final cleanText = TTSService.removeEmojis(text);

      _isSpeaking = true;
      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('Failed to speak text: $e');
      _isSpeaking = false;
    }
  }

  /// Remove emojis from text
  static String removeEmojis(String text) {
    // Emoji regex pattern (covers most common emojis)
    final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true);
    return text.replaceAll(emojiRegex, '');
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Failed to stop TTS: $e');
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Check if TTS is available
  bool get isAvailable => _isInitialized;

  /// Set the language for speech
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      _language = language;
    } catch (e) {
      print('Failed to set language: $e');
    }
  }

  /// Set the speech rate (0.1 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      final clampedRate = rate.clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(clampedRate);
      _speechRate = clampedRate;
    } catch (e) {
      print('Failed to set speech rate: $e');
    }
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(clampedVolume);
      _volume = clampedVolume;
    } catch (e) {
      print('Failed to set volume: $e');
    }
  }

  /// Set the pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(clampedPitch);
      _pitch = clampedPitch;
    } catch (e) {
      print('Failed to set pitch: $e');
    }
  }

  /// Get available languages
  Future<List<Map<String, String>>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<Map<String, String>>();
    } catch (e) {
      print('Failed to get available languages: $e');
      return [];
    }
  }

  /// Get current settings
  Map<String, dynamic> getCurrentSettings() {
    return {
      'language': _language,
      'speechRate': _speechRate,
      'volume': _volume,
      'pitch': _pitch,
    };
  }

  /// Update multiple settings at once
  Future<void> updateSettings({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (language != null) await setLanguage(language);
    if (speechRate != null) await setSpeechRate(speechRate);
    if (volume != null) await setVolume(volume);
    if (pitch != null) await setPitch(pitch);
  }

  /// Check if TTS is supported on this device
  Future<bool> isTTSSupported() async {
    try {
      final languages = await getAvailableLanguages();
      return languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    if (_isSpeaking) {
      _flutterTts.stop();
    }
    _isSpeaking = false;
    _isInitialized = false;
  }
}
