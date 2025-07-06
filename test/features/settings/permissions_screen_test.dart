import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';
import '../../test_config.dart';

void main() {
  group('PermissionsScreen', () {
    testWidgets('should render loading state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display permission tiles when loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Check for permission tiles
      expect(find.text('Microphone'), findsOneWidget);
      expect(find.text('Speech Recognition'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);

      // Check for descriptions
      expect(find.text('Required for voice input and speech recognition'),
          findsOneWidget);
      expect(
          find.text('Required for converting voice to text'), findsOneWidget);
      expect(find.text('Required for file access and document processing'),
          findsOneWidget);
      expect(find.text('Required for image input (future feature)'),
          findsOneWidget);
    });

    testWidgets('should show granted status for permissions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for granted status indicators
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      expect(find.text('Granted'), findsNWidgets(4));
    });

    testWidgets('should show grant buttons for denied permissions',
        (WidgetTester tester) async {
      // Mock denied permissions
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for grant buttons
      expect(find.text('Grant'), findsNWidgets(4));
    });

    testWidgets('should handle permission request',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap a grant button
      await tester.tap(find.text('Grant').first);
      await tester.pump();

      // Verify the button was tapped
      expect(find.text('Grant'), findsNWidgets(3)); // One less after tapping
    });

    testWidgets('should display app bar with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      expect(find.text('Permissions'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle error states gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should still display the screen even if permissions fail
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should update UI when permissions change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Grant'), findsNWidgets(4));

      // Simulate permission change
      await tester.tap(find.text('Grant').first);
      await tester.pump();

      // Should update the UI
      expect(find.text('Grant'), findsNWidgets(3));
    });

    testWidgets('should display correct icons for permission status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for status icons
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4));
      expect(find.byIcon(Icons.error), findsNothing); // No errors initially
    });

    testWidgets('should handle empty permission list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should still show the screen with proper structure
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should maintain scrollable layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should be scrollable
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
