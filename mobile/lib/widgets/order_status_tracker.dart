import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/l10n_formatters.dart';
import '../features/orders/order_status_track.dart';

/// Visual step tracker for order status — full or compact layout.
class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (status == 'cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                localizedOrderStatus(l10n, status),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final current = OrderStatusTrack.indexOf(status);
    final labels = OrderStatusTrack.steps
        .map((s) => localizedOrderStatus(l10n, s))
        .toList();

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DotsRow(currentIndex: current, stepCount: labels.length),
          const SizedBox(height: 6),
          Text(
            localizedOrderStatus(l10n, status),
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.goldDark,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DotsRow(currentIndex: current, stepCount: labels.length),
        const SizedBox(height: 10),
        Row(
          children: List.generate(labels.length, (i) {
            final isCurrent = i == current;
            final isDone = i < current;
            return Expanded(
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  height: 1.2,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? AppTheme.goldDark
                      : isDone
                          ? Colors.black87
                          : Colors.black38,
                ),
              ),
            );
          }),
        ),
        if (OrderStatusTrack.isActive(status)) ...[
          const SizedBox(height: 8),
          Text(
            l10n.orderTrackerYouAreHere(localizedOrderStatus(l10n, status)),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.goldDark,
            ),
          ),
        ],
      ],
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow({required this.currentIndex, required this.stepCount});

  final int currentIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stepCount * 2 - 1, (i) {
        if (i.isOdd) {
          final segment = i ~/ 2;
          final filled = segment < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: filled ? AppTheme.gold : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }

        final step = i ~/ 2;
        final isDone = step < currentIndex;
        final isCurrent = step == currentIndex;
        final color = isDone || isCurrent ? AppTheme.goldDark : Colors.black26;
        final size = isCurrent ? 14.0 : 11.0;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent ? color : Colors.white,
            border: Border.all(color: color, width: isCurrent ? 2.4 : 1.8),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.45),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
