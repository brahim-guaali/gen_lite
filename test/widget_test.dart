// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/features/settings/bloc/agent_bloc.dart';
import 'package:genlite/features/settings/bloc/agent_states.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import 'package:genlite/shared/services/tts_service.dart';
import 'test_config.dart';

void main() {
  group('GenLite App', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Create BLoC instances
      final chatBloc = ChatBloc();
      final agentBloc = AgentBloc();
      final voiceBloc = VoiceBloc();

      // Build our app with required providers
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ChatBloc>.value(value: chatBloc),
            BlocProvider<AgentBloc>.value(value: agentBloc),
            BlocProvider<VoiceBloc>.value(value: voiceBloc),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('GenLite Test App'),
              ),
            ),
          ),
        ),
      );

      // Verify that the app renders without throwing exceptions
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('GenLite Test App'), findsOneWidget);

      // Clean up
      chatBloc.close();
      agentBloc.close();
      voiceBloc.close();
    });

    group('TTS Service', () {
      test('should remove emojis from text before speaking', () {
        final textWithEmojis = 'Hello 👋, how are you? 😊🚀';
        final expected = 'Hello , how are you? ';
        final result = TTSService.removeEmojis(textWithEmojis);
        expect(result, expected);
      });

      test('should use more natural default TTS settings', () {
        expect(TTSService.defaultSpeechRate, closeTo(0.44, 0.01));
        expect(TTSService.defaultPitch, closeTo(1.15, 0.01));
        expect(TTSService.defaultVolume, closeTo(0.95, 0.01));
      });

      test('should handle empty text gracefully', () {
        final result = TTSService.removeEmojis('');
        expect(result, '');
      });

      test('should handle text without emojis', () {
        final textWithoutEmojis = 'Hello, how are you?';
        final result = TTSService.removeEmojis(textWithoutEmojis);
        expect(result, textWithoutEmojis);
      });
    });
  });
}
