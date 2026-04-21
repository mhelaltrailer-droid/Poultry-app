import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../data/api_client.dart';

class AdminStockScreen extends StatefulWidget {
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends State<AdminStockScreen> {
  List<dynamic> _rows = [];
  String? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _err = null;
      _loading = true;
    });
    try {
      final data = await context.read<ApiClient>().get('/api/admin/products', auth: true);
      if (data is List) setState(() => _rows = data);
    } on ApiException catch (e) {
      setState(() => _err = e.message);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveRow(String id, int stock, int maxQ) async {
    try {
      await context.read<ApiClient>().patch(
            '/api/admin/products/$id',
            {'stock': stock, 'maxOrderQty': maxQ},
            auth: true,
          );
      if (mounted) {
        final loc = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.adminStockUpdated)),
        );
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _edit(Map<String, dynamic> m) async {
    final l10n = context.l10n;
    final id = m['_id']?.toString() ?? '';
    if (id.isEmpty) return;
    final stockCtrl = TextEditingController(text: '${m['stock'] ?? 0}');
    final maxCtrl = TextEditingController(text: '${m['maxOrderQty'] ?? 50}');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adminStockDialogTitle('${m['name'] ?? ''}')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockCtrl,
              decoration: InputDecoration(labelText: l10n.adminStock),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: maxCtrl,
              decoration: InputDecoration(labelText: l10n.adminMaxOrderQty),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final stock = int.parse(stockCtrl.text.trim());
      final maxQ = int.parse(maxCtrl.text.trim());
      await _saveRow(id, stock, maxQ);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.adminEnterIntegers)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_err != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_err!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: _rows.map((raw) {
          final m = Map<String, dynamic>.from(raw as Map);
          final id = m['_id']?.toString() ?? '';
          return Card(
            child: ListTile(
              title: Text('${m['name'] ?? '—'}'),
              subtitle: Text(
                l10n.stockCardSubtitle(
                  '${m['stock'] ?? 0}',
                  '${m['maxOrderQty'] ?? 50}',
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: id.isEmpty ? null : () => _edit(m),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
