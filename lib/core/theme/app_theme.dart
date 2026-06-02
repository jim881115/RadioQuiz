import 'package:flutter/material.dart';

/// Centralized color constants and theme definition for the RadioQuiz app.
///
/// Use [AppTheme.light] as the [ThemeData] in [MaterialApp].
/// For UI elements that need specific colors (e.g. quiz answer states),
/// reference the static color constants directly.
class AppTheme {
  AppTheme._();

  /// Main theme with Material 3 and a blue color scheme.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          error: AppTheme.wrongRed,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );

  /// Default text color (was `Colors.black`).
  static const Color textPrimary = Colors.black;

  // ── Quiz-specific UI colors ──────────────────────────────────────

  /// Container background for the question index badge (was `blue.shade100`).
  static const Color infoBlue = Color(0xFFBBDEFB);

  /// Container background for the countdown timer (was `red.shade100`).
  static const Color warningRed = Color(0xFFFFCDD2);

  /// Background for the primary action button (was `green.shade400`).
  static const Color primaryGreen = Color(0xFF66BB6A);

  /// Background for the selected answer button (was `Colors.lightBlue`).
  static const Color selectedBlue = Color(0xFF42A5F5);

  /// Text/border color for a correct answer (was `Colors.green`).
  static const Color correctGreen = Color(0xFF4CAF50);

  /// Text/border color for a wrong answer (was `Colors.red`).
  static const Color wrongRed = Color(0xFFE53935);

  /// Background for a correctly-selected option (was `green.shade100`).
  static const Color correctGreenBg = Color(0xFFC8E6C9);

  /// Background for a wrongly-selected option (was `red.shade100`).
  static const Color wrongRedBg = Color(0xFFFFCDD2);

  /// Border color for unselected options (was `grey.shade400`).
  static const Color borderGrey = Color(0xFFBDBDBD);
}
