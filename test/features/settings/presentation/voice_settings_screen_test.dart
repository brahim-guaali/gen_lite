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

      // Check that error section is displayed
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

      // Check that not available section is displayed
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
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

      // Find the retry button by text
      final retryButton = find.text('Retry');
      expect(retryButton, findsOneWidget);

      // Scroll to make sure the button is visible
      await tester.ensureVisible(retryButton);
      await tester.pumpAndSettle();

      await tester.tap(retryButton);
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

    testWidgets('should display voice output toggle',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Output'), findsOneWidget);
      expect(find.text('Read AI responses aloud'), findsOneWidget);
    });

    testWidgets('should display voice ready status indicator',
        (WidgetTester tester) async {
      when(() => mockVoiceBloc.state).thenReturn(const VoiceReady());
      whenListen(mockVoiceBloc, Stream.value(const VoiceReady()));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice Ready'), findsOneWidget);
      expect(find.text('Voice services are active and ready to use'),
          findsOneWidget);
    });

    testWidgets('should display error status in header when voice error occurs',
        (WidgetTester tester) async {
      const errorState = VoiceError('Voice service unavailable');
      when(() => mockVoiceBloc.state).thenReturn(errorState);
      whenListen(mockVoiceBloc, Stream.value(errorState));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice error occurred'), findsOneWidget);
    });

    testWidgets(
        'should display not available status in header when voice not available',
        (WidgetTester tester) async {
      const notAvailableState =
          VoiceNotAvailable('Microphone permission denied');
      when(() => mockVoiceBloc.state).thenReturn(notAvailableState);
      whenListen(mockVoiceBloc, Stream.value(notAvailableState));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Voice not available'), findsOneWidget);
    });
  });
}
