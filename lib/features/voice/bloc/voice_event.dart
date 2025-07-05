import 'package:equatable/equatable.dart';

/// Base class for voice-related events
abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start listening for voice input
class StartListening extends VoiceEvent {
  const StartListening();
}

/// Event to stop listening for voice input
class StopListening extends VoiceEvent {
  const StopListening();
}

/// Event when voice input is received
class VoiceInputReceived extends VoiceEvent {
  final String text;

  const VoiceInputReceived(this.text);

  @override
  List<Object?> get props => [text];
}

/// Event to toggle voice output on/off
class ToggleVoiceOutput extends VoiceEvent {
  final bool enabled;

  const ToggleVoiceOutput(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to speak text using TTS
class SpeakText extends VoiceEvent {
  final String text;

  const SpeakText(this.text);

  @override
  List<Object?> get props => [text];
}

/// Event to stop current speech
class StopSpeaking extends VoiceEvent {
  const StopSpeaking();
}

/// Event to update voice settings
class UpdateVoiceSettings extends VoiceEvent {
  final String? language;
  final double? speechRate;
  final double? volume;
  final double? pitch;

  const UpdateVoiceSettings({
    this.language,
    this.speechRate,
    this.volume,
    this.pitch,
  });

  @override
  List<Object?> get props => [language, speechRate, volume, pitch];
}

/// Event to initialize voice services
class InitializeVoiceServices extends VoiceEvent {
  const InitializeVoiceServices();
}

/// Event to load voice settings from storage
class LoadVoiceSettings extends VoiceEvent {
  const LoadVoiceSettings();
}

/// Event to save voice settings to storage
class SaveVoiceSettings extends VoiceEvent {
  const SaveVoiceSettings();
}

/// Event when voice recognition error occurs
class VoiceRecognitionError extends VoiceEvent {
  final String error;

  const VoiceRecognitionError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Event when TTS error occurs
class TTSError extends VoiceEvent {
  final String error;

  const TTSError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Event to retry voice initialization
class RetryVoiceInitialization extends VoiceEvent {
  const RetryVoiceInitialization();
}
