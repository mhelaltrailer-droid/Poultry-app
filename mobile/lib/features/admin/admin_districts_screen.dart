import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../data/api_client.dart';

class AdminDistrictsScreen extends StatefulWidget {
  const AdminDistrictsScreen({super.key});

  @override
  State<AdminDistrictsScreen> createState() => _AdminDistrictsScreenState();
}

class _AdminDistrictsScreenState extends State<AdminDistrictsScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

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
      final data = await context.read<ApiClient>().get('/api/admin/districts', auth: true) as List<dynamic>;
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

  Future<void> _openForm([Map<String, dynamic>? existing]) async {
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final sortCtrl = TextEditingController(text: '${existing?['sortOrder'] ?? 0}');
    var active = existing?['isActive'] as bool? ?? true;
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(existing == null ? 'Add District' : 'Edit District'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'District name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sortCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sort order'),
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: active,
                onChanged: (v) => setModal(() => active = v),
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
      ),
    );
    if (ok != true || !mounted) return;
    int sort;
    try {
      sort = int.parse(sortCtrl.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sort order must be a number')),
      );
      return;
    }
    final body = {
      'name': nameCtrl.text.trim(),
      'sortOrder': sort,
      'isActive': active,
    };
    try {
      final api = context.read<ApiClient>();
      final id = existing?['_id']?.toString();
      if (id == null || id.isEmpty) {
        await api.post('/api/admin/districts', body, auth: true);
      } else {
        await api.patch('/api/admin/districts/$id', body, auth: true);
      }
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(String id) async {
    try {
      await context.read<ApiClient>().delete('/api/admin/districts/$id', auth: true);
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
    if (_error != null) return Center(child: Text(_error!));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add District'),
          ),
          const SizedBox(height: 12),
          ..._rows.map((d) {
            final id = d['_id']?.toString() ?? '';
            return Card(
              child: ListTile(
                title: Text(d['name']?.toString() ?? ''),
                subtitle: Text('Order: ${d['sortOrder'] ?? 0} • ${d['isActive'] == true ? 'Active' : 'Inactive'}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _openForm(d);
                    if (v == 'delete' && id.isNotEmpty) _delete(id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
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
