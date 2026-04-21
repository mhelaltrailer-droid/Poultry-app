import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/app_spacing.dart';
import '../../data/api_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 29));
  DateTime _to = DateTime.now();
  bool _loading = false;
  String? _error;
  int _tab = 0;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _endpointForTab() {
    switch (_tab) {
      case 0:
        return '/api/admin/analytics/sales';
      case 1:
        return '/api/admin/analytics/products';
      case 2:
        return '/api/admin/analytics/customers';
      default:
        return '/api/admin/analytics/orders';
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<ApiClient>().get(
            _endpointForTab(),
            auth: true,
            query: {'from': _fmt(_from), 'to': _fmt(_to)},
          );
      if (!mounted) return;
      setState(() => _data = Map<String, dynamic>.from(data as Map));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: _to,
      initialDate: _from,
    );
    if (picked == null) return;
    setState(() => _from = DateTime(picked.year, picked.month, picked.day));
    await _load();
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: _from,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _to,
    );
    if (picked == null) return;
    setState(() => _to = DateTime(picked.year, picked.month, picked.day));
    await _load();
  }

  Widget _kv(String k, String v) {
    return Card(
      child: ListTile(
        title: Text(k),
        trailing: Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _salesView(Map<String, dynamic> d) {
    final topDay = Map<String, dynamic>.from((d['topDay'] as Map?) ?? {});
    final topDistrict = Map<String, dynamic>.from((d['topDistrict'] as Map?) ?? {});
    final totalSales = (d['totalSales'] as num?)?.toDouble() ?? 0;
    final avgOrder = (d['averageOrder'] as num?)?.toDouble() ?? 0;
    final topDaySales = (topDay['sales'] as num?)?.toDouble() ?? 0;
    return Column(
      children: [
        _kv('إجمالي مبيعات المدة', totalSales.toStringAsFixed(2)),
        _kv('أعلى يوم مبيعات', '${topDay['day'] ?? '-'} (${topDaySales.toStringAsFixed(2)})'),
        _kv('متوسط سعر الأوردر', avgOrder.toStringAsFixed(2)),
        _kv('أكثر District', '${topDistrict['district'] ?? '-'} (${topDistrict['count'] ?? 0})'),
      ],
    );
  }

  Widget _productsView(Map<String, dynamic> d) {
    final items = (d['items'] as List?) ?? const [];
    if (items.isEmpty) return const Text('لا توجد بيانات في هذه المدة');
    return Column(
      children: items
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (m) => Card(
              child: ListTile(
                title: Text(m['name']?.toString() ?? '-'),
                trailing: Text('${m['quantity'] ?? 0}'),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _customersView(Map<String, dynamic> d) {
    final topByOrders = (d['topByOrders'] as List?) ?? const [];
    final topByAmount = (d['topByAmount'] as List?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('عملاء لم يطلبوا منذ أكثر من 30 يوم', '${d['inactiveOver30Days'] ?? 0}'),
        _kv('عدد العملاء الجدد', '${d['newCustomersCount'] ?? 0}'),
        const SizedBox(height: AppSpacing.sm),
        const Text('أكثر 10 عملاء (عدد الأوردرات)', style: TextStyle(fontWeight: FontWeight.w700)),
        ...topByOrders.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return ListTile(
            dense: true,
            title: Text(m['name']?.toString() ?? '-'),
            trailing: Text('${m['orderCount'] ?? 0}'),
          );
        }),
        const Divider(),
        const Text('أكثر 10 عملاء (أكبر قيمة مالية)', style: TextStyle(fontWeight: FontWeight.w700)),
        ...topByAmount.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return ListTile(
            dense: true,
            title: Text(m['name']?.toString() ?? '-'),
            trailing: Text('${m['totalAmount'] ?? 0}'),
          );
        }),
      ],
    );
  }

  Widget _ordersView(Map<String, dynamic> d) {
    final byDistrict = (d['byDistrict'] as List?) ?? const [];
    final reasons = (d['cancellationReasons'] as List?) ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kv('عدد الطلبات في المدة', '${d['totalOrders'] ?? 0}'),
        _kv('عدد الطلبات الملغية', '${d['cancelledOrders'] ?? 0}'),
        const SizedBox(height: AppSpacing.sm),
        const Text('أسباب الإلغاء', style: TextStyle(fontWeight: FontWeight.w700)),
        ...reasons.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return ListTile(
            dense: true,
            title: Text(m['reason']?.toString() ?? '-'),
            trailing: Text('${m['count'] ?? 0}'),
          );
        }),
        const Divider(),
        const Text('عدد الطلبات من كل District', style: TextStyle(fontWeight: FontWeight.w700)),
        ...byDistrict.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return ListTile(
            dense: true,
            title: Text(m['district']?.toString() ?? '-'),
            trailing: Text('${m['count'] ?? 0}'),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data ?? const <String, dynamic>{};
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: _pickFrom,
                icon: const Icon(Icons.date_range),
                label: Text('من: ${_fmt(_from)}'),
              ),
              OutlinedButton.icon(
                onPressed: _pickTo,
                icon: const Icon(Icons.date_range),
                label: Text('إلى: ${_fmt(_to)}'),
              ),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Sales')),
              ButtonSegment(value: 1, label: Text('Products')),
              ButtonSegment(value: 2, label: Text('Customers')),
              ButtonSegment(value: 3, label: Text('Orders')),
            ],
            selected: {_tab},
            onSelectionChanged: (s) async {
              setState(() => _tab = s.first);
              await _load();
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, textAlign: TextAlign.center))
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        if (_tab == 0) _salesView(data),
                        if (_tab == 1) _productsView(data),
                        if (_tab == 2) _customersView(data),
                        if (_tab == 3) _ordersView(data),
                      ],
                    ),
        ),
      ],
    );
  }
}
