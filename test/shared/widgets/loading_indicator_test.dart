import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/widgets/loading_indicator.dart';
import '../../test_config.dart';
import '../../../lib/core/constants/app_constants.dart';

void main() {
  group('LoadingIndicator', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should render with default properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should render with custom message',
        (WidgetTester tester) async {
      const message = 'Loading...';
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(message: message),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should render with custom size', (WidgetTester tester) async {
      const size = 60.0;
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(size: size),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, equals(size));
      expect(sizedBox.height, equals(size));
    });

    testWidgets('should render with custom color', (WidgetTester tester) async {
      const color = Colors.red;
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(color: color),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      final valueColor =
          progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(color));
    });

    testWidgets('should center the content', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(),
        ),
      );

      final center = tester.widget<Center>(find.byType(Center));
      expect(center, isNotNull);
    });

    testWidgets('should use column layout', (WidgetTester tester) async {
      const message = 'Test message';
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(message: message),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(column.children.length, equals(3)); // SizedBox, SizedBox, Text
    });

    testWidgets('should apply theme text style', (WidgetTester tester) async {
      const message = 'Theme test';
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(message: message),
        ),
      );

      final text = tester.widget<Text>(find.text(message));
      expect(text.style, isNotNull);
      expect(text.textAlign, equals(TextAlign.center));
    });

    testWidgets('should handle null message gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(message: null),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should handle empty message', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingIndicator(message: ''),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });
  });

  group('LoadingOverlay', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    testWidgets('should show child when not loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: false,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator with message',
        (WidgetTester tester) async {
      const message = 'Processing...';
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            message: message,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
    });

    testWidgets('should use stack layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            child: Text('Child content'),
          ),
        ),
      );

      // Find all Stack widgets and check if any have the expected structure
      final stacks = find.byType(Stack);
      expect(stacks, findsAtLeastNWidgets(1));

      // Check that we have both child content and loading indicator
      expect(find.text('Child content'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should apply overlay background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            child: Text('Child content'),
          ),
        ),
      );

      // Find the overlay container and check its color property
      final containers = find.byType(Container);
      bool foundOverlayContainer = false;
      for (final element in containers.evaluate()) {
        final container = element.widget as Container;
        if (container.color == Color.fromARGB(77, 99, 102, 241)) {
          // AppConstants.primaryColor with 0.3 opacity
          foundOverlayContainer = true;
          break;
        }
      }
      expect(foundOverlayContainer, isTrue);
    });

    testWidgets('should not show overlay when not loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: false,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.text('Child content'), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('should handle state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: false,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsNothing);

      // Change to loading state
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            child: Text('Child content'),
          ),
        ),
      );

      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should handle complex child widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestConfig.createTestApp(
          const LoadingOverlay(
            isLoading: true,
            child: Column(
              children: [
                Text('First line'),
                Text('Second line'),
                Icon(Icons.star),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First line'), findsOneWidget);
      expect(find.text('Second line'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });
  });
}
