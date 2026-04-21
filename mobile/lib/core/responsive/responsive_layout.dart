import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_spacing.dart';
import 'responsive_context.dart';

/// Centers [child] and caps width for readable forms on large screens.
class AppMaxWidthBody extends StatelessWidget {
  const AppMaxWidthBody({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingX(context.screenWidth),
          vertical: AppSpacing.md,
        );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: pad,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth.clamp(0, context.screenWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Scrollable page: avoids vertical overflow; optional max width on wide screens.
class AppScrollablePage extends StatelessWidget {
  const AppScrollablePage({
    super.key,
    required this.child,
    this.maxContentWidth = 720,
    this.padding,
    this.physics,
  });

  final Widget child;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final horizontal = AppSpacing.pagePaddingX(context.screenWidth);
    final vertical = AppSpacing.md;
    final inset = padding ??
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

    Widget content = child;
    final mw = maxContentWidth;
    if (mw != null && context.screenWidth > mw + horizontal * 2) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: mw),
          child: content,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: physics ??
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
          padding: inset,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - vertical * 2).clamp(0.0, double.infinity),
            ),
            child: content,
          ),
        );
      },
    );
  }
}

/// Use inside [AlertDialog] / sheets: bounded width from viewport, no hardcoded px.
double dialogContentMaxWidth(BuildContext context) {
  final w = context.screenWidth;
  return (w - AppSpacing.xl * 2).clamp(280.0, 520.0);
}

/// Product grid: column count from width and minimum tile width.
int productGridCrossAxisCount(double width, {double minTileWidth = 148}) {
  final count = (width / minTileWidth).floor();
  if (width < AppBreakpoints.mobile) return count.clamp(2, 3);
  if (width < AppBreakpoints.tablet) return count.clamp(3, 4);
  return count.clamp(4, 6);
}

double productGridAspectRatio(AppBreakpointTier tier) {
  switch (tier) {
    case AppBreakpointTier.mobile:
      return 0.72;
    case AppBreakpointTier.tablet:
      return 0.76;
    case AppBreakpointTier.desktop:
      return 0.78;
  }
}
