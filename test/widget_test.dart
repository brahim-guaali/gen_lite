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
  });
}
