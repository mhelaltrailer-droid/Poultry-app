import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'responsive_context.dart';

/// Semantic spacing — prefer these over raw literals in UI code.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Horizontal inset for page bodies (scales slightly with breakpoint).
  static double pagePaddingX(double width) {
    final tier = breakpointTierFromWidth(width);
    switch (tier) {
      case AppBreakpointTier.mobile:
        return md;
      case AppBreakpointTier.tablet:
        return lg;
      case AppBreakpointTier.desktop:
        return xl;
    }
  }

  static EdgeInsets pageInsets(BuildContext context) {
    final x = pagePaddingX(context.screenWidth);
    final y = context.breakpointTier == AppBreakpointTier.mobile ? md : lg;
    return EdgeInsets.symmetric(horizontal: x, vertical: y);
  }

  static EdgeInsets pageInsetsSymmetric(BuildContext context) {
    final x = pagePaddingX(context.screenWidth);
    return EdgeInsets.symmetric(horizontal: x);
  }
}
