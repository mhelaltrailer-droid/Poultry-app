import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/responsive/app_text_scale.dart';
import '../../data/models/order.dart';
import '../shop/shop_repository.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Order> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ShopRepository>().fetchOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: const Text('Order'),
      ),
      body: FutureBuilder<Order>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final o = snap.data!;
          return ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              Text(
                o.orderNumber,
                style: GoogleFonts.playfairDisplay(
                  fontSize: AppTextScale.fontSize(context, 26),
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(Order.statusLabel(o.status)),
                backgroundColor: AppTheme.gold.withValues(alpha: 0.2),
              ),
              if (o.assignedDelivery != null &&
                  o.assignedDelivery!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Delivery: ${o.assignedDelivery}',
                  style: GoogleFonts.montserrat(),
                ),
              ],
              const Divider(height: 32),
              Text('Items', style: GoogleFonts.playfairDisplay(fontSize: 20)),
              ...o.items.map(
                (it) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
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
                            ),
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
                      const SizedBox(width: 8),
                      Text(
                        (it.price * it.quantity).toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              _row('Subtotal', o.subtotal),
              _row('Discount', -o.discountAmount),
              _row('Delivery', o.deliveryFee),
              _row('Total', o.total, bold: true),
              const SizedBox(height: 16),
              Text(
                'Placed ${o.createdAt.toLocal()}',
                style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: GoogleFonts.montserrat(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
