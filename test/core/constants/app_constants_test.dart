import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genlite/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have valid app information', () {
      expect(AppConstants.appName, isNotEmpty);
      expect(AppConstants.appVersion, isNotEmpty);
      expect(AppConstants.appDescription, isNotEmpty);
    });

    test('should have valid colors', () {
      expect(AppConstants.primaryColor, isA<Color>());
      expect(AppConstants.secondaryColor, isA<Color>());
      expect(AppConstants.accentColor, isA<Color>());
      expect(AppConstants.backgroundColor, isA<Color>());
      expect(AppConstants.surfaceColor, isA<Color>());
      expect(AppConstants.errorColor, isA<Color>());
      expect(AppConstants.successColor, isA<Color>());
      expect(AppConstants.warningColor, isA<Color>());
    });

    test('should have valid spacing values', () {
      expect(AppConstants.paddingSmall, isA<double>());
      expect(AppConstants.paddingMedium, isA<double>());
      expect(AppConstants.paddingLarge, isA<double>());
      expect(AppConstants.paddingXLarge, isA<double>());

      expect(AppConstants.paddingSmall, greaterThan(0));
      expect(
          AppConstants.paddingMedium, greaterThan(AppConstants.paddingSmall));
      expect(
          AppConstants.paddingLarge, greaterThan(AppConstants.paddingMedium));
      expect(
          AppConstants.paddingXLarge, greaterThan(AppConstants.paddingLarge));
    });

    test('should have valid model configuration', () {
      expect(AppConstants.defaultModelName, isNotEmpty);
      expect(AppConstants.maxTokens, greaterThan(0));
      expect(AppConstants.temperature, greaterThan(0));
      expect(AppConstants.temperature, lessThanOrEqualTo(1));
    });
  });
}
