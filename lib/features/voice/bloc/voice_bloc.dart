import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/shared/services/speech_service.dart';
import 'package:genlite/shared/services/tts_service.dart';
import 'package:genlite/shared/services/storage_service.dart';
import 'package:genlite/shared/utils/logger.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

/// BLoC for managing voice input and output functionality
class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();

  // Storage keys for voice settings
  static const String _voiceOutputEnabledKey = 'voice_output_enabled';
  static const String _voiceLanguageKey = 'voice_language';
  static const String _voiceSpeechRateKey = 'voice_speech_rate';
  static const String _voiceVolumeKey = 'voice_volume';
  static const String _voicePitchKey = 'voice_pitch';

  VoiceBloc() : super(const VoiceInitial()) {
    on<InitializeVoiceServices>(_onInitializeVoiceServices);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<VoiceInputReceived>(_onVoiceInputReceived);
    on<ToggleVoiceOutput>(_onToggleVoiceOutput);
    on<SpeakText>(_onSpeakText);
    on<StopSpeaking>(_onStopSpeaking);
    on<UpdateVoiceSettings>(_onUpdateVoiceSettings);
    on<LoadVoiceSettings>(_onLoadVoiceSettings);
    on<SaveVoiceSettings>(_onSaveVoiceSettings);
    on<VoiceRecognitionError>(_onVoiceRecognitionError);
    on<TTSError>(_onTTSError);
    on<RetryVoiceInitialization>(_onRetryVoiceInitialization);
  }

  /// Initialize voice services
  Future<void> _onInitializeVoiceServices(
    InitializeVoiceServices event,
    Emitter<VoiceState> emit,
  ) async {
    Logger.logMethod('VoiceBloc', '_onInitializeVoiceServices');
    emit(const VoiceInitializing());

    try {
      // Initialize speech recognition
      final speechAvailable = await _speechService.initialize();

      // Initialize TTS
      await _ttsService.initialize();
      final ttsAvailable = await _ttsService.isTTSSupported();

      if (!speechAvailable && !ttsAvailable) {
        Logger.warning(
            LogTags.voiceBloc, 'Speech recognition and TTS not available');
        emit(const VoiceNotAvailable(
            'Speech recognition and TTS not available'));
        return;
      }

      // Load saved settings
      await _loadSettings();

      // Emit ready state
      emit(VoiceReady(
        voiceOutputEnabled: _ttsService.getCurrentSettings()['volume'] > 0,
        language: _ttsService.getCurrentSettings()['language'],
        speechRate: _ttsService.getCurrentSettings()['speechRate'],
        volume: _ttsService.getCurrentSettings()['volume'],
        pitch: _ttsService.getCurrentSettings()['pitch'],
      ));

      Logger.info(LogTags.voiceBloc, 'Voice services initialized successfully');
    } catch (e) {
      Logger.error(LogTags.voiceBloc, 'Failed to initialize voice services',
          error: e);
      emit(VoiceError('Failed to initialize voice services: $e'));
    }
  }

  /// Start listening for voice input
  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.debug(LogTags.voiceBloc, 'Starting to listen for voice input');
        emit(currentState.copyWith(isListening: true));

        await _speechService.startListening(
          onResult: (text) {
            add(VoiceInputReceived(text));
          },
          onError: (error) {
            add(VoiceRecognitionError(error));
          },
        );
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to start listening', error: e);
        emit(VoiceError('Failed to start listening: $e'));
      }
    }
  }

  /// Stop listening for voice input
  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.debug(LogTags.voiceBloc, 'Stopping voice input listening');
        await _speechService.stopListening();
        emit(currentState.copyWith(isListening: false));
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to stop listening', error: e);
        emit(VoiceError('Failed to stop listening: $e'));
      }
    }
  }

  /// Handle received voice input
  Future<void> _onVoiceInputReceived(
    VoiceInputReceived event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.debug(
            LogTags.voiceBloc, 'Voice input received: "${event.text}"');

        // Stop listening
        await _speechService.stopListening();

        // Emit processing state
        emit(const VoiceProcessing());

        // Return to ready state with updated listening status
        emit(currentState.copyWith(isListening: false));

        // Here you would typically send the text to the chat BLoC
        // This will be handled by the UI layer
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to process voice input',
            error: e);
        emit(VoiceError('Failed to process voice input: $e'));
        emit(currentState.copyWith(isListening: false));
      }
    }
  }

  /// Toggle voice output on/off
  Future<void> _onToggleVoiceOutput(
    ToggleVoiceOutput event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.info(
            LogTags.voiceBloc, 'Toggling voice output: ${event.enabled}');

        // Update TTS volume based on enabled state
        final newVolume = event.enabled ? currentState.volume : 0.0;
        await _ttsService.setVolume(newVolume);

        // Save setting
        await StorageService.saveSetting(_voiceOutputEnabledKey, event.enabled);

        emit(currentState.copyWith(voiceOutputEnabled: event.enabled));
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to toggle voice output',
            error: e);
        emit(VoiceError('Failed to toggle voice output: $e'));
      }
    }
  }

  /// Speak text using TTS
  Future<void> _onSpeakText(
    SpeakText event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      if (!currentState.voiceOutputEnabled) {
        Logger.debug(
            LogTags.voiceBloc, 'Voice output disabled, skipping speech');
        return;
      }

      try {
        Logger.debug(LogTags.voiceBloc, 'Speaking text: "${event.text}"');
        emit(currentState.copyWith(isSpeaking: true));

        await _ttsService.speak(event.text);

        // Note: The speaking state will be updated when TTS completes
        // This is handled by the TTS service completion handler
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to speak text', error: e);
        emit(VoiceError('Failed to speak text: $e'));
        emit(currentState.copyWith(isSpeaking: false));
      }
    }
  }

  /// Stop current speech
  Future<void> _onStopSpeaking(
    StopSpeaking event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.debug(LogTags.voiceBloc, 'Stopping current speech');
        await _ttsService.stop();
        emit(currentState.copyWith(isSpeaking: false));
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to stop speaking', error: e);
        emit(VoiceError('Failed to stop speaking: $e'));
      }
    }
  }

  /// Update voice settings
  Future<void> _onUpdateVoiceSettings(
    UpdateVoiceSettings event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      try {
        Logger.info(LogTags.voiceBloc, 'Updating voice settings', data: {
          'language': event.language,
          'speechRate': event.speechRate,
          'volume': event.volume,
          'pitch': event.pitch,
        });

        // Update TTS settings
        await _ttsService.updateSettings(
          language: event.language,
          speechRate: event.speechRate,
          volume: event.volume,
          pitch: event.pitch,
        );

        // Get updated settings
        final settings = _ttsService.getCurrentSettings();

        // Save settings
        await _saveSettings(settings);

        // Update state
        emit(currentState.copyWith(
          language: settings['language'],
          speechRate: settings['speechRate'],
          volume: settings['volume'],
          pitch: settings['pitch'],
        ));
      } catch (e) {
        Logger.error(LogTags.voiceBloc, 'Failed to update voice settings',
            error: e);
        emit(VoiceError('Failed to update voice settings: $e'));
      }
    }
  }

  /// Load voice settings from storage
  Future<void> _onLoadVoiceSettings(
    LoadVoiceSettings event,
    Emitter<VoiceState> emit,
  ) async {
    Logger.debug(LogTags.voiceBloc, 'Loading voice settings from storage');
    await _loadSettings();
  }

  /// Save voice settings to storage
  Future<void> _onSaveVoiceSettings(
    SaveVoiceSettings event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;
      Logger.debug(LogTags.voiceBloc, 'Saving voice settings to storage');
      final settings = _ttsService.getCurrentSettings();
      await _saveSettings(settings);
    }
  }

  /// Handle voice recognition errors
  Future<void> _onVoiceRecognitionError(
    VoiceRecognitionError event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;

      // Stop listening and return to ready state
      try {
        await _speechService.stopListening();
        emit(currentState.copyWith(isListening: false));
      } catch (e) {
        // If stopping fails, still emit the error
      }
    }

    // Provide user-friendly error messages
    String userMessage;
    if (event.error.contains('permission')) {
      userMessage =
          'Microphone permission denied. Please enable microphone access in settings.';
    } else if (event.error.contains('network')) {
      userMessage = 'Network error. Please check your internet connection.';
    } else if (event.error.contains('timeout')) {
      userMessage = 'Voice recognition timed out. Please try again.';
    } else {
      userMessage = 'Voice recognition failed: ${event.error}';
    }

    Logger.warning(
        LogTags.voiceBloc, 'Voice recognition error: ${event.error}');
    emit(VoiceError(userMessage));
  }

  /// Handle TTS errors
  Future<void> _onTTSError(
    TTSError event,
    Emitter<VoiceState> emit,
  ) async {
    if (state is VoiceReady) {
      final currentState = state as VoiceReady;
      emit(currentState.copyWith(isSpeaking: false));
    }

    // Provide user-friendly error messages
    String userMessage;
    if (event.error.contains('language')) {
      userMessage =
          'Language not supported. Please select a different language.';
    } else if (event.error.contains('volume')) {
      userMessage = 'Volume setting error. Please adjust volume in settings.';
    } else if (event.error.contains('network')) {
      userMessage = 'Network error. Please check your internet connection.';
    } else {
      userMessage = 'Text-to-speech failed: ${event.error}';
    }

    Logger.warning(LogTags.voiceBloc, 'TTS error: ${event.error}');
    emit(VoiceError(userMessage));
  }

  /// Retry voice initialization
  Future<void> _onRetryVoiceInitialization(
    RetryVoiceInitialization event,
    Emitter<VoiceState> emit,
  ) async {
    Logger.info(LogTags.voiceBloc, 'Retrying voice initialization');
    // Re-run the initialization process
    await _onInitializeVoiceServices(
      const InitializeVoiceServices(),
      emit,
    );
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final voiceOutputEnabled =
          await StorageService.getSetting<bool>(_voiceOutputEnabledKey) ??
              false;
      final language =
          await StorageService.getSetting<String>(_voiceLanguageKey) ?? 'en-US';
      final speechRate =
          await StorageService.getSetting<double>(_voiceSpeechRateKey) ?? 0.5;
      final volume =
          await StorageService.getSetting<double>(_voiceVolumeKey) ?? 1.0;
      final pitch =
          await StorageService.getSetting<double>(_voicePitchKey) ?? 1.0;

      await _ttsService.updateSettings(
        language: language,
        speechRate: speechRate,
        volume: voiceOutputEnabled ? volume : 0.0,
        pitch: pitch,
      );
    } catch (e) {
      Logger.error(LogTags.voiceBloc, 'Failed to load voice settings',
          error: e);
    }
  }

  /// Save settings to storage
  Future<void> _saveSettings(Map<String, dynamic> settings) async {
    try {
      await StorageService.saveSetting(_voiceLanguageKey, settings['language']);
      await StorageService.saveSetting(
          _voiceSpeechRateKey, settings['speechRate']);
      await StorageService.saveSetting(_voiceVolumeKey, settings['volume']);
      await StorageService.saveSetting(_voicePitchKey, settings['pitch']);
    } catch (e) {
      Logger.error(LogTags.voiceBloc, 'Failed to save voice settings',
          error: e);
    }
  }

  @override
  Future<void> close() {
    _speechService.dispose();
    _ttsService.dispose();
    return super.close();
  }
}
