/// Canonical layout breakpoints for the app (width-based).
abstract final class AppBreakpoints {
  /// Max width treated as **mobile** (exclusive upper bound for tablet).
  static const double mobile = 600;

  /// Max width treated as **tablet** (exclusive upper bound for desktop).
  static const double tablet = 1024;

  /// Comfortable minimum width before showing a side [NavigationRail] in shells.
  static const double railCompact = 600;

  /// Width at which an **extended** rail is used (labels beside icons).
  static const double railExtended = 900;
}

/// Derived tier from viewport width.
enum AppBreakpointTier {
  mobile,
  tablet,
  desktop,
}

AppBreakpointTier breakpointTierFromWidth(double width) {
  if (width < AppBreakpoints.mobile) return AppBreakpointTier.mobile;
  if (width < AppBreakpoints.tablet) return AppBreakpointTier.tablet;
  return AppBreakpointTier.desktop;
}
