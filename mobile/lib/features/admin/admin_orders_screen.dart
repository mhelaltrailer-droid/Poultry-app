import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_formatters.dart';
import '../../core/l10n_context.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/responsive/app_spacing.dart';
import '../../data/api_client.dart';
import '../../data/models/order.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _statuses = <String>[
    'pending',
    'confirmed',
    'preparing',
    'on_the_way',
    'delivered',
    'cancelled',
  ];

  List<Map<String, dynamic>> _rows = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _statusFilters = <String>{};
  final Set<String> _districtFilters = <String>{};
  DateTime? _dayFilter;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<ApiClient>().get('/api/admin/orders', auth: true) as List<dynamic>;
      setState(() {
        _rows = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _askCancellationReason() async {
    final ctrl = TextEditingController();
    String? errorText;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Cancel order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please enter cancellation reason (required):'),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Cancellation reason',
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () {
                final reason = ctrl.text.trim();
                if (reason.isEmpty) {
                  setModal(() => errorText = 'Reason is required');
                  return;
                }
                Navigator.pop(ctx, reason);
              },
              child: const Text('Confirm cancel'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    return result;
  }

  Future<void> _updateStatus(Order order, String status) async {
    final api = context.read<ApiClient>();
    String? cancellationReason;
    if (status == 'cancelled') {
      cancellationReason = await _askCancellationReason();
      if (cancellationReason == null || cancellationReason.trim().isEmpty) return;
    }
    try {
      await api.patch(
        '/api/admin/orders/${order.id}/status',
        {
          'status': status,
          'cancellationReason': cancellationReason?.trim(),
        },
        auth: true,
      );
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _openDetails(Order order) async {
    try {
      final data = await context
          .read<ApiClient>()
          .get('/api/admin/orders/${order.id}', auth: true) as Map<String, dynamic>;
      final full = Order.fromJson(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final l10n = ctx.l10n;
          final addr = full.deliveryAddress ?? const <String, dynamic>{};
          return AlertDialog(
            title: Text('Order ${full.orderNumber}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status: ${localizedOrderStatus(l10n, full.status)}'),
                  const SizedBox(height: 6),
                  Text('Customer: ${_customerName(data)}'),
                  const SizedBox(height: 6),
                  Text('Mobile: ${_mobile(data, addr)}'),
                  const SizedBox(height: 6),
                  Text('District: ${_district(addr)}'),
                  const SizedBox(height: 6),
                  Text('Address details: ${_addressDetails(addr)}'),
                  const Divider(height: 24),
                  ...full.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${i.name}  x${i.quantity}  •  ${i.price.toStringAsFixed(2)}'),
                    ),
                  ),
                  const Divider(height: 24),
                  Text('Subtotal: ${full.subtotal.toStringAsFixed(2)}'),
                  Text('Delivery: ${full.deliveryFee.toStringAsFixed(2)}'),
                  Text('Discount: ${full.discountAmount.toStringAsFixed(2)}'),
                  Text(
                    'Total: ${full.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  String _customerName(Map<String, dynamic> raw) {
    final customer = raw['customerId'];
    if (customer is Map && customer['name'] != null && customer['name'].toString().trim().isNotEmpty) {
      return customer['name'].toString();
    }
    final guest = raw['guestName']?.toString().trim() ?? '';
    return guest.isNotEmpty ? guest : 'Guest';
  }

  String _district(Map<String, dynamic> addr) {
    final city = addr['city']?.toString().trim() ?? '';
    if (city.isNotEmpty) return city;
    final region = addr['region']?.toString().trim() ?? '';
    if (region.isNotEmpty) return region;
    return '-';
  }

  String _mobile(Map<String, dynamic> raw, Map<String, dynamic> addr) {
    final customer = raw['customerId'];
    if (customer is Map) {
      final phone = customer['phone']?.toString().trim() ?? '';
      if (phone.isNotEmpty) return phone;
    }
    final deliveryPhone = addr['phone']?.toString().trim() ?? '';
    if (deliveryPhone.isNotEmpty) return deliveryPhone;
    final guestPhone = raw['guestPhone']?.toString().trim() ?? '';
    if (guestPhone.isNotEmpty) return guestPhone;
    return '-';
  }

  String _addressDetails(Map<String, dynamic> addr) {
    final line1 = addr['line1']?.toString().trim() ?? '';
    if (line1.isNotEmpty) return line1;
    final line2 = addr['line2']?.toString().trim() ?? '';
    if (line2.isNotEmpty) return line2;
    return '-';
  }

  String _orderTimeLabel(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  List<String> _districtOptions() {
    final set = <String>{};
    for (final raw in _rows) {
      final o = Order.fromJson(raw);
      final addr = o.deliveryAddress ?? const <String, dynamic>{};
      final d = _district(addr);
      if (d.isNotEmpty && d != '-') set.add(d);
    }
    final list = set.toList()..sort();
    return ['all', ...list];
  }

  bool _matchesSearch(Map<String, dynamic> raw, String q) {
    if (q.isEmpty) return true;
    final o = Order.fromJson(raw);
    final addr = o.deliveryAddress ?? const <String, dynamic>{};
    final haystack = [
      o.orderNumber,
      _customerName(raw),
      _mobile(raw, addr),
    ].join(' ').toLowerCase();
    return haystack.contains(q);
  }

  List<Map<String, dynamic>> _filteredRows() {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _rows.where((raw) {
      final o = Order.fromJson(raw);
      final addr = o.deliveryAddress ?? const <String, dynamic>{};
      if (_statusFilters.isNotEmpty && !_statusFilters.contains(o.status)) return false;
      if (_districtFilters.isNotEmpty && !_districtFilters.contains(_district(addr))) return false;
      if (_dayFilter != null) {
        final d = _dayFilter!;
        final sameDay = o.createdAt.year == d.year &&
            o.createdAt.month == d.month &&
            o.createdAt.day == d.day;
        if (!sameDay) return false;
      }
      return _matchesSearch(raw, q);
    }).toList();
  }

  Future<void> _pickStatuses() async {
    final selected = Set<String>.from(_statusFilters);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Filter by status'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses
                  .map(
                    (s) => FilterChip(
                      label: Text(s == 'on_the_way' ? 'On the way' : '${s[0].toUpperCase()}${s.substring(1)}'),
                      selected: selected.contains(s),
                      onSelected: (v) {
                        setModal(() {
                          if (v) {
                            selected.add(s);
                          } else {
                            selected.remove(s);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                selected.clear();
                Navigator.pop(ctx, selected);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _statusFilters
        ..clear()
        ..addAll(result);
    });
  }

  Future<void> _pickDistricts(List<String> options) async {
    final selected = Set<String>.from(_districtFilters);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: const Text('Filter by district'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map(
                    (d) => FilterChip(
                      label: Text(d),
                      selected: selected.contains(d),
                      onSelected: (v) {
                        setModal(() {
                          if (v) {
                            selected.add(d);
                          } else {
                            selected.remove(d);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                selected.clear();
                Navigator.pop(ctx, selected);
              },
              child: const Text('Clear'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, selected),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _districtFilters
        ..clear()
        ..addAll(result);
    });
  }

  int _countIn(List<Map<String, dynamic>> rows, String status) =>
      rows.where((r) => (r['status']?.toString() ?? '') == status).length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(onPressed: _load, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    final w = MediaQuery.sizeOf(context).width;
    final isDesktop = w >= AppBreakpoints.tablet;
    final pad = AppSpacing.pagePaddingX(w);

    final filtered = _filteredRows();
    final districtOptions = _districtOptions().where((d) => d != 'all').toList();
    final stats = <({String label, int count})>[
      (label: 'Pending', count: _countIn(filtered, 'pending')),
      (label: 'Confirmed', count: _countIn(filtered, 'confirmed')),
      (label: 'Preparing', count: _countIn(filtered, 'preparing')),
      (label: 'On the way', count: _countIn(filtered, 'on_the_way')),
      (label: 'Delivered', count: _countIn(filtered, 'delivered')),
      (label: 'Cancelled', count: _countIn(filtered, 'cancelled')),
      (label: 'Total', count: filtered.length),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              SizedBox(
                width: isDesktop ? 320 : w - (pad * 2),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Search orders',
                    hintText: 'Order # / Customer / Mobile',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  onPressed: districtOptions.isEmpty ? null : () => _pickDistricts(districtOptions),
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: Text(
                    _districtFilters.isEmpty
                        ? 'District: All'
                        : 'District: ${_districtFilters.length}',
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: OutlinedButton.icon(
                  onPressed: _pickStatuses,
                  icon: const Icon(Icons.tune),
                  label: Text(
                    _statusFilters.isEmpty
                        ? 'Status: All'
                        : 'Status: ${_statusFilters.length}',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: _dayFilter ?? DateTime.now(),
                    );
                    if (picked == null) return;
                    setState(() => _dayFilter = DateTime(picked.year, picked.month, picked.day));
                  },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _dayFilter == null
                        ? 'Date: All'
                        : 'Date: ${_dayFilter!.year}-${_dayFilter!.month.toString().padLeft(2, '0')}-${_dayFilter!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              if (_dayFilter != null || _statusFilters.isNotEmpty || _districtFilters.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dayFilter = null;
                      _statusFilters.clear();
                      _districtFilters.clear();
                    });
                  },
                  child: const Text('Clear filters'),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: stats
                .map(
                  (s) => _StatCard(
                    label: s.label,
                    value: s.count,
                    compact: !isDesktop,
                  ),
                )
                .toList(),
          ),
          SizedBox(height: AppSpacing.lg),
          ...filtered.map((raw) {
            final o = Order.fromJson(raw);
            final addr = o.deliveryAddress ?? const <String, dynamic>{};
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${o.orderNumber}  •  ${_orderTimeLabel(o.createdAt)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('Customer: ${_customerName(raw)}'),
                    Text('District: ${_district(addr)}'),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: isDesktop ? 210 : 190,
                          child: DropdownButtonFormField<String>(
                            initialValue: _statuses.contains(o.status) ? o.status : 'pending',
                            decoration: const InputDecoration(
                              labelText: 'Order status',
                              isDense: true,
                            ),
                            items: _statuses
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s == 'on_the_way'
                                          ? 'On the way'
                                          : '${s[0].toUpperCase()}${s.substring(1)}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v == null || v == o.status) return;
                              _updateStatus(o, v);
                            },
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _openDetails(o),
                          child: const Text('Order details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.compact});

  final String label;
  final int value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 104 : 122,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
