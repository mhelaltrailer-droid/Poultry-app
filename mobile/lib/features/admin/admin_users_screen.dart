import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/l10n_formatters.dart';
import '../../data/api_client.dart';

const _roleKeys = ['customer', 'app_admin', 'ops_admin', 'admin'];

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const _districts = <String>[
    'Golf City',
    'الحي السابع',
    'الحي السادس',
    'الحي الخامس',
    'الحي الرابع',
    'الحي الثالث',
    'الحي الثامن',
    'اسكان الشباب',
    'الحي الاول',
    'الحي الثاني',
    'الحي التاسع',
    'الحي الترفيهي',
    'دار مصر',
    'حي المجد',
    'حي الكرامة',
    'سكن مصر (العبور الجديدة)',
    'جمعية احمد عرابي',
  ];
  static const _fixedCity = 'Obour City';

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
      final api = context.read<ApiClient>();
      final data = await api.get('/api/admin/users', auth: true);
      if (data is List) {
        setState(() => _rows = data);
      }
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
    var role = (existing?['role'] as String?) ?? 'ops_admin';
    if (!_roleKeys.contains(role)) role = 'ops_admin';
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final familyCtrl = TextEditingController(text: existing?['familyName']?.toString() ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone']?.toString() ?? '');
    final districtCtrl = TextEditingController(text: existing?['district']?.toString() ?? '');
    final addressCtrl = TextEditingController(text: existing?['addressDetail']?.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?['deliveryNotes']?.toString() ?? '');
    final passCtrl = TextEditingController();
    String? selectedDistrict = districtCtrl.text.trim().isNotEmpty ? districtCtrl.text.trim() : null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(
            existing == null ? l10n.adminNewUser : l10n.adminEditUser,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(labelText: l10n.adminRole),
                  items: _roleKeys
                      .map(
                        (k) => DropdownMenuItem(
                          value: k,
                          child: Text(localizedAdminRole(l10n, k)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setModal(() => role = v ?? 'ops_admin'),
                ),
                const SizedBox(height: 12),
                if (role == 'customer') ...[
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l10n.labelName),
                  ),
                  TextField(
                    controller: familyCtrl,
                    decoration: const InputDecoration(labelText: 'Family Name'),
                  ),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: l10n.phoneNumber),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: existing == null
                          ? l10n.adminPassword
                          : l10n.adminPasswordOptionalUnchanged,
                    ),
                  ),
                  TextFormField(
                    initialValue: _fixedCity,
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDistrict,
                    decoration: const InputDecoration(labelText: 'District'),
                    items: _districts
                        .map((d) => DropdownMenuItem<String>(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) {
                      selectedDistrict = v;
                      districtCtrl.text = v ?? '';
                    },
                  ),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address Details'),
                  ),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Delivery Notes'),
                  ),
                ] else ...[
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
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: existing == null
                          ? l10n.adminPassword
                          : l10n.adminPasswordOptionalUnchanged,
                    ),
                  ),
                ],
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
      ),
    );
    if (ok != true || !mounted) return;

    if (existing == null && passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminEnterPasswordNewUser)),
      );
      return;
    }

    try {
      final api = context.read<ApiClient>();
      final id = existing?['_id']?.toString();
      if (id == null) {
        await api.post(
          '/api/admin/users',
          {
            'name': nameCtrl.text.trim(),
            'familyName': familyCtrl.text.trim(),
            'phone': phoneCtrl.text.trim(),
            'password': passCtrl.text,
            'role': role,
            if (role == 'customer') 'city': _fixedCity,
            if (role == 'customer') 'district': (selectedDistrict ?? districtCtrl.text).trim(),
            if (role == 'customer') 'addressDetail': addressCtrl.text.trim(),
            if (role == 'customer') 'deliveryNotes': notesCtrl.text.trim(),
          },
          auth: true,
        );
      } else {
        final body = <String, dynamic>{
          'name': nameCtrl.text.trim(),
          'familyName': familyCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'role': role,
          if (role == 'customer') 'city': _fixedCity,
          if (role == 'customer') 'district': (selectedDistrict ?? districtCtrl.text).trim(),
          if (role == 'customer') 'addressDetail': addressCtrl.text.trim(),
          if (role == 'customer') 'deliveryNotes': notesCtrl.text.trim(),
        };
        if (passCtrl.text.isNotEmpty) body['password'] = passCtrl.text;
        await api.patch('/api/admin/users/$id', body, auth: true);
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
    final api = context.read<ApiClient>();
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final loc = ctx.l10n;
        return AlertDialog(
          title: Text(loc.adminDeleteUserTitle),
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
      await api.delete('/api/admin/users/$id', auth: true);
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
            icon: const Icon(Icons.add),
            label: Text(l10n.adminAddUser),
          ),
          const SizedBox(height: 16),
          ..._rows.map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            final id = m['_id']?.toString() ?? '';
            final r = m['role'] as String? ?? '';
            return Card(
              child: ListTile(
                title: Text(
                  ((m['name'] as String?)?.trim().isNotEmpty ?? false)
                      ? '${m['name']}'
                      : '—',
                ),
                subtitle: Text(
                  '${m['phone'] ?? '—'} · ${localizedAdminRole(l10n, r)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _openForm(m);
                    if (v == 'delete' && id.isNotEmpty) _delete(id);
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.edit),
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
