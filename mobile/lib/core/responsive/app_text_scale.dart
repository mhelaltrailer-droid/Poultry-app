import 'package:flutter/material.dart';

import 'responsive_context.dart';

/// Scales a logical font size from a reference phone width (default 390).
abstract final class AppTextScale {
  static double fontSize(
    BuildContext context,
    double base, {
    double minFactor = 0.88,
    double maxFactor = 1.15,
    double referenceWidth = 390,
  }) {
    final w = context.screenWidth;
    final factor = (w / referenceWidth).clamp(minFactor, maxFactor);
    return base * factor;
  }

  /// Respects system text scaler (accessibility).
  static TextStyle scaledStyle(
    BuildContext context,
    TextStyle base, {
    double sizeMultiplier = 1,
  }) {
    final scaled = base.fontSize != null
        ? base.copyWith(
            fontSize: fontSize(context, base.fontSize! * sizeMultiplier),
          )
        : base;
    return scaled;
  }
}
