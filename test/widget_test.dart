// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/main.dart';
import 'package:genlite/core/constants/app_constants.dart';

void main() {
  group('GenLite App', () {
    testWidgets('should render app with correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GenLiteApp());

      // Verify app title is displayed
      expect(find.text(AppConstants.appName), findsOneWidget);
    });

    testWidgets('should show welcome message initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GenLiteApp());

      // Verify welcome message is displayed
      expect(find.text('Welcome to GenLite'), findsOneWidget);
      expect(find.text('Your offline AI assistant is ready to help.'),
          findsOneWidget);
    });

    testWidgets('should have message input field', (WidgetTester tester) async {
      await tester.pumpWidget(const GenLiteApp());

      // Verify message input is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Type your message...'), findsOneWidget);
    });
  });
}
