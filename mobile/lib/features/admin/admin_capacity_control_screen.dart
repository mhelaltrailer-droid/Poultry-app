import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/app_spacing.dart';
import '../../widgets/app_skeleton.dart';
import '../../data/api_client.dart';

class AdminCapacityControlScreen extends StatefulWidget {
  const AdminCapacityControlScreen({super.key});

  @override
  State<AdminCapacityControlScreen> createState() =>
      _AdminCapacityControlScreenState();
}

class _AdminCapacityControlScreenState extends State<AdminCapacityControlScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _message;
  List<_SlotRow> _slots = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<_SlotRow> _defaultSlots() {
    return List.generate(10, (index) {
      final from = 9 + index;
      final to = from + 1;
      return _SlotRow(
        id: '$from-$to',
        fromHour: from,
        toHour: to,
        capacityController: TextEditingController(text: '30'),
      );
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });
    try {
      final data = await context.read<ApiClient>().get(
            '/api/admin/capacity-control',
            auth: true,
          );
      final map = Map<String, dynamic>.from(data as Map);
      final rawSlots = (map['slots'] as List?) ?? const [];
      final parsed = rawSlots
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (slot) => _SlotRow(
              id: slot['id']?.toString() ?? '',
              fromHour: (slot['fromHour'] as num?)?.toInt() ?? 0,
              toHour: (slot['toHour'] as num?)?.toInt() ?? 0,
              capacityController: TextEditingController(
                text: ((slot['capacity'] as num?)?.toInt() ?? 0).toString(),
              ),
            ),
          )
          .where((slot) => slot.id.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _slots = parsed.isEmpty ? _defaultSlots() : parsed;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _slots = _defaultSlots();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _slots = _defaultSlots();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int get _totalCapacity {
    var sum = 0;
    for (final slot in _slots) {
      final n = int.tryParse(slot.capacityController.text.trim()) ?? 0;
      sum += n < 0 ? 0 : n;
    }
    return sum;
  }

  String _formatHourAr(int hour24) {
    final period = hour24 >= 12 ? 'م' : 'ص';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '${hour12.toString().padLeft(2, '0')} $period';
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
      _error = null;
    });

    final payloadSlots = <Map<String, dynamic>>[];
    for (final slot in _slots) {
      final value = int.tryParse(slot.capacityController.text.trim());
      if (value == null || value < 0) {
        setState(() {
          _saving = false;
          _error = 'Please enter a valid non-negative number for all slots';
        });
        return;
      }
      payloadSlots.add({
        'id': slot.id,
        'fromHour': slot.fromHour,
        'toHour': slot.toHour,
        'capacity': value,
      });
    }

    try {
      await context.read<ApiClient>().put(
            '/api/admin/capacity-control',
            {'slots': payloadSlots},
            auth: true,
          );
      if (!mounted) return;
      setState(() => _message = 'Saved successfully');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final slot in _slots) {
      slot.capacityController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AdminPageSkeleton();
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Manage accepted orders per hour (09:00 ص - 07:00 م)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (_message != null) ...[
            Text(
              _message!,
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          ..._slots.map((slot) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_formatHourAr(slot.fromHour)} : ${_formatHourAr(slot.toHour)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: slot.capacityController,
                        keyboardType: TextInputType.number,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: 'Orders',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Daily Capacity',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '$_totalCapacity',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: Icon(_saving ? Icons.hourglass_top : Icons.save),
            label: Text(_saving ? 'Saving...' : 'Save'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SlotRow {
  _SlotRow({
    required this.id,
    required this.fromHour,
    required this.toHour,
    required this.capacityController,
  });

  final String id;
  final int fromHour;
  final int toHour;
  final TextEditingController capacityController;
}
