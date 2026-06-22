import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_constants.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';
import '../orders/orders_page.dart';
import '../profile/profile_page.dart';
import '../shop/shop_home_page.dart';
import '../shop/cart_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _supportAnim;

  @override
  void initState() {
    super.initState();
    _supportAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _supportAnim.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(AppConstants.whatsappUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _onDestinationSelected(int i, {required bool showAccountTabs}) async {
    final whatsAppIndex = showAccountTabs ? 4 : 2;
    if (i == whatsAppIndex) {
      await _openWhatsApp();
      return;
    }
    if (!mounted) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final cart = context.watch<CartController>();
    final l10n = context.l10n;
    final w = MediaQuery.sizeOf(context).width;
    final useRail = w >= AppBreakpoints.railCompact;
    final extended = w >= AppBreakpoints.railExtended;
    final showAccountTabs =
        auth.isCustomerLoggedIn ||
        auth.guestName.trim().isNotEmpty ||
        auth.guestPhone.trim().isNotEmpty;

    final pages = <Widget>[
      const ShopHomePage(),
      const CartPage(),
      if (showAccountTabs) const OrdersPage(),
      if (showAccountTabs) const ProfilePage(),
    ];
    final safeIndex = _index.clamp(0, pages.length - 1);

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              selectedIndex: safeIndex,
              onDestinationSelected: (i) =>
                  _onDestinationSelected(i, showAccountTabs: showAccountTabs),
              labelType:
                  extended ? null : NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.storefront_outlined),
                  selectedIcon: const Icon(Icons.storefront),
                  label: Text(l10n.navShop),
                ),
                NavigationRailDestination(
                  icon: _BadgeIcon(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    count: cart.itemCount,
                  ),
                  selectedIcon: _BadgeIcon(
                    icon: const Icon(Icons.shopping_bag),
                    count: cart.itemCount,
                  ),
                  label: Text(l10n.navCart),
                ),
                if (showAccountTabs)
                  NavigationRailDestination(
                    icon: const Icon(Icons.local_shipping_outlined),
                    selectedIcon: const Icon(Icons.local_shipping),
                    label: Text(l10n.navOrders),
                  ),
                if (showAccountTabs)
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: Text(l10n.navYou),
                  ),
                NavigationRailDestination(
                  icon: _SupportAgent3DIcon(animation: _supportAnim, selected: false),
                  selectedIcon: _SupportAgent3DIcon(animation: _supportAnim, selected: true),
                  label: Text('WhatsApp'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: IndexedStack(
                index: safeIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (i) =>
            _onDestinationSelected(i, showAccountTabs: showAccountTabs),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.navShop,
          ),
          NavigationDestination(
            icon: _BadgeIcon(
              icon: const Icon(Icons.shopping_bag_outlined),
              count: cart.itemCount,
            ),
            selectedIcon: _BadgeIcon(
              icon: const Icon(Icons.shopping_bag),
              count: cart.itemCount,
            ),
            label: l10n.navCart,
          ),
          if (showAccountTabs)
            NavigationDestination(
              icon: const Icon(Icons.local_shipping_outlined),
              selectedIcon: const Icon(Icons.local_shipping),
              label: l10n.navOrders,
            ),
          if (showAccountTabs)
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navYou,
            ),
          NavigationDestination(
            icon: _SupportAgent3DIcon(animation: _supportAnim, selected: false),
            selectedIcon: _SupportAgent3DIcon(animation: _supportAnim, selected: true),
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.icon, required this.count});
  final Widget icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return icon;
    return Badge(
      label: Text('$count', style: const TextStyle(fontSize: 10)),
      child: icon,
    );
  }
}

class _SupportAgent3DIcon extends StatelessWidget {
  const _SupportAgent3DIcon({
    required this.animation,
    required this.selected,
  });

  final Animation<double> animation;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(animation.value);
        final angle = (t - 0.5) * 0.55; // subtle left-right 3D swing
        final shift = (t - 0.5) * 2.4;
        final scale = selected ? 1.05 + (0.02 * t) : 0.98 + (0.02 * t);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(shift)
            ..rotateY(angle)
            ..scale(scale),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFFC5A059) : const Color(0xFFBDAE8F),
                width: selected ? 1.6 : 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC5A059).withValues(alpha: selected ? 0.32 : 0.18),
                  blurRadius: selected ? 10 : 7,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/support_agent_3d.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
