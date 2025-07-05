import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

void main() {
  group('VoiceBloc', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('initial state is VoiceInitial', () {
      final voiceBloc = VoiceBloc();
      expect(voiceBloc.state, isA<VoiceInitial>());
    });

    test('VoiceRecognitionError emits VoiceError', () async {
      final voiceBloc = VoiceBloc();

      expectLater(
        voiceBloc.stream,
        emitsInOrder([
          isA<VoiceError>(),
        ]),
      );

      voiceBloc.add(const VoiceRecognitionError('Test error'));
    });

    test('TTSError emits VoiceError', () async {
      final voiceBloc = VoiceBloc();

      expectLater(
        voiceBloc.stream,
        emitsInOrder([
          isA<VoiceError>(),
        ]),
      );

      voiceBloc.add(const TTSError('Test TTS error'));
    });
  });
}
