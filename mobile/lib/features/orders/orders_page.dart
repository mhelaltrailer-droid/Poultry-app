import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/l10n_formatters.dart';
import '../../data/models/order.dart';
import '../../widgets/app_skeleton.dart';
import '../../widgets/order_status_tracker.dart';
import '../auth/auth_controller.dart';
import '../auth/customer_profile.dart';
import '../auth/customer_profile_local_service.dart';
import '../shop/shop_repository.dart';
import 'order_detail_page.dart';
import 'reorder_preview_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _profileService = CustomerProfileLocalService();
  CustomerProfile? _savedProfile;
  Future<List<Order>>? _future;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _future = _loadOrders();
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.load();
    if (!mounted) return;
    setState(() => _savedProfile = profile);
  }

  Future<List<Order>> _loadOrders() async {
    final auth = context.read<AuthController>();
    final repo = context.read<ShopRepository>();
    if (auth.isCustomerLoggedIn) {
      return repo.fetchMyOrders();
    }
    final profile = await _profileService.load();
    final phone = auth.guestPhone.trim().isNotEmpty
        ? auth.guestPhone.trim()
        : (profile?.mobile.trim() ?? '');
    if (phone.isEmpty) return const [];
    return repo.fetchGuestOrdersByPhone(phone);
  }

  Future<void> _refresh() async {
    setState(() => _future = _loadOrders());
    await _future;
  }

  void _openOrderDetail(Order order) {
    final auth = context.read<AuthController>();
    final phone = auth.guestPhone.trim().isNotEmpty
        ? auth.guestPhone.trim()
        : (_savedProfile?.defaultPhone.number ?? '');
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailPage(
              order: order,
              ownerPhone: phone,
              onOrderChanged: _refresh,
            ),
          ),
        )
        .then((_) => _refresh());
  }

  void _openReorder(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReorderPreviewPage(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        title: Text(l10n.ordersTitle),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <Order>[];
          return ListView(
            padding: EdgeInsets.all(AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width)),
            children: [
              Text(
                l10n.ordersHistoryTitle,
                style: GoogleFonts.playfairDisplay(fontSize: 22),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                l10n.ordersExplainer,
                style: GoogleFonts.montserrat(height: 1.45, color: Colors.black54),
              ),
              SizedBox(height: AppSpacing.md),
              if (snapshot.connectionState == ConnectionState.waiting)
                const OrderCardSkeletonList()
              else if (snapshot.hasError)
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.red),
                )
              else if (items.isEmpty)
                Text(
                  l10n.noProductsYet,
                  style: GoogleFonts.montserrat(color: Colors.black54),
                )
              else
                ...items.map(
                  (o) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openOrderDetail(o),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.xs,
                            AppSpacing.sm,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      o.orderNumber,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    o.total.toStringAsFixed(2),
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: l10n.reorder,
                                    icon: const Icon(Icons.replay_rounded),
                                    onPressed: () => _openReorder(o),
                                  ),
                                ],
                              ),
                              if (Order.isTrackableActive(o.status)) ...[
                                const SizedBox(height: 6),
                                OrderStatusTracker(status: o.status, compact: true),
                              ] else
                                Text(
                                  localizedOrderStatus(l10n, o.status),
                                  style: const TextStyle(color: Color(0xFF8B754A)),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
