import 'package:flutter/material.dart';

import '../core/responsive/app_breakpoints.dart';

/// Lays out [children] in a [Row] when wider than [widthBreakpoint], else [Column].
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.widthBreakpoint = AppBreakpoints.mobile,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0,
    this.runSpacing = 0,
  });

  final List<Widget> children;
  final double widthBreakpoint;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= widthBreakpoint) {
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: _withSpacing(children, spacing, axis: Axis.horizontal),
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _withSpacing(children, runSpacing, axis: Axis.vertical),
        );
      },
    );
  }

  static List<Widget> _withSpacing(
    List<Widget> items,
    double gap, {
    required Axis axis,
  }) {
    if (items.isEmpty || gap <= 0) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        out.add(
          axis == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
      out.add(items[i]);
    }
    return out;
  }
}
