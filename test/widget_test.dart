// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/main.dart';
import 'test_config.dart';
import 'package:genlite/features/chat/presentation/chat_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_bloc.dart';
import 'package:genlite/features/chat/bloc/chat_states.dart';
import 'package:genlite/features/settings/bloc/agent_bloc.dart';
import 'package:genlite/features/settings/bloc/agent_states.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';

void main() {
  group('GenLite App', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render app with correct title',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const GenLiteApp());

      // Wait for the app to initialize
      await tester.pumpAndSettle();

      // Verify that the app title is displayed
      expect(find.text('Welcome to GenLite'), findsOneWidget);
    });

    testWidgets('should show onboarding initially',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const GenLiteApp());

      // Wait for the app to initialize
      await tester.pumpAndSettle();

      // Verify that onboarding is shown initially
      expect(find.text('Welcome to GenLite'), findsOneWidget);
    });

    testWidgets('should have onboarding flow', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const GenLiteApp());

      // Wait for the app to initialize
      await tester.pumpAndSettle();

      // Verify onboarding elements are present
      expect(find.text('Welcome to GenLite'), findsOneWidget);
      expect(find.text('Your Personal Offline AI Assistant'), findsOneWidget);
    });

    testWidgets('should handle app initialization',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const GenLiteApp());

      // Wait for the app to initialize
      await tester.pumpAndSettle();

      // Verify app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Chat screen is ready to start immediately (no start button)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatBloc>(
                create: (_) => ChatBloc()..emit(ChatInitial()),
              ),
              BlocProvider<AgentBloc>(
                create: (_) => AgentBloc()..emit(AgentInitial()),
              ),
              BlocProvider<VoiceBloc>(
                create: (_) => VoiceBloc()..emit(VoiceInitial()),
              ),
            ],
            child: const ChatScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not find the start button
      expect(find.text('Start New Conversation'), findsNothing);
      // Should find the message input field
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
