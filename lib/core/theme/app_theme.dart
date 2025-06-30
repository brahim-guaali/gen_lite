import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      tertiary: AppConstants.accentColor,
      surface: AppConstants.surfaceColor,
      background: AppConstants.backgroundColor,
      error: AppConstants.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1E293B),
      onBackground: Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.surfaceColor,
      foregroundColor: Color(0xFF1E293B),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppConstants.surfaceColor,
      elevation: 2,
      shadowColor: Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
    ),
    textTheme: const TextTheme(
      headlineLarge: AppConstants.headingStyle,
      headlineMedium: AppConstants.subheadingStyle,
      bodyLarge: AppConstants.bodyStyle,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      tertiary: AppConstants.accentColor,
      surface: AppConstants.darkSurfaceColor,
      background: AppConstants.darkBackgroundColor,
      error: AppConstants.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppConstants.darkTextColor,
      onBackground: AppConstants.darkTextColor,
    ),
    scaffoldBackgroundColor: AppConstants.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.darkSurfaceColor,
      foregroundColor: AppConstants.darkTextColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppConstants.darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppConstants.darkSurfaceColor,
      elevation: 2,
      shadowColor: Color(0x4D000000),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppConstants.borderRadiusMedium)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        borderSide:
            const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppConstants.darkTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppConstants.darkTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppConstants.darkTextColor,
      ),
    ),
  );
}
