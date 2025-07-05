import 'package:flutter_test/flutter_test.dart';

import '../../../../lib/features/voice/bloc/voice_event.dart';

void main() {
  group('VoiceEvent', () {
    group('StartListening', () {
      test('should be equatable', () {
        const event1 = StartListening();
        const event2 = StartListening();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = StartListening();
        expect(event.props, isEmpty);
      });
    });

    group('StopListening', () {
      test('should be equatable', () {
        const event1 = StopListening();
        const event2 = StopListening();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = StopListening();
        expect(event.props, isEmpty);
      });
    });

    group('VoiceInputReceived', () {
      test('should create with text', () {
        const text = 'Hello world';
        const event = VoiceInputReceived(text);
        expect(event.text, text);
      });

      test('should be equatable', () {
        const event1 = VoiceInputReceived('Text 1');
        const event2 = VoiceInputReceived('Text 1');
        const event3 = VoiceInputReceived('Text 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const text = 'Hello world';
        const event = VoiceInputReceived(text);
        expect(event.props, [text]);
      });
    });

    group('ToggleVoiceOutput', () {
      test('should create with enabled flag', () {
        const event = ToggleVoiceOutput(true);
        expect(event.enabled, true);
      });

      test('should be equatable', () {
        const event1 = ToggleVoiceOutput(true);
        const event2 = ToggleVoiceOutput(true);
        const event3 = ToggleVoiceOutput(false);

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = ToggleVoiceOutput(true);
        expect(event.props, [true]);
      });
    });

    group('SpeakText', () {
      test('should create with text', () {
        const text = 'Hello world';
        const event = SpeakText(text);
        expect(event.text, text);
      });

      test('should be equatable', () {
        const event1 = SpeakText('Text 1');
        const event2 = SpeakText('Text 1');
        const event3 = SpeakText('Text 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const text = 'Hello world';
        const event = SpeakText(text);
        expect(event.props, [text]);
      });
    });

    group('StopSpeaking', () {
      test('should be equatable', () {
        const event1 = StopSpeaking();
        const event2 = StopSpeaking();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = StopSpeaking();
        expect(event.props, isEmpty);
      });
    });

    group('UpdateVoiceSettings', () {
      test('should create with all parameters', () {
        const event = UpdateVoiceSettings(
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.2,
        );
        expect(event.language, 'en-US');
        expect(event.speechRate, 1.0);
        expect(event.volume, 0.8);
        expect(event.pitch, 1.2);
      });

      test('should create with partial parameters', () {
        const event = UpdateVoiceSettings(speechRate: 1.5);
        expect(event.language, isNull);
        expect(event.speechRate, 1.5);
        expect(event.volume, isNull);
        expect(event.pitch, isNull);
      });

      test('should be equatable', () {
        const event1 = UpdateVoiceSettings(speechRate: 1.0);
        const event2 = UpdateVoiceSettings(speechRate: 1.0);
        const event3 = UpdateVoiceSettings(speechRate: 1.5);

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const event = UpdateVoiceSettings(
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.2,
        );
        expect(event.props, ['en-US', 1.0, 0.8, 1.2]);
      });
    });

    group('InitializeVoiceServices', () {
      test('should be equatable', () {
        const event1 = InitializeVoiceServices();
        const event2 = InitializeVoiceServices();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = InitializeVoiceServices();
        expect(event.props, isEmpty);
      });
    });

    group('LoadVoiceSettings', () {
      test('should be equatable', () {
        const event1 = LoadVoiceSettings();
        const event2 = LoadVoiceSettings();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = LoadVoiceSettings();
        expect(event.props, isEmpty);
      });
    });

    group('SaveVoiceSettings', () {
      test('should be equatable', () {
        const event1 = SaveVoiceSettings();
        const event2 = SaveVoiceSettings();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = SaveVoiceSettings();
        expect(event.props, isEmpty);
      });
    });

    group('VoiceRecognitionError', () {
      test('should create with error message', () {
        const errorMessage = 'Speech recognition failed';
        const event = VoiceRecognitionError(errorMessage);
        expect(event.error, errorMessage);
      });

      test('should be equatable', () {
        const event1 = VoiceRecognitionError('Error 1');
        const event2 = VoiceRecognitionError('Error 1');
        const event3 = VoiceRecognitionError('Error 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const errorMessage = 'Speech recognition failed';
        const event = VoiceRecognitionError(errorMessage);
        expect(event.props, [errorMessage]);
      });
    });

    group('TTSError', () {
      test('should create with error message', () {
        const errorMessage = 'Text-to-speech failed';
        const event = TTSError(errorMessage);
        expect(event.error, errorMessage);
      });

      test('should be equatable', () {
        const event1 = TTSError('Error 1');
        const event2 = TTSError('Error 1');
        const event3 = TTSError('Error 2');

        expect(event1, event2);
        expect(event1, isNot(event3));
      });

      test('should have correct props', () {
        const errorMessage = 'Text-to-speech failed';
        const event = TTSError(errorMessage);
        expect(event.props, [errorMessage]);
      });
    });

    group('RetryVoiceInitialization', () {
      test('should be equatable', () {
        const event1 = RetryVoiceInitialization();
        const event2 = RetryVoiceInitialization();
        expect(event1, event2);
      });

      test('should have empty props', () {
        const event = RetryVoiceInitialization();
        expect(event.props, isEmpty);
      });
    });
  });
}
