import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:genlite/shared/utils/logger.dart';

/// Service for handling text-to-speech functionality
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  Map<String, dynamic> _currentSettings = {};

  // Default settings
  static const String defaultLanguage = 'en-US';
  static const double defaultSpeechRate = 0.44;
  static const double defaultVolume = 0.95;
  static const double defaultPitch = 1.15;

  String _language = defaultLanguage;
  double _speechRate = defaultSpeechRate;
  double _volume = defaultVolume;
  double _pitch = defaultPitch;

  /// Initialize the text-to-speech service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _currentSettings = {
        'language': 'en-US',
        'speechRate': 0.5,
        'volume': 1.0,
        'pitch': 1.0,
      };

      _isInitialized = true;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to initialize TTS', error: e);
      rethrow;
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
      Logger.error(LogTags.ttsService, 'Failed to speak text', error: e);
      rethrow;
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
      Logger.error(LogTags.ttsService, 'Failed to stop TTS', error: e);
      rethrow;
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
      _currentSettings['language'] = language;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to set language', error: e);
      rethrow;
    }
  }

  /// Set the speech rate (0.1 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      final clampedRate = rate.clamp(0.1, 1.0);
      await _flutterTts.setSpeechRate(clampedRate);
      _speechRate = clampedRate;
      _currentSettings['speechRate'] = clampedRate;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to set speech rate', error: e);
      rethrow;
    }
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(clampedVolume);
      _volume = clampedVolume;
      _currentSettings['volume'] = clampedVolume;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to set volume', error: e);
      rethrow;
    }
  }

  /// Set the pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(clampedPitch);
      _pitch = clampedPitch;
      _currentSettings['pitch'] = clampedPitch;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to set pitch', error: e);
      rethrow;
    }
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.cast<String>();
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to get available languages',
          error: e);
      return [];
    }
  }

  /// Get current settings
  Map<String, dynamic> getCurrentSettings() {
    return Map.from(_currentSettings);
  }

  /// Update multiple settings at once
  Future<void> updateSettings({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    try {
      if (language != null) await setLanguage(language);
      if (speechRate != null) await setSpeechRate(speechRate);
      if (volume != null) await setVolume(volume);
      if (pitch != null) await setPitch(pitch);
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to update settings', error: e);
      rethrow;
    }
  }

  /// Check if TTS is supported on this device
  Future<bool> isTTSSupported() async {
    try {
      final available = await _flutterTts.isLanguageAvailable('en-US');
      return available == 1;
    } catch (e) {
      Logger.error(LogTags.ttsService, 'Failed to check TTS support', error: e);
      return false;
    }
  }

  /// Dispose of resources
  Future<void> dispose() async {
    if (_isSpeaking) {
      await stop();
    }
    _isSpeaking = false;
    _isInitialized = false;
    await _flutterTts.stop();
  }

  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
}
