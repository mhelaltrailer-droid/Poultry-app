import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  AppBreakpointTier get breakpointTier =>
      breakpointTierFromWidth(screenWidth);

  bool get isMobileBreakpoint => breakpointTier == AppBreakpointTier.mobile;

  bool get isTabletBreakpoint => breakpointTier == AppBreakpointTier.tablet;

  bool get isDesktopBreakpoint => breakpointTier == AppBreakpointTier.desktop;

  /// At least tablet width (600+).
  bool get isTabletOrWider => screenWidth >= AppBreakpoints.mobile;

  /// At least desktop width (1024+).
  bool get isDesktopOrWider => screenWidth >= AppBreakpoints.tablet;
}
