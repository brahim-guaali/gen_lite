import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'GenLite';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Lightweight Offline AI Assistant';

  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF0F172A);
  static const Color darkSurfaceColor = Color(0xFF1E293B);
  static const Color darkTextColor = Color(0xFFF1F5F9);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1E293B),
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF475569),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Color(0xFF64748B),
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Model Configuration
  static const String defaultModelName = 'gemma-3n-E4B-it-int4.task';
  static const int maxTokens = 2048;
  static const double temperature = 0.7;

  // File Configuration
  static const List<String> supportedFileTypes = ['pdf', 'txt', 'docx', 'md'];
  static const int maxFileSizeMB = 50;

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String modelKey = 'selected_model';
  static const String temperatureKey = 'temperature';
  static const String maxTokensKey = 'max_tokens';
}
