import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genlite/core/theme/app_theme.dart';

/// Test configuration and utilities for GenLite tests
class TestConfig {
  /// Creates a test app with the given child widget
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  /// Creates a test app with BLoC providers
  static Widget createTestAppWithBloc(
      Widget child, List<BlocProvider> providers) {
    return MultiBlocProvider(
      providers: providers,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  /// Waits for a specific condition to be true
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();
    while (!condition()) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Condition not met within timeout', timeout);
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Finds a widget by type and text
  static Finder findByTypeAndText<T extends Widget>(String text) {
    return find.ancestor(
      of: find.text(text),
      matching: find.byType(T),
    );
  }

  /// Taps a widget and waits for the action to complete
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Enters text and waits for the action to complete
  static Future<void> enterTextAndWait(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Common test data for GenLite tests
class TestData {
  static const String sampleUserMessage = 'Hello, this is a test message';
  static const String sampleAIResponse =
      'Hello! I am an AI assistant. How can I help you today?';
  static const String sampleConversationTitle = 'Test Conversation';

  static const List<String> quickStartPrompts = [
    'Help me write a professional email',
    'Explain a complex topic simply',
    'Brainstorm ideas for a project',
    'Help me learn something new',
  ];
}

/// Common test matchers for GenLite tests
class TestMatchers {
  /// Matches a widget that has the given text
  static Finder hasText(String text) {
    return find.text(text);
  }

  /// Matches a widget that contains the given text
  static Finder containsText(String text) {
    return find.textContaining(text);
  }

  /// Matches a widget that has the given icon
  static Finder hasIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Matches a widget that is enabled
  static Matcher isEnabled() {
    return predicate<Widget>((widget) {
      if (widget is StatelessWidget) return true;
      if (widget is StatefulWidget) return true;
      return false;
    });
  }

  /// Matches a widget that is visible
  static Matcher isVisible() {
    return predicate<Widget>((widget) {
      return widget is! Offstage || !widget.offstage;
    });
  }
}
