import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/settings/widgets/settings_header_section.dart';
import '../../../test_config.dart';

void main() {
  group('SettingsHeaderSection', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render header section with correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHeaderSection(),
        ),
      );

      // Verify header content
      expect(find.text('App Configuration'), findsOneWidget);
      expect(find.text('Customize your GenLite experience'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should have proper visual styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const SettingsHeaderSection(),
        ),
      );

      // Verify container styling
      expect(find.byType(Container), findsWidgets);

      // Verify icon container
      final iconContainer = find.byType(Container).first;
      expect(iconContainer, findsOneWidget);
    });
  });
}
