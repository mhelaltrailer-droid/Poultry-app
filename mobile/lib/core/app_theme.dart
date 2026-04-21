import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'responsive/app_spacing.dart';

/// DAY TO DAY — cream, black, gold (premium poultry)
class AppTheme {
  static const Color gold = Color(0xFFC5A059);
  static const Color goldDark = Color(0xFF9A7B42);
  static const Color black = Color(0xFF1A1A1A);
  static const Color cream = Color(0xFFF9F7F2);

  static ThemeData light() {
    final display = GoogleFonts.playfairDisplayTextTheme();
    final body = GoogleFonts.montserratTextTheme();

    final colorScheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.light,
      primary: goldDark,
      onPrimary: cream,
      surface: cream,
      onSurface: black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      textTheme: display.copyWith(
        bodyLarge: body.bodyLarge?.copyWith(color: black),
        bodyMedium: body.bodyMedium?.copyWith(color: black),
        bodySmall: body.bodySmall?.copyWith(color: black),
        labelLarge: body.labelLarge?.copyWith(color: black),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: cream,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: gold,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: black,
        indicatorColor: gold.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.montserrat(fontSize: 12, color: cream),
        ),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final selected = s.contains(WidgetState.selected);
          return IconThemeData(color: selected ? gold : cream.withValues(alpha: 0.6));
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: goldDark,
          foregroundColor: cream,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm + 2,
          ),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
