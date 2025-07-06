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

    testWidgets('should render settings home screen with all items',
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

      // Verify settings items
      expect(find.text('AI Agents'), findsOneWidget);
      expect(find.text('Voice Settings'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('About GenLite'), findsOneWidget);

      // Verify privacy notice
      expect(
          find.textContaining('All data is processed locally'), findsOneWidget);
    });

    testWidgets('should display correct item descriptions',
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

      // Verify main container is present
      expect(find.byType(Container), findsWidgets);

      // Verify icons are present
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
    });

    testWidgets('should have tappable settings items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      // Verify all items are tappable
      expect(find.byType(InkWell), findsNWidgets(4));
    });

    testWidgets('should have chevron icons for navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHomeScreen(),
        ),
      );

      // Verify chevron icons are present
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));
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
      expect(find.text('App Information'), findsOneWidget);

      // Verify feature cards
      expect(find.text('Privacy First'), findsOneWidget);
      expect(find.text('Offline Capable'), findsOneWidget);
      expect(find.text('AI Powered'), findsOneWidget);
      expect(find.text('Voice Interaction'), findsOneWidget);
      expect(find.text('File Processing'), findsOneWidget);
      expect(find.text('License'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);

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
      expect(
          find.text('Speak naturally with your AI assistant'), findsOneWidget);
      expect(find.text('Upload and analyze documents easily'), findsOneWidget);
      expect(find.text('MIT License - Open Source'), findsOneWidget);
      expect(find.text('2.0.0'), findsOneWidget);
    });

    testWidgets('should have proper visual hierarchy in about screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      // Verify cards are present (5 features + 2 app info)
      expect(find.byType(Card), findsNWidgets(7));

      // Verify icons are present
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
      expect(find.byIcon(Icons.offline_bolt), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      expect(find.byIcon(Icons.voice_chat), findsOneWidget);
      expect(find.byIcon(Icons.file_upload), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
      expect(find.byIcon(Icons.verified_user), findsOneWidget);
    });

    testWidgets('should display privacy notice correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const AboutScreen(),
        ),
      );

      expect(find.textContaining('No information is sent to external servers'),
          findsOneWidget);
    });
  });
}
