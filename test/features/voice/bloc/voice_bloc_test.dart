import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

import '../../../test_config.dart';

void main() {
  group('VoiceBloc', () {
    late VoiceBloc voiceBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() async {
      // Wait a bit for platform mocks to be ready
      await Future.delayed(const Duration(milliseconds: 100));
      voiceBloc = VoiceBloc();
      // Wait for bloc initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      try {
        await voiceBloc.close();
      } catch (e) {
        // Ignore platform plugin errors during cleanup
      }
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    test('initial state should be VoiceInitial', () {
      expect(voiceBloc.state, isA<VoiceInitial>());
    });

    group('Event Handling', () {
      test('should handle InitializeVoiceServices event', () {
        expect(() {
          voiceBloc.add(InitializeVoiceServices());
        }, returnsNormally);
      });

      test('should handle VoiceInputReceived event', () {
        expect(() {
          voiceBloc.add(const VoiceInputReceived('Hello world'));
        }, returnsNormally);
      });

      test('should handle SpeakText event', () {
        expect(() {
          voiceBloc.add(const SpeakText('Hello world'));
        }, returnsNormally);
      });

      test('should handle LoadVoiceSettings event', () {
        expect(() {
          voiceBloc.add(LoadVoiceSettings());
        }, returnsNormally);
      });

      test('should handle SaveVoiceSettings event', () {
        expect(() {
          voiceBloc.add(const SaveVoiceSettings());
        }, returnsNormally);
      });

      test('should handle VoiceRecognitionError event', () {
        expect(() {
          voiceBloc.add(const VoiceRecognitionError('test error'));
        }, returnsNormally);
      });

      test('should handle TTSError event', () {
        expect(() {
          voiceBloc.add(const TTSError('test tts error'));
        }, returnsNormally);
      });

      test('should handle RetryVoiceInitialization event', () {
        expect(() {
          voiceBloc.add(RetryVoiceInitialization());
        }, returnsNormally);
      });
    });

    group('State Transitions', () {
      test('should handle multiple events without crashing', () {
        expect(() {
          voiceBloc.add(LoadVoiceSettings());
          voiceBloc.add(const VoiceRecognitionError('test error'));
          voiceBloc.add(RetryVoiceInitialization());
        }, returnsNormally);
      });

      test('should maintain state consistency', () {
        final initialState = voiceBloc.state;
        expect(initialState, isA<VoiceInitial>());

        voiceBloc.add(InitializeVoiceServices());
        expect(voiceBloc.state, isA<VoiceState>());
      });
    });

    group('Event Properties', () {
      test('VoiceInputReceived should have correct text property', () {
        const event = VoiceInputReceived('Test input');
        expect(event.text, equals('Test input'));
      });

      test('ToggleVoiceOutput should have correct enabled property', () {
        const event = ToggleVoiceOutput(true);
        expect(event.enabled, isTrue);
      });

      test('UpdateVoiceSettings should have correct properties', () {
        const event = UpdateVoiceSettings(
          language: 'en-US',
          speechRate: 1.5,
          volume: 0.8,
          pitch: 1.2,
        );
        expect(event.language, equals('en-US'));
        expect(event.speechRate, equals(1.5));
        expect(event.volume, equals(0.8));
        expect(event.pitch, equals(1.2));
      });

      test('VoiceRecognitionError should have correct error property', () {
        const event = VoiceRecognitionError('Test error');
        expect(event.error, equals('Test error'));
      });

      test('TTSError should have correct error property', () {
        const event = TTSError('Test TTS error');
        expect(event.error, equals('Test TTS error'));
      });
    });
  });
}
