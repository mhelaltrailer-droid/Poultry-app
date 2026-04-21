import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_formatters.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../auth/auth_controller.dart';
import 'admin_flash_offers_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_districts_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_stock_screen.dart';
import 'admin_users_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  void _stepBack() {
    if (_index <= 0) return;
    setState(() => _index = _index - 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthController>();
    final userName = (auth.staffUser?['name']?.toString().trim() ?? '').isEmpty
        ? 'Staff'
        : auth.staffUser!['name'].toString().trim();
    final roleCode = auth.staffUser?['role']?.toString() ?? '';
    final roleLabel =
        roleCode.isEmpty ? '' : localizedAdminRole(l10n, roleCode);
    final titles = [
      'Orders',
      l10n.adminTitleUsers,
      l10n.adminTitleCustomers,
      l10n.adminTitleProducts,
      l10n.adminTitleStock,
      'Districts',
      'Flash Offers',
      'Reports',
    ];
    final pages = [
      const AdminOrdersScreen(),
      const AdminUsersScreen(),
      const AdminCustomersScreen(),
      const AdminProductsScreen(),
      const AdminStockScreen(),
      const AdminDistrictsScreen(),
      const AdminFlashOffersScreen(),
      const AdminReportsScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.railCompact;
        // Flutter 3.41+: when extended is true, labelType must be null or none
        // (labels still show beside icons from each destination).
        final extended =
            wide && constraints.maxWidth >= AppBreakpoints.railExtended;
        final rail = NavigationRail(
          extended: extended,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelType:
              extended ? null : NavigationRailLabelType.all,
          destinations: [
            const NavigationRailDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: Text('Orders'),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.manage_accounts_outlined),
              selectedIcon: const Icon(Icons.manage_accounts),
              label: Text(l10n.adminNavUsers),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.person_search_outlined),
              selectedIcon: const Icon(Icons.person_search),
              label: Text(l10n.adminNavCustomers),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              selectedIcon: const Icon(Icons.inventory_2),
              label: Text(l10n.adminNavProducts),
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.warehouse_outlined),
              selectedIcon: const Icon(Icons.warehouse),
              label: Text(l10n.adminNavStock),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.location_city_outlined),
              selectedIcon: Icon(Icons.location_city),
              label: Text('Districts'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.flash_on_outlined),
              selectedIcon: Icon(Icons.flash_on),
              label: Text('Flash Offers'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: Text('Reports'),
            ),
          ],
        );

        final body = pages[_index];

        if (wide) {
          return Scaffold(
            appBar: AppBar(
              leading: _index > 0
                  ? IconButton(
                      onPressed: _stepBack,
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              title: Text(titles[_index]),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Center(
                    child: Text(
                      roleLabel.isEmpty ? userName : '$userName • $roleLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<AuthController>().logout(),
                  child: Text(l10n.adminLogout,
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            body: Row(
              children: [
                rail,
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: _index > 0
                ? IconButton(
                    onPressed: _stepBack,
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
            title: Text(titles[_index]),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthController>().logout(),
                child: Text(l10n.adminLogout,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (roleLabel.isNotEmpty)
                        Text(
                          roleLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFC5A059),
                            fontSize: 13,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        l10n.adminDashboardDrawer,
                        style: const TextStyle(
                          color: Color(0xFFC5A059),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                for (var i = 0; i < titles.length; i++)
                  ListTile(
                    title: Text(titles[i]),
                    selected: _index == i,
                    onTap: () {
                      setState(() => _index = i);
                      Navigator.of(context).pop();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l10n.adminLogout),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await context.read<AuthController>().logout();
                  },
                ),
              ],
            ),
          ),
          body: body,
        );
      },
    );
  }
}
