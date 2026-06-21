import 'package:flutter/material.dart';

/// Luxury palette for cinematic splash.
abstract final class SplashPalette {
  static const Color ivory = Color(0xFFF7F5F2);
  static const Color black = Color(0xFF111111);
  static const Color gold = Color(0xFFD4B483);
  static const Color goldDeep = Color(0xFFB8956A);
  static const Color mutedGold = Color(0xFF8B754A);

  static const Duration total = Duration(milliseconds: 5800);

  // Scene boundaries (0.0 – 1.0) — eased for a softer hand-off to the landing UI.
  static const double particlesEnd = 0.28;
  static const double logoEnd = 0.58;
  static const double welcomeEnd = 0.78;
  static const double holdEnd = 0.88;
  static const double uiRevealStart = 0.88;
}
