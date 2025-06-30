import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/shared/widgets/message_bubble.dart';
import 'package:genlite/shared/models/message.dart';

void main() {
  group('MessageBubble', () {
    testWidgets('should render user message correctly',
        (WidgetTester tester) async {
      final userMessage = Message.create(
        content: 'Hello, this is a user message',
        role: MessageRole.user,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: userMessage),
          ),
        ),
      );

      // Verify user message is displayed
      expect(find.text('Hello, this is a user message'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);

      // Verify user avatar is present
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Verify AI avatar is not present
      expect(find.byIcon(Icons.smart_toy), findsNothing);
    });

    testWidgets('should render AI message correctly',
        (WidgetTester tester) async {
      final aiMessage = Message.create(
        content: 'Hello! I am an AI assistant.',
        role: MessageRole.assistant,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: aiMessage),
          ),
        ),
      );

      // Verify AI message is displayed
      expect(find.text('Hello! I am an AI assistant.'), findsOneWidget);
      expect(find.text('GenLite'), findsOneWidget);

      // Verify AI avatar is present
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);

      // Verify user avatar is not present
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('should handle empty messages gracefully',
        (WidgetTester tester) async {
      final emptyMessage = Message.create(
        content: '',
        role: MessageRole.user,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: emptyMessage),
          ),
        ),
      );

      // Verify widget renders without errors
      expect(find.byType(MessageBubble), findsOneWidget);
    });
  });
}
