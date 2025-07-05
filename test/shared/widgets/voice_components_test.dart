import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genlite/shared/widgets/voice_components.dart';
import 'package:genlite/features/voice/bloc/voice_bloc.dart';
import 'package:genlite/features/voice/bloc/voice_event.dart';
import 'package:genlite/features/voice/bloc/voice_state.dart';
import '../../test_config.dart';

void main() {
  group('Voice Components', () {
    late VoiceBloc voiceBloc;

    setUp(() {
      TestConfig.initialize();
      voiceBloc = VoiceBloc();
    });

    tearDown(() {
      voiceBloc.close();
      TestConfig.cleanup();
    });

    group('VoiceInputButton', () {
      testWidgets('renders microphone icon when not listening',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceInputButton(
              onVoiceInput: null,
            ),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.byIcon(Icons.mic), findsOneWidget);
        expect(find.byIcon(Icons.mic_off), findsNothing);
      });

      testWidgets('renders stop icon when listening',
          (WidgetTester tester) async {
        // Set up listening state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: true,
          isListening: true,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceInputButton(
              onVoiceInput: null,
            ),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.byIcon(Icons.stop), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsNothing);
      });

      testWidgets('calls onVoiceInput callback when voice input is received',
          (WidgetTester tester) async {
        String? receivedText;

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            VoiceInputButton(
              onVoiceInput: (text) {
                receivedText = text;
              },
            ),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        // Simulate voice input received
        voiceBloc.add(const VoiceInputReceived('Hello world'));
        await tester.pump();

        expect(receivedText, equals('Hello world'));
      });

      testWidgets('shows loading indicator when processing',
          (WidgetTester tester) async {
        // Set up processing state
        voiceBloc.emit(const VoiceProcessing());

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceInputButton(
              onVoiceInput: null,
            ),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('VoiceOutputToggle', () {
      testWidgets('renders toggle switch with correct initial state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceOutputToggle(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.byType(Switch), findsOneWidget);
        expect(find.text('Voice Output'), findsOneWidget);
      });

      testWidgets('shows enabled state when voice output is on',
          (WidgetTester tester) async {
        // Set up enabled state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: true,
          isListening: false,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceOutputToggle(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isTrue);
      });

      testWidgets('shows disabled state when voice output is off',
          (WidgetTester tester) async {
        // Set up disabled state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: false,
          isListening: false,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.0,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceOutputToggle(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        final switchWidget = tester.widget<Switch>(find.byType(Switch));
        expect(switchWidget.value, isFalse);
      });

      testWidgets('toggles voice output when switch is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceOutputToggle(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        // Tap the switch
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Verify that ToggleVoiceOutput event was added
        expect(voiceBloc.state, isA<VoiceReady>());
      });
    });

    group('VoiceSettingsPanel', () {
      testWidgets('renders all voice settings controls',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceSettingsPanel(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Voice Settings'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Speech Rate'), findsOneWidget);
        expect(find.text('Volume'), findsOneWidget);
        expect(find.text('Pitch'), findsOneWidget);
      });

      testWidgets('shows current voice settings values',
          (WidgetTester tester) async {
        // Set up voice ready state with specific settings
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: true,
          isListening: false,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.2,
          volume: 0.7,
          pitch: 1.1,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceSettingsPanel(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        // Verify that the settings are displayed
        expect(find.text('en-US'), findsOneWidget);
        expect(find.text('1.2'), findsOneWidget);
        expect(find.text('0.7'), findsOneWidget);
        expect(find.text('1.1'), findsOneWidget);
      });

      testWidgets('shows error message when voice is not available',
          (WidgetTester tester) async {
        // Set up not available state
        voiceBloc.emit(const VoiceNotAvailable('No microphone available'));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceSettingsPanel(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Voice features not available'), findsOneWidget);
        expect(find.text('No microphone available'), findsOneWidget);
      });

      testWidgets('shows error message when voice service has error',
          (WidgetTester tester) async {
        // Set up error state
        voiceBloc.emit(const VoiceError('Voice service failed'));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceSettingsPanel(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Voice service failed'), findsOneWidget);
      });
    });

    group('Voice Status Indicator', () {
      testWidgets('shows listening indicator when voice is active',
          (WidgetTester tester) async {
        // Set up listening state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: true,
          isListening: true,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceStatusIndicator(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Listening'), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('shows voice on indicator when voice output is enabled',
          (WidgetTester tester) async {
        // Set up voice output enabled state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: true,
          isListening: false,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.8,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceStatusIndicator(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Voice On'), findsOneWidget);
        expect(find.byIcon(Icons.volume_up), findsOneWidget);
      });

      testWidgets('shows nothing when voice is not active',
          (WidgetTester tester) async {
        // Set up inactive state
        voiceBloc.emit(const VoiceReady(
          voiceOutputEnabled: false,
          isListening: false,
          isSpeaking: false,
          language: 'en-US',
          speechRate: 1.0,
          volume: 0.0,
          pitch: 1.0,
        ));

        await tester.pumpWidget(
          TestConfig.createTestAppWithBloc(
            const VoiceStatusIndicator(),
            [
              BlocProvider<VoiceBloc>.value(value: voiceBloc),
            ],
          ),
        );

        expect(find.text('Listening'), findsNothing);
        expect(find.text('Voice On'), findsNothing);
      });
    });
  });
}
