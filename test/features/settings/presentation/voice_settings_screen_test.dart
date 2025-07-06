import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:genlite/features/settings/presentation/voice_settings_screen.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import '../../../test_config.dart';
import 'package:mocktail/mocktail.dart';

class MockVoiceBloc extends Mock implements VoiceBloc {}

void main() {
  group('VoiceSettingsScreen', () {
    late MockVoiceBloc mockVoiceBloc;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    setUp(() {
      mockVoiceBloc = MockVoiceBloc();
    });

    Widget createTestWidget() {
      return TestConfig.createTestApp(
        BlocProvider<VoiceBloc>.value(
          value: mockVoiceBloc,
          child: const VoiceSettingsScreen(),
        ),
      );
    }

    testWidgets('should render voice settings screen with header',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Settings'), findsOneWidget);
      expect(find.text('Voice Assistant'), findsOneWidget);
      expect(find.text('Configure voice input and output settings'),
          findsOneWidget);
    });

    testWidgets('should display voice status section',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Status'), findsOneWidget);
      expect(find.text('Speech Recognition'), findsOneWidget);
      expect(find.text('Text-to-Speech'), findsOneWidget);
      expect(find.text('Microphone Access'), findsOneWidget);
    });

    testWidgets('should display voice controls section',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Controls'), findsOneWidget);
    });

    testWidgets('should display voice preferences when ready',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Preferences'), findsOneWidget);
    });

    testWidgets('should display error section when voice error occurs',
        (WidgetTester tester) async {
      const errorState = VoiceError('Voice service unavailable');
      when(() => mockVoiceBloc.state).thenReturn(errorState);
      whenListen(mockVoiceBloc, Stream.value(errorState));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Error'), findsOneWidget);
      expect(find.text('Voice service unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should display not available section when voice not available',
        (WidgetTester tester) async {
      const notAvailableState =
          VoiceNotAvailable('Microphone permission denied');
      when(() => mockVoiceBloc.state).thenReturn(notAvailableState);
      whenListen(mockVoiceBloc, Stream.value(notAvailableState));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Not Available'), findsOneWidget);
      expect(find.text('Microphone permission denied'), findsOneWidget);
    });

    testWidgets('should display initializing status',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceInitializing());
      whenListen(mockVoiceBloc, Stream.value(const VoiceInitializing()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Initializing voice services...'), findsOneWidget);
    });

    testWidgets('should display ready status when voice is ready',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice services ready'), findsOneWidget);
    });

    testWidgets('should handle retry button press',
        (WidgetTester tester) async {
      const errorState = VoiceError('Voice service unavailable');
      when(() => mockVoiceBloc.state).thenReturn(errorState);
      whenListen(mockVoiceBloc, Stream.value(errorState));
      when(() => mockVoiceBloc.add(const RetryVoiceInitialization()))
          .thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(() => mockVoiceBloc.add(const RetryVoiceInitialization()))
          .called(1);
    });

    testWidgets('should have proper app bar', (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Voice Settings'), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
