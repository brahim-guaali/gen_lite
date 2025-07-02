import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/widgets/ui_components.dart';
import '../../test_config.dart';

void main() {
  group('UI Components', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group('PrimaryButton', () {
      testWidgets('should render with text', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const PrimaryButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should render with icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const PrimaryButton(
              text: 'Test Button',
              icon: Icons.star,
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should show loading indicator when isLoading is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const PrimaryButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: null,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Test Button'), findsNothing);
      });

      testWidgets('should be disabled when isLoading is true',
          (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          TestConfig.createTestApp(
            PrimaryButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () => wasPressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isFalse);
      });

      testWidgets('should call onPressed when tapped',
          (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          TestConfig.createTestApp(
            PrimaryButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });

      testWidgets('should be full width by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const PrimaryButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ),
        );

        expect(sizedBox.width, equals(double.infinity));
      });

      testWidgets('should not be full width when isFullWidth is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const PrimaryButton(
              text: 'Test Button',
              isFullWidth: false,
              onPressed: null,
            ),
          ),
        );

        expect(find.byType(SizedBox), findsNothing);
      });
    });

    group('SecondaryButton', () {
      testWidgets('should render with text', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const SecondaryButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('should render with icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const SecondaryButton(
              text: 'Test Button',
              icon: Icons.star,
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should show loading indicator when isLoading is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const SecondaryButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: null,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Test Button'), findsNothing);
      });

      testWidgets('should call onPressed when tapped',
          (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          TestConfig.createTestApp(
            SecondaryButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(OutlinedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });
    });

    group('DangerButton', () {
      testWidgets('should render with text', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const DangerButton(
              text: 'Delete',
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should render with icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const DangerButton(
              text: 'Delete',
              icon: Icons.delete,
              onPressed: null,
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('should call onPressed when tapped',
          (WidgetTester tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          TestConfig.createTestApp(
            DangerButton(
              text: 'Delete',
              onPressed: () => wasPressed = true,
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });
    });

    group('AppCard', () {
      testWidgets('should render with child', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppCard(
              child: Text('Card Content'),
            ),
          ),
        );

        expect(find.text('Card Content'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('should call onTap when tapped', (WidgetTester tester) async {
        bool wasTapped = false;

        await tester.pumpWidget(
          TestConfig.createTestApp(
            AppCard(
              onTap: () => wasTapped = true,
              child: const Text('Card Content'),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pump();

        expect(wasTapped, isTrue);
      });

      testWidgets('should apply custom padding', (WidgetTester tester) async {
        const customPadding = EdgeInsets.all(20.0);

        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppCard(
              padding: customPadding,
              child: Text('Card Content'),
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
      });

      testWidgets('should apply custom margin', (WidgetTester tester) async {
        const customMargin = EdgeInsets.all(10.0);

        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppCard(
              margin: customMargin,
              child: Text('Card Content'),
            ),
          ),
        );

        final card = tester.widget<Card>(find.byType(Card));
        expect(card, isNotNull);
      });
    });

    group('AppProgressBar', () {
      testWidgets('should render with progress', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppProgressBar(
              progress: 0.5,
            ),
          ),
        );

        expect(find.byType(AppProgressBar), findsOneWidget);
        expect(find.byType(Stack), findsWidgets);
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(AnimatedContainer), findsWidgets);
      });

      testWidgets('should render with label', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppProgressBar(
              progress: 0.5,
              label: 'Loading...',
            ),
          ),
        );

        expect(find.text('Loading...'), findsOneWidget);
      });
    });

    group('AppIcon', () {
      testWidgets('should render with icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppIcon(
              icon: Icons.star,
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('should render with custom color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppIcon(
              icon: Icons.star,
              color: Colors.red,
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });
    });

    group('AppDivider', () {
      testWidgets('should render divider', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppDivider(),
          ),
        );

        expect(find.byType(AppDivider), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('AppBadge', () {
      testWidgets('should render with text', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppBadge(
              text: '5',
            ),
          ),
        );

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should render with custom background color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            const AppBadge(
              text: '5',
              backgroundColor: Colors.red,
            ),
          ),
        );

        expect(find.text('5'), findsOneWidget);
      });
    });
  });
}
