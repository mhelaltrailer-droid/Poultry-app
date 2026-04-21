import 'package:flutter/material.dart';

import '../core/responsive/app_breakpoints.dart';
import '../core/responsive/app_spacing.dart';
import '../core/responsive/responsive_layout.dart';

/// [SliverGrid] whose column count and aspect ratio follow [AppBreakpoints].
class ResponsiveProductSliverGrid extends StatelessWidget {
  const ResponsiveProductSliverGrid({
    super.key,
    required this.delegate,
    this.padding = EdgeInsets.zero,
    this.minTileWidth = 148,
  });

  final SliverChildDelegate delegate;
  final EdgeInsetsGeometry padding;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.crossAxisExtent;
        final count = productGridCrossAxisCount(w, minTileWidth: minTileWidth);
        final tier = breakpointTierFromWidth(w);
        final ratio = productGridAspectRatio(tier);
        return SliverPadding(
          padding: padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: ratio,
            ),
            delegate: delegate,
          ),
        );
      },
    );
  }
}
