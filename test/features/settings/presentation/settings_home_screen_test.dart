import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/settings/presentation/settings_home_screen.dart';
import '../../../test_config.dart';
import 'package:genlite/features/settings/presentation/agent_management_screen.dart';
import 'package:genlite/features/settings/presentation/voice_settings_screen.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';

void main() {
  group('SettingsHomeScreen', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render settings home screen with all sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      // Verify app bar
      expect(find.text('Settings'), findsOneWidget);

      // Verify header section
      expect(find.text('App Configuration'), findsOneWidget);
      expect(find.text('Customize your GenLite experience'), findsOneWidget);

      // Verify section headers
      expect(find.text('AI & Voice'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);

      // Verify settings cards
      expect(find.text('AI Agents'), findsOneWidget);
      expect(find.text('Voice Settings'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('About GenLite'), findsOneWidget);

      // Verify privacy notice
      expect(
          find.textContaining('All data is processed locally'), findsOneWidget);
    });

    testWidgets('should navigate to agent management screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      await tester.tap(find.text('AI Agents'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(AgentManagementScreen), findsOneWidget);
    });

    testWidgets('should navigate to voice settings screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      await tester.tap(find.text('Voice Settings'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(VoiceSettingsScreen), findsOneWidget);
    });

    testWidgets('should navigate to permissions screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      await tester.tap(find.text('Permissions'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(PermissionsScreen), findsOneWidget);
    });

    testWidgets('should navigate to about screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      await tester.tap(find.text('About GenLite'));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(AboutScreen), findsOneWidget);
    });

    testWidgets('should display correct card descriptions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      expect(
          find.text('Manage and customize AI personalities'), findsOneWidget);
      expect(find.text('Configure speech recognition and TTS'), findsOneWidget);
      expect(find.text('Manage app permissions and access'), findsOneWidget);
      expect(
          find.text('Version, license, and app information'), findsOneWidget);
    });

    testWidgets('should have proper visual hierarchy',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      // Verify cards are present
      expect(find.byType(Card), findsNWidgets(4));

      // Verify icons are present
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
    });
  });

  group('AboutScreen', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render about screen with app information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      // Verify app bar
      expect(find.text('About GenLite'), findsOneWidget);

      // Verify app header
      expect(find.text('GenLite'), findsOneWidget);
      expect(find.text('Version 2.0'), findsOneWidget);
      expect(
          find.text('A privacy-focused, offline AI assistant'), findsOneWidget);

      // Verify sections
      expect(find.text('Key Features'), findsOneWidget);
      expect(find.text('Technical Information'), findsOneWidget);

      // Verify feature cards
      expect(find.text('Privacy First'), findsOneWidget);
      expect(find.text('Offline Capable'), findsOneWidget);
      expect(find.text('AI Powered'), findsOneWidget);
      expect(find.text('License'), findsOneWidget);
      expect(find.text('Architecture'), findsOneWidget);

      // Verify privacy commitment
      expect(find.text('Privacy Commitment'), findsOneWidget);
      expect(
          find.textContaining('Your privacy is our priority'), findsOneWidget);
    });

    testWidgets('should display correct feature descriptions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      expect(find.text('All processing happens locally on your device'),
          findsOneWidget);
      expect(find.text('Works without internet connection'), findsOneWidget);
      expect(find.text('Powered by Google\'s Gemma language model'),
          findsOneWidget);
      expect(find.text('MIT License - Open Source'), findsOneWidget);
      expect(find.text('Clean Architecture with BLoC pattern'), findsOneWidget);
    });

    testWidgets('should have proper visual hierarchy in about screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      // Verify cards are present
      expect(find.byType(Card), findsNWidgets(5));

      // Verify icons are present
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.architecture), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
    });

    testWidgets('should display privacy notice correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      final privacyContainer = find.byType(Container).last;
      expect(privacyContainer, findsOneWidget);

      expect(find.textContaining('No information is sent to external servers'),
          findsOneWidget);
    });
  });
}
