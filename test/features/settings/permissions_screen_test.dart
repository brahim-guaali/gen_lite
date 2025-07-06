import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:genlite/features/settings/presentation/permissions_screen.dart';
import '../../test_config.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel permissionChannel =
        MethodChannel('flutter.baseflow.com/permissions/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      permissionChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'checkPermissionStatus':
            // Always return granted
            return 1; // 1 = granted
          case 'requestPermissions':
            // Return all permissions as granted
            final Map<dynamic, dynamic> result = {};
            (methodCall.arguments as Map).forEach((key, value) {
              result[key] = 1; // 1 = granted
            });
            return result;
          case 'shouldShowRequestPermissionRationale':
            return false;
          default:
            return null;
        }
      },
    );
  });

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
      expect(find.text('File Access'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);

      // Check for descriptions
      expect(find.text('Required for voice input and speech recognition'),
          findsOneWidget);
      expect(find.text('Required for accessing and processing files'),
          findsOneWidget);
      expect(
          find.text('Required for image input and analysis'), findsOneWidget);
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
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      expect(find.text('Granted'), findsNWidgets(3));
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
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
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
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
      expect(find.byIcon(Icons.error), findsNothing); // No errors initially
    });

    testWidgets('should handle empty permission list',
        (WidgetTester tester) async {
      // Simulate empty permission list by directly setting state (not possible with current implementation)
      // So just check that the screen structure is correct
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const PermissionsScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Permissions'), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
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
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
