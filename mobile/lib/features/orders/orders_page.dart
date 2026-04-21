import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_spacing.dart';
import '../../core/l10n_formatters.dart';
import '../../data/models/order.dart';
import '../auth/auth_controller.dart';
import '../auth/customer_profile_local_service.dart';
import '../shop/shop_repository.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _profileService = CustomerProfileLocalService();
  Future<List<Order>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadOrders();
  }

  Future<List<Order>> _loadOrders() async {
    final auth = context.read<AuthController>();
    final repo = context.read<ShopRepository>();
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
                const Center(child: CircularProgressIndicator())
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
                      child: ListTile(
                        title: Text(
                          o.orderNumber,
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          localizedOrderStatus(l10n, o.status),
                          style: TextStyle(color: AppTheme.goldDark),
                        ),
                        trailing: Text(
                          o.total.toStringAsFixed(2),
                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
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
