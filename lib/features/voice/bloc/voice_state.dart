import 'package:equatable/equatable.dart';

/// Base class for voice-related states
abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object?> get props => [];
}

/// Initial voice state
class VoiceInitial extends VoiceState {
  const VoiceInitial();
}

/// State when voice services are being initialized
class VoiceInitializing extends VoiceState {
  const VoiceInitializing();
}

/// State when listening for voice input
class VoiceListening extends VoiceState {
  const VoiceListening();
}

/// State when processing voice input
class VoiceProcessing extends VoiceState {
  const VoiceProcessing();
}

/// State when voice output is enabled with current settings
class VoiceOutputEnabled extends VoiceState {
  final bool enabled;
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
  final bool isSpeaking;

  const VoiceOutputEnabled({
    this.enabled = false,
    this.language = 'en-US',
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.isSpeaking = false,
  });

  VoiceOutputEnabled copyWith({
    bool? enabled,
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
    bool? isSpeaking,
  }) {
    return VoiceOutputEnabled(
      enabled: enabled ?? this.enabled,
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        language,
        speechRate,
        volume,
        pitch,
        isSpeaking,
      ];
}

/// State when voice recognition is available and ready
class VoiceReady extends VoiceState {
  final bool isListening;
  final bool voiceOutputEnabled;
  final String language;
  final double speechRate;
  final double volume;
  final double pitch;
  final bool isSpeaking;

  const VoiceReady({
    this.isListening = false,
    this.voiceOutputEnabled = false,
    this.language = 'en-US',
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.pitch = 1.0,
    this.isSpeaking = false,
  });

  VoiceReady copyWith({
    bool? isListening,
    bool? voiceOutputEnabled,
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
    bool? isSpeaking,
  }) {
    return VoiceReady(
      isListening: isListening ?? this.isListening,
      voiceOutputEnabled: voiceOutputEnabled ?? this.voiceOutputEnabled,
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      pitch: pitch ?? this.pitch,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  List<Object?> get props => [
        isListening,
        voiceOutputEnabled,
        language,
        speechRate,
        volume,
        pitch,
        isSpeaking,
      ];
}

/// State when an error occurs
class VoiceError extends VoiceState {
  final String message;
  final String? details;

  const VoiceError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

/// State when voice services are not available
class VoiceNotAvailable extends VoiceState {
  final String reason;

  const VoiceNotAvailable(this.reason);

  @override
  List<Object?> get props => [reason];
}
