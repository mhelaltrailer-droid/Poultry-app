import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../data/api_client.dart';

class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
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
      final data = await context.read<ApiClient>().get('/api/admin/customers', auth: true);
      if (data is List) setState(() => _rows = data);
    } on ApiException catch (e) {
      setState(() => _err = e.message);
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openForm([Map<String, dynamic>? existing]) async {
    final l10n = context.l10n;
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone']?.toString() ?? '');
    final districtCtrl = TextEditingController(text: existing?['district']?.toString() ?? '');
    final addrCtrl = TextEditingController(text: existing?['addressDetail']?.toString() ?? '');
    final passCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? l10n.adminNewCustomer : l10n.adminEditCustomer,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: l10n.labelName),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(labelText: l10n.phoneNumber),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: districtCtrl,
                decoration: InputDecoration(labelText: l10n.adminDistrict),
              ),
              TextField(
                controller: addrCtrl,
                decoration: InputDecoration(labelText: l10n.adminAddressDetail),
                maxLines: 2,
              ),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: existing == null
                      ? l10n.adminPassword
                      : l10n.adminPasswordOptional,
                ),
              ),
            ],
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
    );
    if (ok != true || !mounted) return;
    if (existing == null && passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminEnterPasswordNewCustomer)),
      );
      return;
    }

    try {
      final api = context.read<ApiClient>();
      final id = existing?['_id']?.toString();
      if (id == null) {
        await api.post(
          '/api/admin/customers',
          {
            'name': nameCtrl.text.trim(),
            'phone': phoneCtrl.text.trim(),
            'password': passCtrl.text,
            'district': districtCtrl.text.trim(),
            'addressDetail': addrCtrl.text.trim(),
          },
          auth: true,
        );
      } else {
        final body = <String, dynamic>{
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'district': districtCtrl.text.trim(),
          'addressDetail': addrCtrl.text.trim(),
        };
        if (passCtrl.text.isNotEmpty) body['password'] = passCtrl.text;
        await api.patch('/api/admin/customers/$id', body, auth: true);
      }
      await _load();
      if (mounted) {
        final loc = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.savedSnack)),
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
      builder: (ctx) {
        final loc = ctx.l10n;
        return AlertDialog(
          title: Text(loc.adminDeleteCustomerTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc.no),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
    if (yes != true) return;
    try {
      await context.read<ApiClient>().delete('/api/admin/customers/$id', auth: true);
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
        children: [
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(l10n.adminAddCustomer),
          ),
          const SizedBox(height: 16),
          ..._rows.map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            final id = m['_id']?.toString() ?? '';
            return Card(
              child: ExpansionTile(
                title: Text(m['name']?.toString().isNotEmpty == true ? '${m['name']}' : '—'),
                subtitle: Text('${m['phone'] ?? '—'}'),
                children: [
                  ListTile(
                    title: Text(l10n.adminCustomerDistrictTitle),
                    subtitle: Text(m['district']?.toString().isNotEmpty == true ? '${m['district']}' : '—'),
                  ),
                  ListTile(
                    title: Text(l10n.adminCustomerAddressTitle),
                    subtitle: Text(
                      m['addressDetail']?.toString().isNotEmpty == true ? '${m['addressDetail']}' : '—',
                    ),
                  ),
                  OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: 8,
                    overflowSpacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openForm(m),
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.edit),
                      ),
                      TextButton.icon(
                        onPressed: id.isEmpty ? null : () => _delete(id),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.delete),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
