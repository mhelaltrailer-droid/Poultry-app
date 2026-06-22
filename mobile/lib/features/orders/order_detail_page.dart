import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_constants.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_text_scale.dart';
import '../../data/models/order.dart';
import '../../widgets/order_status_tracker.dart';
import '../auth/auth_controller.dart';
import '../shop/shop_repository.dart';
import 'reorder_preview_page.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({
    super.key,
    required this.order,
    required this.ownerPhone,
    this.onOrderChanged,
  });

  final Order order;
  final String ownerPhone;
  final VoidCallback? onOrderChanged;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static const _pollInterval = Duration(seconds: 45);

  late Order _order;
  bool _busy = false;
  bool _polling = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _syncPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _syncPolling() {
    _pollTimer?.cancel();
    if (!Order.isTrackableActive(_order.status)) {
      _polling = false;
      return;
    }
    _polling = true;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refreshOrder(silent: true));
  }

  bool get _canCancel => Order.canCustomerCancel(_order.status);

  bool get _showSupportOnly =>
      !_canCancel && _order.status != 'delivered' && _order.status != 'cancelled';

  Future<void> _refreshOrder({bool silent = false}) async {
    if (_busy) return;
    if (!silent) setState(() => _busy = true);
    try {
      final repo = context.read<ShopRepository>();
      final auth = context.read<AuthController>();
      final Order fresh;
      if (auth.isCustomerLoggedIn) {
        fresh = await repo.fetchOrder(_order.id);
      } else {
        final phone = widget.ownerPhone.replaceAll(RegExp(r'\s'), '');
        if (phone.isEmpty) return;
        fresh = await repo.fetchGuestOrder(_order.id, phone);
      }
      if (!mounted) return;
      final statusChanged = fresh.status != _order.status;
      setState(() => _order = fresh);
      if (statusChanged) {
        widget.onOrderChanged?.call();
        _syncPolling();
      } else if (!Order.isTrackableActive(fresh.status)) {
        _syncPolling();
      }
    } catch (_) {
      // Keep last known state during background refresh.
    } finally {
      if (mounted && !silent) setState(() => _busy = false);
    }
  }

  Future<void> _cancelOrder() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.orderCancelTitle),
            content: Text(l10n.orderCancelConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.no),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.yes),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      final repo = context.read<ShopRepository>();
      final auth = context.read<AuthController>();
      final updated = auth.isCustomerLoggedIn
          ? await repo.cancelCustomerOrder(
              _order.id,
              reason: 'Cancelled by customer',
            )
          : await repo.cancelGuestOrder(
              _order.id,
              widget.ownerPhone,
              reason: 'Cancelled by customer',
            );
      if (!mounted) return;
      setState(() => _order = updated);
      widget.onOrderChanged?.call();
      _syncPolling();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderCancelledSnack)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openWhatsAppSupport() async {
    final l10n = context.l10n;
    final text = Uri.encodeComponent(
      l10n.orderSupportWhatsAppMessage(_order.orderNumber),
    );
    final uri = Uri.parse('${AppConstants.whatsappUrl}?text=$text');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openReorder() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReorderPreviewPage(order: _order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final o = _order;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetailTitle),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refreshOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width)),
        children: [
          Text(
            o.orderNumber,
            style: GoogleFonts.playfairDisplay(
              fontSize: AppTextScale.fontSize(context, 26),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: OrderStatusTracker(status: o.status),
            ),
          ),
          if (_polling) ...[
            const SizedBox(height: 8),
            Text(
              l10n.orderTrackerAutoRefresh,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),
          ],
          if (o.deliverySlotLabel != null && o.deliverySlotLabel!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(l10n.orderDeliverySlot, o.deliverySlotLabel!),
          ],
          if (o.deliveryAddress != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              l10n.phone,
              (o.deliveryAddress!['phone'] ?? '').toString(),
            ),
            const SizedBox(height: 4),
            _infoRow(
              l10n.orderDeliveryAddress,
              (o.deliveryAddress!['line1'] ?? '').toString(),
            ),
          ],
          const Divider(height: 32),
          Text(l10n.reorderItemsTitle, style: GoogleFonts.playfairDisplay(fontSize: 20)),
          const SizedBox(height: 8),
          ...o.items.map(
            (it) => Padding(
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
                              it.name,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${it.price.toStringAsFixed(2)} × ${it.quantity}',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        (it.price * it.quantity).toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          _row(l10n.subtotal, o.subtotal),
          if (o.discountAmount > 0) _row(l10n.orderDiscount, -o.discountAmount),
          _row(l10n.orderDeliveryFee, o.deliveryFee),
          _row(l10n.orderTotal, o.total, bold: true),
          const SizedBox(height: 12),
          Text(
            l10n.orderPlacedAt(o.createdAt.toLocal().toString()),
            style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54),
          ),
          if (o.status == 'cancelled' &&
              o.cancellationReason != null &&
              o.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.orderCancelReason}: ${o.cancellationReason}',
              style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black54),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          if (_canCancel)
            FilledButton.icon(
              onPressed: _busy ? null : _cancelOrder,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cancel_outlined),
              label: Text(l10n.orderCancelAction),
            ),
          if (_showSupportOnly) ...[
            Text(
              l10n.orderCancelSupportHint,
              style: GoogleFonts.montserrat(color: Colors.black54, height: 1.45),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _openWhatsAppSupport,
              icon: Image.asset(
                'assets/images/support_agent_3d.png',
                width: 22,
                height: 22,
                errorBuilder: (_, __, ___) => const Icon(Icons.chat),
              ),
              label: Text(l10n.orderContactSupport),
            ),
          ],
          if (o.status != 'cancelled') ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _openReorder,
              icon: const Icon(Icons.replay_rounded),
              label: Text(l10n.reorder),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(child: Text(value, style: GoogleFonts.montserrat())),
      ],
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.montserrat())),
          Text(
            value.toStringAsFixed(2),
            style: GoogleFonts.montserrat(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
