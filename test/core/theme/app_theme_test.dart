import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/core/theme/app_theme.dart';
import '../../test_config.dart';

void main() {
  group('AppTheme', () {
    setUpAll(() async {
      await TestConfig.initialize();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group('lightTheme', () {
      test('should have correct brightness', () {
        expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
      });

      test('should use Material 3', () {
        expect(AppTheme.lightTheme.useMaterial3, isTrue);
      });

      test('should have correct color scheme', () {
        final colorScheme = AppTheme.lightTheme.colorScheme;
        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.tertiary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.error, isNotNull);
      });

      test('should have correct scaffold background color', () {
        expect(AppTheme.lightTheme.scaffoldBackgroundColor, isNotNull);
      });

      test('should have configured app bar theme', () {
        final appBarTheme = AppTheme.lightTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, isNotNull);
        expect(appBarTheme.foregroundColor, isNotNull);
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.centerTitle, isTrue);
        expect(appBarTheme.titleTextStyle, isNotNull);
      });

      test('should have configured card theme', () {
        final cardTheme = AppTheme.lightTheme.cardTheme;
        expect(cardTheme.color, isNotNull);
        expect(cardTheme.elevation, equals(2));
        expect(cardTheme.shadowColor, isNotNull);
        expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      });

      test('should have configured elevated button theme', () {
        final buttonTheme = AppTheme.lightTheme.elevatedButtonTheme;
        expect(buttonTheme.style, isNotNull);
      });

      test('should have configured input decoration theme', () {
        final inputTheme = AppTheme.lightTheme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, isNotNull);
        expect(inputTheme.border, isA<OutlineInputBorder>());
        expect(inputTheme.enabledBorder, isA<OutlineInputBorder>());
        expect(inputTheme.focusedBorder, isA<OutlineInputBorder>());
        expect(inputTheme.contentPadding, isNotNull);
      });

      test('should have configured text theme', () {
        final textTheme = AppTheme.lightTheme.textTheme;
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
      });

      test('should have valid theme configuration', () {
        expect(AppTheme.lightTheme, isNotNull);
        expect(AppTheme.lightTheme.colorScheme, isNotNull);
        expect(AppTheme.lightTheme.textTheme, isNotNull);
      });
    });

    group('darkTheme', () {
      test('should have correct brightness', () {
        expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
      });

      test('should use Material 3', () {
        expect(AppTheme.darkTheme.useMaterial3, isTrue);
      });

      test('should have correct color scheme', () {
        final colorScheme = AppTheme.darkTheme.colorScheme;
        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.primary, isNotNull);
        expect(colorScheme.secondary, isNotNull);
        expect(colorScheme.tertiary, isNotNull);
        expect(colorScheme.surface, isNotNull);
        expect(colorScheme.error, isNotNull);
      });

      test('should have correct scaffold background color', () {
        expect(AppTheme.darkTheme.scaffoldBackgroundColor, isNotNull);
      });

      test('should have configured app bar theme', () {
        final appBarTheme = AppTheme.darkTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, isNotNull);
        expect(appBarTheme.foregroundColor, isNotNull);
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.centerTitle, isTrue);
        expect(appBarTheme.titleTextStyle, isNotNull);
      });

      test('should have configured card theme', () {
        final cardTheme = AppTheme.darkTheme.cardTheme;
        expect(cardTheme.color, isNotNull);
        expect(cardTheme.elevation, equals(2));
        expect(cardTheme.shadowColor, isNotNull);
        expect(cardTheme.shape, isA<RoundedRectangleBorder>());
      });

      test('should have configured elevated button theme', () {
        final buttonTheme = AppTheme.darkTheme.elevatedButtonTheme;
        expect(buttonTheme.style, isNotNull);
      });

      test('should have configured input decoration theme', () {
        final inputTheme = AppTheme.darkTheme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, isNotNull);
        expect(inputTheme.border, isA<OutlineInputBorder>());
        expect(inputTheme.enabledBorder, isA<OutlineInputBorder>());
        expect(inputTheme.focusedBorder, isA<OutlineInputBorder>());
        expect(inputTheme.contentPadding, isNotNull);
      });

      test('should have configured text theme', () {
        final textTheme = AppTheme.darkTheme.textTheme;
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
      });

      test('should have valid dark theme configuration', () {
        expect(AppTheme.darkTheme, isNotNull);
        expect(AppTheme.darkTheme.colorScheme, isNotNull);
        expect(AppTheme.darkTheme.textTheme, isNotNull);
      });
    });

    group('Theme Comparison', () {
      test('light and dark themes should have different brightness', () {
        expect(AppTheme.lightTheme.brightness,
            isNot(equals(AppTheme.darkTheme.brightness)));
      });

      test(
          'light and dark themes should have different scaffold background colors',
          () {
        expect(
          AppTheme.lightTheme.scaffoldBackgroundColor,
          isNot(equals(AppTheme.darkTheme.scaffoldBackgroundColor)),
        );
      });

      test('light and dark themes should have different surface colors', () {
        expect(
          AppTheme.lightTheme.colorScheme.surface,
          isNot(equals(AppTheme.darkTheme.colorScheme.surface)),
        );
      });

      test('both themes should have same primary color', () {
        expect(
          AppTheme.lightTheme.colorScheme.primary,
          equals(AppTheme.darkTheme.colorScheme.primary),
        );
      });

      test('both themes should have same error color', () {
        expect(
          AppTheme.lightTheme.colorScheme.error,
          equals(AppTheme.darkTheme.colorScheme.error),
        );
      });
    });

    group('Theme Consistency', () {
      test('light theme should have consistent color scheme', () {
        final colorScheme = AppTheme.lightTheme.colorScheme;
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
      });

      test('dark theme should have consistent color scheme', () {
        final colorScheme = AppTheme.darkTheme.colorScheme;
        expect(colorScheme.onPrimary, isNotNull);
        expect(colorScheme.onSecondary, isNotNull);
        expect(colorScheme.onSurface, isNotNull);
      });

      test('both themes should have consistent button styling', () {
        final lightButtonStyle = AppTheme.lightTheme.elevatedButtonTheme.style;
        final darkButtonStyle = AppTheme.darkTheme.elevatedButtonTheme.style;

        expect(lightButtonStyle, isNotNull);
        expect(darkButtonStyle, isNotNull);
      });

      test('both themes should have consistent input styling', () {
        final lightInputTheme = AppTheme.lightTheme.inputDecorationTheme;
        final darkInputTheme = AppTheme.darkTheme.inputDecorationTheme;

        expect(lightInputTheme.filled, equals(darkInputTheme.filled));
        expect(lightInputTheme.contentPadding,
            equals(darkInputTheme.contentPadding));
      });
    });
  });
}
