import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/l10n_formatters.dart';
import '../../core/responsive/app_spacing.dart';
import '../../data/models/order.dart';
import '../../widgets/app_skeleton.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_model.dart';
import '../shop/cart_page.dart';
import '../shop/shop_repository.dart';

/// Review a past order, edit quantities, then load items into the cart.
class ReorderPreviewPage extends StatefulWidget {
  const ReorderPreviewPage({super.key, required this.order});

  final Order order;

  @override
  State<ReorderPreviewPage> createState() => _ReorderPreviewPageState();
}

class _ReorderPreviewPageState extends State<ReorderPreviewPage> {
  late Future<_ReorderDraft> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDraft();
  }

  Future<_ReorderDraft> _loadDraft() async {
    final repo = context.read<ShopRepository>();
    final lines = await repo.buildReorderLines(widget.order);
    final skipped = widget.order.items.length - lines.length;
    return _ReorderDraft(lines: lines, skippedCount: skipped);
  }

  double _subtotal(List<CartLine> lines) =>
      lines.fold(0.0, (sum, line) => sum + line.lineTotal);

  Future<void> _addToCart(List<CartLine> lines) async {
    final l10n = context.l10n;
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reorderEmpty)),
      );
      return;
    }

    final cart = context.read<CartController>();
    if (cart.lines.isNotEmpty) {
      final choice = await showDialog<_CartMergeChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.reorderReplaceCartTitle),
          content: Text(l10n.reorderReplaceCartBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _CartMergeChoice.cancel),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _CartMergeChoice.merge),
              child: Text(l10n.reorderMergeCart),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _CartMergeChoice.replace),
              child: Text(l10n.reorderReplaceCart),
            ),
          ],
        ),
      );
      if (!mounted || choice == null || choice == _CartMergeChoice.cancel) {
        return;
      }
      if (choice == _CartMergeChoice.replace) {
        await cart.replaceLines(lines);
      } else {
        await cart.mergeLines(lines);
      }
    } else {
      await cart.replaceLines(lines);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reorderAddedToCart)),
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reorderTitle),
      ),
      body: FutureBuilder<_ReorderDraft>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(snap.error.toString(), textAlign: TextAlign.center),
              ),
            );
          }
          if (!snap.hasData) {
            return const DetailPageSkeleton();
          }

          final draft = snap.data!;
          if (draft.lines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.reorderEmpty,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: Colors.black54),
                ),
              ),
            );
          }

          return _ReorderBody(
            order: order,
            initialLines: draft.lines,
            skippedCount: draft.skippedCount,
            lang: lang,
            subtotal: _subtotal,
            onAddToCart: _addToCart,
          );
        },
      ),
    );
  }
}

class _ReorderBody extends StatefulWidget {
  const _ReorderBody({
    required this.order,
    required this.initialLines,
    required this.skippedCount,
    required this.lang,
    required this.subtotal,
    required this.onAddToCart,
  });

  final Order order;
  final List<CartLine> initialLines;
  final int skippedCount;
  final String lang;
  final double Function(List<CartLine>) subtotal;
  final Future<void> Function(List<CartLine>) onAddToCart;

  @override
  State<_ReorderBody> createState() => _ReorderBodyState();
}

class _ReorderBodyState extends State<_ReorderBody> {
  late List<CartLine> _lines;

  @override
  void initState() {
    super.initState();
    _lines = widget.initialLines.map((l) => l.copyWith()).toList();
  }

  void _setQuantity(int index, int qty) {
    setState(() {
      if (qty <= 0) {
        _lines.removeAt(index);
      } else {
        _lines[index] = _lines[index].copyWith(quantity: qty);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final order = widget.order;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(
              AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width),
            ),
            children: [
              Text(
                order.orderNumber,
                style: GoogleFonts.playfairDisplay(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Chip(
                label: Text(localizedOrderStatus(l10n, order.status)),
                backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
              ),
              if (order.deliverySlotLabel != null &&
                  order.deliverySlotLabel!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.reorderPreviousSlot}: ${order.deliverySlotLabel}',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.reorderHint,
                style: GoogleFonts.montserrat(
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),
              if (widget.skippedCount > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.reorderUnavailable(widget.skippedCount),
                  style: GoogleFonts.montserrat(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Divider(height: 32),
              Text(
                l10n.reorderItemsTitle,
                style: GoogleFonts.playfairDisplay(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...List.generate(_lines.length, (i) {
                final line = _lines[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.localizedName(widget.lang),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${line.price.toStringAsFixed(2)} × ${line.quantity}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () =>
                                          _setQuantity(i, line.quantity - 1),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                      ),
                                      child: Text(
                                        '${line.quantity}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () =>
                                          _setQuantity(i, line.quantity + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            line.lineTotal.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Material(
          elevation: 6,
          shadowColor: Colors.black26,
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width),
                AppSpacing.md,
                AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width),
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.subtotal,
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                      ),
                      Text(
                        widget.subtotal(_lines).toStringAsFixed(2),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.goldDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton.icon(
                    onPressed: _lines.isEmpty
                        ? null
                        : () => widget.onAddToCart(_lines),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(l10n.reorderAddToCart),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReorderDraft {
  const _ReorderDraft({required this.lines, required this.skippedCount});

  final List<CartLine> lines;
  final int skippedCount;
}

enum _CartMergeChoice { cancel, replace, merge }
