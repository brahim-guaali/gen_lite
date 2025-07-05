import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

void main() {
  group('VoiceBloc', () {
    late VoiceBloc voiceBloc;

    setUp(() {
      voiceBloc = VoiceBloc();
    });

    tearDown(() {
      voiceBloc.close();
    });

    test('initial state is VoiceInitial', () {
      expect(voiceBloc.state, const VoiceInitial());
    });

    group('VoiceInputReceived', () {
      blocTest<VoiceBloc, VoiceState>(
        'emits [VoiceProcessing, VoiceReady] when voice input is received',
        build: () => VoiceBloc(),
        act: (bloc) => bloc.add(const VoiceInputReceived('Hello world')),
        expect: () => [
          const VoiceProcessing(),
          isA<VoiceReady>().having(
            (state) => state.isListening,
            'isListening',
            false,
          ),
        ],
      );
    });

    group('ToggleVoiceOutput', () {
      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceReady with voiceOutputEnabled: true when enabling voice output',
        build: () => VoiceBloc(),
        act: (bloc) => bloc.add(const ToggleVoiceOutput(true)),
        expect: () => [
          isA<VoiceReady>().having(
            (state) => state.voiceOutputEnabled,
            'voiceOutputEnabled',
            true,
          ),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceReady with voiceOutputEnabled: false when disabling voice output',
        build: () => VoiceBloc(),
        act: (bloc) => bloc.add(const ToggleVoiceOutput(false)),
        expect: () => [
          isA<VoiceReady>().having(
            (state) => state.voiceOutputEnabled,
            'voiceOutputEnabled',
            false,
          ),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError when voice recognition error occurs',
        build: () => VoiceBloc(),
        act: (bloc) =>
            bloc.add(const VoiceRecognitionError('Recognition failed')),
        expect: () => [
          isA<VoiceError>().having(
            (state) => state.message,
            'message',
            'Voice recognition error: Recognition failed',
          ),
        ],
      );

      blocTest<VoiceBloc, VoiceState>(
        'emits VoiceError when TTS error occurs',
        build: () => VoiceBloc(),
        act: (bloc) => bloc.add(const TTSError('TTS failed')),
        expect: () => [
          isA<VoiceError>().having(
            (state) => state.message,
            'message',
            'TTS error: TTS failed',
          ),
        ],
      );
    });
  });
}
