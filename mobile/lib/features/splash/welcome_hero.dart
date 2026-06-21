import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared welcome title + brand card — matches the landing reference layout.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({
    super.key,
    required this.welcomeText,
    required this.titleSize,
    required this.logoWidth,
    this.textScale = 1.0,
    this.titleOpacity = 1.0,
    this.logoReveal = 1.0,
    this.showTitle = true,
  });

  final String welcomeText;
  final double titleSize;
  final double logoWidth;
  final double textScale;
  final double titleOpacity;
  final double logoReveal;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle && welcomeText.isNotEmpty)
          Opacity(
            opacity: titleOpacity.clamp(0.0, 1.0),
            child: Text(
              welcomeText,
              textAlign: TextAlign.center,
              textScaler: TextScaler.linear(textScale),
              style: GoogleFonts.playfairDisplay(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181818),
              ),
            ),
          ),
        if (showTitle && welcomeText.isNotEmpty) const SizedBox(height: 12),
        Transform.scale(
          scale: 0.9 + logoReveal.clamp(0.0, 1.0) * 0.1,
          child: Opacity(
            opacity: logoReveal.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFD8C18A).withValues(alpha: 0.85),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Image.asset(
                'assets/images/brand_logo_full.png',
                width: logoWidth,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
