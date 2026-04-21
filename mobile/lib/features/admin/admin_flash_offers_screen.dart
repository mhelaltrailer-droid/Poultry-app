import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/api_client.dart';
import '../../data/models/product.dart';

class AdminFlashOffersScreen extends StatefulWidget {
  const AdminFlashOffersScreen({super.key});

  @override
  State<AdminFlashOffersScreen> createState() => _AdminFlashOffersScreenState();
}

class _AdminFlashOffersScreenState extends State<AdminFlashOffersScreen> {
  List<dynamic> _offers = [];
  List<Product> _products = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final data = await api.get('/api/admin/flash-offers', auth: true) as List<dynamic>;
      final productsData = await api.get('/api/admin/products', auth: true) as List<dynamic>;
      setState(() {
        _offers = data;
        _products = productsData
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Map<String, dynamic>? existing]) async {
    final titleCtrl = TextEditingController(text: existing?['title']?.toString() ?? '');
    final imageCtrl = TextEditingController(text: existing?['imageUrl']?.toString() ?? '');
    final beforeCtrl = TextEditingController(
      text: existing != null ? '${existing['originalPrice'] ?? ''}' : '',
    );
    final afterCtrl = TextEditingController(
      text: existing != null ? '${existing['discountedPrice'] ?? ''}' : '',
    );
    final maxQtyCtrl = TextEditingController(
      text: existing != null ? '${existing['maxQtyPerOrder'] ?? 1}' : '1',
    );
    final totalAvailableCtrl = TextEditingController(
      text: existing != null ? '${existing['totalAvailable'] ?? 1}' : '1',
    );
    final totalUsedCtrl = TextEditingController(
      text: existing != null ? '${existing['totalUsed'] ?? 0}' : '0',
    );
    final startCtrl = TextEditingController(
      text: existing?['startsAt']?.toString().replaceFirst('Z', '') ?? '',
    );
    final endCtrl = TextEditingController(
      text: existing?['endsAt']?.toString().replaceFirst('Z', '') ?? '',
    );
    var enabled = existing?['isEnabled'] as bool? ?? true;
    final selectedProductIds = <String>{
      ...List<dynamic>.from(existing?['productIds'] as List? ?? const [])
          .map((e) => (e is Map ? e['_id'] : e).toString()),
    };
    final l10n = context.l10n;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(existing == null ? 'Add Flash Offer' : 'Edit Flash Offer'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogContentMaxWidth(ctx)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Offer title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageCtrl,
                    decoration: const InputDecoration(labelText: 'Offer image URL'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: beforeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price before discount'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: afterCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price after discount'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Starts at (ISO/date)',
                      hintText: '2026-04-06T10:00:00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ends at (ISO/date)',
                      hintText: '2026-04-06T22:00:00',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: maxQtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max qty / order',
                      hintText: 'e.g. 1',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalAvailableCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total available',
                      hintText: 'e.g. 100',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalUsedCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total used',
                      hintText: 'e.g. 0',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: enabled,
                    onChanged: (v) => setModal(() => enabled = v),
                    title: const Text('Enabled'),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Products in this offer',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _products.map((p) {
                            final selected = selectedProductIds.contains(p.id);
                            return FilterChip(
                              selected: selected,
                              label: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onSelected: (v) {
                                setModal(() {
                                  if (v) {
                                    selectedProductIds.add(p.id);
                                  } else {
                                    selectedProductIds.remove(p.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      ),
    );
    if (ok != true || !mounted) return;

    if (selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one product')),
      );
      return;
    }

    DateTime? startsAt;
    DateTime? endsAt;
    double beforePrice;
    double afterPrice;
    int maxQty;
    int totalAvailable;
    int totalUsed;
    try {
      startsAt = DateTime.parse(startCtrl.text.trim());
      endsAt = DateTime.parse(endCtrl.text.trim());
      beforePrice = double.parse(beforeCtrl.text.trim().replaceAll(',', '.'));
      afterPrice = double.parse(afterCtrl.text.trim().replaceAll(',', '.'));
      maxQty = int.parse(maxQtyCtrl.text.trim());
      totalAvailable = int.parse(totalAvailableCtrl.text.trim());
      totalUsed = int.parse(totalUsedCtrl.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check numbers/date format')),
      );
      return;
    }

    final body = {
      'title': titleCtrl.text.trim(),
      'imageUrl': imageCtrl.text.trim(),
      'productIds': selectedProductIds.toList(),
      'originalPrice': beforePrice,
      'discountedPrice': afterPrice,
      'startsAt': startsAt.toUtc().toIso8601String(),
      'endsAt': endsAt.toUtc().toIso8601String(),
      'maxQtyPerOrder': maxQty,
      'totalAvailable': totalAvailable,
      'totalUsed': totalUsed,
      'isEnabled': enabled,
    };

    try {
      final api = context.read<ApiClient>();
      final id = existing?['_id']?.toString();
      if (id == null || id.isEmpty) {
        await api.post('/api/admin/flash-offers', body, auth: true);
      } else {
        await api.patch('/api/admin/flash-offers/$id', body, auth: true);
      }
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedSnack)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(String id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this flash offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await context.read<ApiClient>().delete('/api/admin/flash-offers/$id', auth: true);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _toggle(String id) async {
    try {
      await context.read<ApiClient>().patch('/api/admin/flash-offers/$id/toggle', null, auth: true);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

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
            FilledButton(
              onPressed: _load,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.flash_on),
            label: const Text('Add Flash Offer'),
          ),
          const SizedBox(height: 14),
          ..._offers.map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            final id = m['_id']?.toString() ?? '';
            final products = List<dynamic>.from(m['productIds'] as List? ?? const []);
            final names = products
                .whereType<Map>()
                .map((x) => (x['name'] ?? '').toString())
                .where((x) => x.isNotEmpty)
                .toList();
            final isLive = m['isLive'] == true;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isLive ? const Color(0xFFC5A059) : Colors.grey.shade500,
                  child: const Icon(Icons.local_offer, color: Colors.white),
                ),
                title: Text(m['title']?.toString() ?? 'Offer'),
                subtitle: Text(
                  'Before ${m['originalPrice']}  •  After ${m['discountedPrice']}\n'
                  'Products: ${names.isEmpty ? '-' : names.join(', ')}\n'
                  'Remaining: ${m['remainingCount'] ?? 0}  •  ${isLive ? 'LIVE' : 'INACTIVE'}',
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _openForm(m);
                    if (v == 'toggle' && id.isNotEmpty) _toggle(id);
                    if (v == 'delete' && id.isNotEmpty) _delete(id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      enabled: id.isNotEmpty,
                      child: Text((m['isEnabled'] == true) ? 'Disable' : 'Enable'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      enabled: id.isNotEmpty,
                      child: Text(l10n.delete),
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
