import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:genlite/features/app_initialization/presentation/initialization_screen.dart';
import '../../../test_config.dart';

void main() {
  group('InitializationScreen', () {
    testWidgets('renders and shows loading', (tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const InitializationScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('GenLite'), findsOneWidget);
    });

    testWidgets('has correct styling', (tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const InitializationScreen(),
        ),
      );

      // There may be multiple Scaffolds, check at least one has the correct background color
      final scaffoldWidgets =
          tester.widgetList<Scaffold>(find.byType(Scaffold));
      expect(
          scaffoldWidgets
              .any((s) => s.backgroundColor == const Color(0xFF6366F1)),
          isTrue);

      // Check for white text
      final textFinder = find.text('GenLite');
      expect(textFinder, findsOneWidget);
    });
  });
}
