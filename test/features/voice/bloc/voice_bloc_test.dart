import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

import '../../../test_config.dart';

void main() {
  group('VoiceBloc', () {
    late VoiceBloc voiceBloc;

    setUp(() {
      TestConfig.initialize();
      voiceBloc = VoiceBloc();
    });

    tearDown(() {
      voiceBloc.close();
      TestConfig.cleanup();
    });

    test('initial state should be VoiceInitial', () {
      expect(voiceBloc.state, isA<VoiceInitial>());
    });

    group('Basic Event Handling', () {
      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceInitializing when InitializeVoiceServices is added',
        build: () => voiceBloc,
        act: (bloc) => bloc.add(const InitializeVoiceServices()),
        expect: () => [
          const VoiceInitializing(),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceProcessing when VoiceInputReceived is added',
        build: () => voiceBloc,
        seed: () => const VoiceReady(
          voiceOutputEnabled: true,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
          isListening: true,
        ),
        act: (bloc) => bloc.add(const VoiceInputReceived('Hello world')),
        expect: () => [
          const VoiceProcessing(),
          const VoiceReady(
            voiceOutputEnabled: true,
            language: 'en-US',
            speechRate: 0.5,
            volume: 1.0,
            pitch: 1.0,
            isListening: false,
          ),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'does not emit when SpeakText called with voice output disabled',
        build: () => voiceBloc,
        seed: () => const VoiceReady(
          voiceOutputEnabled: false,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
        ),
        act: (bloc) => bloc.add(const SpeakText('Hello world')),
        expect: () => [],
      );

      blocTest<VoiceBloc, VoiceState>(
        'loads settings when LoadVoiceSettings called',
        build: () => voiceBloc,
        seed: () => const VoiceReady(
          voiceOutputEnabled: true,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
        ),
        act: (bloc) => bloc.add(const LoadVoiceSettings()),
        expect: () => [],
      );

      blocTest<VoiceBloc, VoiceState>(
        'saves settings when SaveVoiceSettings called',
        build: () => voiceBloc,
        seed: () => const VoiceReady(
          voiceOutputEnabled: true,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
        ),
        act: (bloc) => bloc.add(const SaveVoiceSettings()),
        expect: () => [],
      );
    });

    group('Error Handling', () {
      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError with user-friendly message when VoiceRecognitionError occurs',
        build: () => voiceBloc,
        act: (bloc) =>
            bloc.add(const VoiceRecognitionError('permission denied')),
        expect: () => [
          const VoiceError(
            'Microphone permission denied. Please enable microphone access in settings.',
          ),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError with user-friendly message when TTSError occurs',
        build: () => voiceBloc,
        act: (bloc) => bloc.add(const TTSError('language not supported')),
        expect: () => [
          const VoiceError(
            'Language not supported. Please select a different language.',
          ),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError with generic message for unknown errors',
        build: () => voiceBloc,
        act: (bloc) => bloc.add(const VoiceRecognitionError('unknown error')),
        expect: () => [
          const VoiceError('Voice recognition failed: unknown error'),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError with generic message for unknown TTS errors',
        build: () => voiceBloc,
        act: (bloc) => bloc.add(const TTSError('unknown tts error')),
        expect: () => [
          const VoiceError('Text-to-speech failed: unknown tts error'),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceInitializing when RetryVoiceInitialization is added',
        build: () => voiceBloc,
        seed: () => const VoiceError('Previous error'),
        act: (bloc) => bloc.add(const RetryVoiceInitialization()),
        expect: () => [
          const VoiceInitializing(),
        ],
      );
    });

    group('State Transitions', () {
      test('should handle multiple events without crashing', () {
        expect(() {
          voiceBloc.add(const InitializeVoiceServices());
          voiceBloc.add(const LoadVoiceSettings());
          voiceBloc.add(const SaveVoiceSettings());
          voiceBloc.add(const VoiceRecognitionError('test error'));
        }, returnsNormally);
      });

      test('should maintain state consistency after errors', () async {
        voiceBloc.add(const VoiceRecognitionError('Test error'));
        await Future.delayed(Duration.zero); // allow bloc to process event
        expect(voiceBloc.state, isA<VoiceError>());

        // Should be able to recover from error state
        voiceBloc.add(const RetryVoiceInitialization());
        await Future.delayed(Duration.zero);
        expect(voiceBloc.state, isA<VoiceInitializing>());
      });
    });

    group('Event Properties', () {
      test('VoiceInputReceived should have correct text property', () {
        const event = VoiceInputReceived('Hello world');
        expect(event.text, 'Hello world');
        expect(event.props, ['Hello world']);
      });

      test('ToggleVoiceOutput should have correct enabled property', () {
        const event = ToggleVoiceOutput(true);
        expect(event.enabled, true);
        expect(event.props, [true]);
      });

      test('UpdateVoiceSettings should have correct properties', () {
        const event = UpdateVoiceSettings(
          language: 'es-ES',
          speechRate: 0.7,
          volume: 0.8,
          pitch: 1.2,
        );
        expect(event.language, 'es-ES');
        expect(event.speechRate, 0.7);
        expect(event.volume, 0.8);
        expect(event.pitch, 1.2);
        expect(event.props, ['es-ES', 0.7, 0.8, 1.2]);
      });

      test('VoiceRecognitionError should have correct error property', () {
        const event = VoiceRecognitionError('test error');
        expect(event.error, 'test error');
        expect(event.props, ['test error']);
      });

      test('TTSError should have correct error property', () {
        const event = TTSError('test tts error');
        expect(event.error, 'test tts error');
        expect(event.props, ['test tts error']);
      });
    });
  });
}
