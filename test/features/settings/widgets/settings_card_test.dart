import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/features/settings/widgets/settings_card.dart';
import '../../../test_config.dart';

void main() {
  group('SettingsCard', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render settings card with correct content',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        TestConfig.createTestApp(
          SettingsCard(
            icon: Icons.settings,
            title: 'Test Settings',
            subtitle: 'Test description',
            color: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Verify card content
      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        TestConfig.createTestApp(
          SettingsCard(
            icon: Icons.settings,
            title: 'Test Settings',
            subtitle: 'Test description',
            color: Colors.blue,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Verify tap callback was called
      expect(tapped, isTrue);
    });

    testWidgets('should have proper visual styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          SettingsCard(
            icon: Icons.settings,
            title: 'Test Settings',
            subtitle: 'Test description',
            color: Colors.blue,
            onTap: () {},
          ),
        ),
      );

      // Verify card styling
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });
  });
}
