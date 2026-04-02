import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF0288D1);
  static const Color accentColor = Color(0xFF00ACC1);
  static const Color dangerColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color surfaceColor = Color(0xFFF5F5F5);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          tertiary: accentColor,
          error: dangerColor,
          surface: surfaceColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        fontFamily: 'Roboto',
      );

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'normal':
        return successColor;
      case 'mild':
        return const Color(0xFF8BC34A);
      case 'moderate':
        return warningColor;
      case 'severe':
        return const Color(0xFFE64A19);
      case 'very severe':
        return dangerColor;
      default:
        return Colors.grey;
    }
  }

  static Color riskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'no risk':
        return successColor;
      case 'low risk':
        return const Color(0xFF8BC34A);
      case 'moderate risk':
        return warningColor;
      case 'high risk':
        return const Color(0xFFE64A19);
      case 'critical risk':
        return dangerColor;
      default:
        return Colors.grey;
    }
  }
}
