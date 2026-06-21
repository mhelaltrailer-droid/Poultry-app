import 'package:flutter/material.dart';

import '../core/responsive/app_breakpoints.dart';
import '../core/responsive/app_spacing.dart';
import '../core/responsive/responsive_layout.dart';

/// Moving highlight over a solid-colored subtree (table rows, tiles, etc.).
class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final hi = Color.lerp(base, Theme.of(context).colorScheme.surface, 0.55)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * 2 - 0.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, hi, base],
              stops: const [0.2, 0.5, 0.8],
              begin: Alignment(-1.4 + t * 2.8, 0),
              end: Alignment(0.2 + t * 2.8, 0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonRect extends StatelessWidget {
  const SkeletonRect({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final double height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(color: bg, borderRadius: borderRadius),
    );
  }
}

/// Generic admin list placeholder (filters stay interactive once data loads).
class AdminPageSkeleton extends StatelessWidget {
  const AdminPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width);
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          const SkeletonRect(height: 36, width: 140),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonRect(height: 44),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            10,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SkeletonRect(height: 68, borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matches [ResponsiveProductSliverGrid] density for the shop home loading state.
class ShopProductGridSkeleton extends StatelessWidget {
  const ShopProductGridSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padX = AppSpacing.pagePaddingX(w);
    final count = productGridCrossAxisCount(w);
    final ratio = productGridAspectRatio(breakpointTierFromWidth(w));
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return AppShimmer(
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(padX, AppSpacing.sm, padX, AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: ratio,
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) {
          return Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: base,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonRect(height: 13, width: 110, borderRadius: BorderRadius.circular(6)),
                      const SizedBox(height: AppSpacing.xs),
                      SkeletonRect(height: 11, width: 56, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderCardSkeletonList extends StatelessWidget {
  const OrderCardSkeletonList({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          count,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SkeletonRect(height: 88, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class DetailPageSkeleton extends StatelessWidget {
  const DetailPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonRect(height: 220, borderRadius: BorderRadius.all(Radius.circular(12))),
            const SizedBox(height: AppSpacing.md),
            const SkeletonRect(height: 26, width: 200),
            const SizedBox(height: AppSpacing.sm),
            const SkeletonRect(height: 18, width: 120),
            const SizedBox(height: AppSpacing.md),
            const SkeletonRect(height: 14, width: double.infinity),
            const SizedBox(height: AppSpacing.xs),
            const SkeletonRect(height: 14, width: double.infinity),
            const SizedBox(height: AppSpacing.xs),
            const SkeletonRect(height: 14, width: 180),
          ],
        ),
      ),
    );
  }
}

class FlashOffersListSkeleton extends StatelessWidget {
  const FlashOffersListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width);
    return AppShimmer(
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SkeletonRect(height: 200, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
