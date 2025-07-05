import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/voice/bloc/voice_state.dart';

void main() {
  group('VoiceState', () {
    group('VoiceInitial', () {
      test('should be equatable', () {
        const state1 = VoiceInitial();
        const state2 = VoiceInitial();
        expect(state1, state2);
      });

      test('should have empty props', () {
        const state = VoiceInitial();
        expect(state.props, isEmpty);
      });
    });

    group('VoiceInitializing', () {
      test('should be equatable', () {
        const state1 = VoiceInitializing();
        const state2 = VoiceInitializing();
        expect(state1, state2);
      });

      test('should have empty props', () {
        const state = VoiceInitializing();
        expect(state.props, isEmpty);
      });
    });

    group('VoiceListening', () {
      test('should be equatable', () {
        const state1 = VoiceListening();
        const state2 = VoiceListening();
        expect(state1, state2);
      });

      test('should have empty props', () {
        const state = VoiceListening();
        expect(state.props, isEmpty);
      });
    });

    group('VoiceProcessing', () {
      test('should be equatable', () {
        const state1 = VoiceProcessing();
        const state2 = VoiceProcessing();
        expect(state1, state2);
      });

      test('should have empty props', () {
        const state = VoiceProcessing();
        expect(state.props, isEmpty);
      });
    });

    group('VoiceOutputEnabled', () {
      test('should create with default values', () {
        const state = VoiceOutputEnabled();
        expect(state.enabled, false);
        expect(state.language, 'en-US');
        expect(state.speechRate, 0.5);
        expect(state.volume, 1.0);
        expect(state.pitch, 1.0);
        expect(state.isSpeaking, false);
      });

      test('should create with custom values', () {
        const state = VoiceOutputEnabled(
          enabled: true,
          language: 'es-ES',
          speechRate: 1.5,
          volume: 0.8,
          pitch: 1.2,
          isSpeaking: true,
        );
        expect(state.enabled, true);
        expect(state.language, 'es-ES');
        expect(state.speechRate, 1.5);
        expect(state.volume, 0.8);
        expect(state.pitch, 1.2);
        expect(state.isSpeaking, true);
      });

      test('should be equatable', () {
        const state1 = VoiceOutputEnabled(enabled: true);
        const state2 = VoiceOutputEnabled(enabled: true);
        const state3 = VoiceOutputEnabled(enabled: false);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const state = VoiceOutputEnabled(
          enabled: true,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
          isSpeaking: false,
        );
        expect(state.props, [true, 'en-US', 0.5, 1.0, 1.0, false]);
      });

      test('should copy with new values', () {
        const state = VoiceOutputEnabled(enabled: false);

        final copiedState = state.copyWith(
          enabled: true,
          speechRate: 1.5,
        );

        expect(copiedState.enabled, true);
        expect(copiedState.language, 'en-US');
        expect(copiedState.speechRate, 1.5);
        expect(copiedState.volume, 1.0);
      });

      test('should copy with partial values', () {
        const state = VoiceOutputEnabled(
          enabled: true,
          isSpeaking: true,
          speechRate: 0.5,
        );

        final copiedState = state.copyWith(isSpeaking: false);

        expect(copiedState.enabled, true);
        expect(copiedState.isSpeaking, false);
        expect(copiedState.speechRate, 0.5);
      });
    });

    group('VoiceReady', () {
      test('should create with default values', () {
        const state = VoiceReady();
        expect(state.isListening, false);
        expect(state.voiceOutputEnabled, false);
        expect(state.language, 'en-US');
        expect(state.speechRate, 0.5);
        expect(state.volume, 1.0);
        expect(state.pitch, 1.0);
        expect(state.isSpeaking, false);
      });

      test('should create with custom values', () {
        const state = VoiceReady(
          isListening: true,
          voiceOutputEnabled: true,
          language: 'es-ES',
          speechRate: 1.5,
          volume: 0.8,
          pitch: 1.2,
          isSpeaking: true,
        );
        expect(state.isListening, true);
        expect(state.voiceOutputEnabled, true);
        expect(state.language, 'es-ES');
        expect(state.speechRate, 1.5);
        expect(state.volume, 0.8);
        expect(state.pitch, 1.2);
        expect(state.isSpeaking, true);
      });

      test('should be equatable', () {
        const state1 = VoiceReady(isListening: true);
        const state2 = VoiceReady(isListening: true);
        const state3 = VoiceReady(isListening: false);

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const state = VoiceReady(
          isListening: true,
          voiceOutputEnabled: true,
          language: 'en-US',
          speechRate: 0.5,
          volume: 1.0,
          pitch: 1.0,
          isSpeaking: false,
        );
        expect(state.props, [true, true, 'en-US', 0.5, 1.0, 1.0, false]);
      });

      test('should copy with new values', () {
        const state = VoiceReady(isListening: false);

        final copiedState = state.copyWith(
          isListening: true,
          speechRate: 1.5,
        );

        expect(copiedState.isListening, true);
        expect(copiedState.voiceOutputEnabled, false);
        expect(copiedState.speechRate, 1.5);
        expect(state.volume, 1.0);
      });

      test('should copy with partial values', () {
        const state = VoiceReady(
          isListening: true,
          isSpeaking: true,
          speechRate: 0.5,
        );

        final copiedState = state.copyWith(isSpeaking: false);

        expect(copiedState.isListening, true);
        expect(copiedState.isSpeaking, false);
        expect(copiedState.speechRate, 0.5);
      });
    });

    group('VoiceError', () {
      test('should create with error message', () {
        const errorMessage = 'Voice service error';
        const state = VoiceError(errorMessage);
        expect(state.message, errorMessage);
        expect(state.details, isNull);
      });

      test('should create with error message and details', () {
        const errorMessage = 'Voice service error';
        const details = 'Additional error details';
        const state = VoiceError(errorMessage, details: details);
        expect(state.message, errorMessage);
        expect(state.details, details);
      });

      test('should be equatable', () {
        const state1 = VoiceError('Error 1');
        const state2 = VoiceError('Error 1');
        const state3 = VoiceError('Error 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const errorMessage = 'Voice service error';
        const details = 'Additional error details';
        const state = VoiceError(errorMessage, details: details);
        expect(state.props, [errorMessage, details]);
      });
    });

    group('VoiceNotAvailable', () {
      test('should create with reason', () {
        const reason = 'Voice services not supported';
        const state = VoiceNotAvailable(reason);
        expect(state.reason, reason);
      });

      test('should be equatable', () {
        const state1 = VoiceNotAvailable('Reason 1');
        const state2 = VoiceNotAvailable('Reason 1');
        const state3 = VoiceNotAvailable('Reason 2');

        expect(state1, state2);
        expect(state1, isNot(state3));
      });

      test('should have correct props', () {
        const reason = 'Voice services not supported';
        const state = VoiceNotAvailable(reason);
        expect(state.props, [reason]);
      });
    });
  });
}
