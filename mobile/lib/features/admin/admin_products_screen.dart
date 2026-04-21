import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_context.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../data/api_client.dart';
import '../../data/models/product.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
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

  Future<void> _openForm([Map<String, dynamic>? existing]) async {
    final l10n = context.l10n;
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final nameEnCtrl = TextEditingController(text: existing?['nameEn']?.toString() ?? '');
    final nameArCtrl = TextEditingController(text: existing?['nameAr']?.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?['description']?.toString() ?? '');
    final descEnCtrl = TextEditingController(text: existing?['descriptionEn']?.toString() ?? '');
    final descArCtrl = TextEditingController(text: existing?['descriptionAr']?.toString() ?? '');
    final priceCtrl = TextEditingController(
      text: existing != null ? '${existing['price']}' : '0',
    );
    final saleCtrl = TextEditingController(
      text: existing != null && existing['salePrice'] != null ? '${existing['salePrice']}' : '',
    );
    final imgCtrl = TextEditingController();
    final weightCtrl = TextEditingController(
      text: existing != null ? '${existing['weightValue'] ?? 1}' : '1',
    );
    var unit = (existing?['weightUnit'] as String?) ?? 'kg';
    final stockCtrl = TextEditingController(
      text: existing != null ? '${existing['stock'] ?? 0}' : '0',
    );
    final maxQCtrl = TextEditingController(
      text: existing != null ? '${existing['maxOrderQty'] ?? 50}' : '50',
    );
    final catCtrl = TextEditingController(text: existing?['category']?.toString() ?? 'poultry');
    var active = existing?['isActive'] as bool? ?? true;

    List<String> images = List<String>.from(existing?['images'] as List? ?? const []);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          title: Text(
            existing == null ? l10n.adminNewProduct : l10n.adminEditProduct,
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: dialogContentMaxWidth(ctx),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: l10n.adminProductName),
                  ),
                  TextField(
                    controller: nameEnCtrl,
                    decoration: InputDecoration(labelText: l10n.adminNameEnglish),
                  ),
                  TextField(
                    controller: nameArCtrl,
                    decoration: InputDecoration(labelText: l10n.adminNameArabic),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(labelText: l10n.adminDescription),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: descEnCtrl,
                    decoration: InputDecoration(labelText: l10n.adminDescriptionEnglish),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: descArCtrl,
                    decoration: InputDecoration(labelText: l10n.adminDescriptionArabic),
                    maxLines: 2,
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: InputDecoration(labelText: l10n.adminPrice),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: saleCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.adminSalePriceHint,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: weightCtrl,
                    decoration: InputDecoration(labelText: l10n.adminWeightQty),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: unit,
                    decoration: InputDecoration(labelText: l10n.adminWeightUnit),
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'lb', child: Text('lb')),
                      DropdownMenuItem(value: 'piece', child: Text('piece')),
                    ],
                    onChanged: (v) => setModal(() => unit = v ?? 'kg'),
                  ),
                  TextField(
                    controller: stockCtrl,
                    decoration: InputDecoration(labelText: l10n.adminStock),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: maxQCtrl,
                    decoration: InputDecoration(labelText: l10n.adminMaxOrderQty),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: catCtrl,
                    decoration: InputDecoration(labelText: l10n.adminCategory),
                  ),
                  DropdownButtonFormField<String>(
                    value: active ? 'yes' : 'no',
                    decoration: InputDecoration(labelText: l10n.adminActive),
                    items: [
                      DropdownMenuItem(value: 'yes', child: Text(l10n.adminYes)),
                      DropdownMenuItem(value: 'no', child: Text(l10n.adminNo)),
                    ],
                    onChanged: (v) => setModal(() => active = v == 'yes'),
                  ),
                  TextField(
                    controller: imgCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.adminImageUrlHint,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        final u = imgCtrl.text.trim();
                        if (u.isEmpty) return;
                        setModal(() {
                          images = [...images, u];
                          imgCtrl.clear();
                        });
                      },
                      child: Text(l10n.adminAddImageUrlButton),
                    ),
                  ),
                  if (images.isNotEmpty)
                    Text(
                      images.join('\n'),
                      style: const TextStyle(fontSize: 11),
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

    double price;
    double weight;
    int stock;
    int maxQ;
    try {
      price = double.parse(priceCtrl.text.replaceAll(',', '.'));
      weight = double.parse(weightCtrl.text.replaceAll(',', '.'));
      stock = int.parse(stockCtrl.text.trim());
      maxQ = int.parse(maxQCtrl.text.trim());
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminCheckNumbers)),
      );
      return;
    }

    double? sale;
    final saleT = saleCtrl.text.trim();
    if (saleT.isNotEmpty) {
      try {
        sale = double.parse(saleT.replaceAll(',', '.'));
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.adminInvalidSalePrice)),
        );
        return;
      }
    }

    final body = <String, dynamic>{
      'name': nameCtrl.text.trim(),
      'nameEn': nameEnCtrl.text.trim(),
      'nameAr': nameArCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'descriptionEn': descEnCtrl.text.trim(),
      'descriptionAr': descArCtrl.text.trim(),
      'images': images,
      'price': price,
      'salePrice': sale,
      'weightValue': weight,
      'weightUnit': unit,
      'stock': stock,
      'maxOrderQty': maxQ,
      'category': catCtrl.text.trim(),
      'isActive': active,
    };

    try {
      final api = context.read<ApiClient>();
      final id = existing?['_id']?.toString();
      if (id == null) {
        await api.post('/api/admin/products', body, auth: true);
      } else {
        await api.patch('/api/admin/products/$id', body, auth: true);
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
          title: Text(loc.adminDeleteProductTitle),
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
      await context.read<ApiClient>().delete('/api/admin/products/$id', auth: true);
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
    final lang = Localizations.localeOf(context).languageCode;
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
            label: Text(l10n.adminAddProduct),
          ),
          const SizedBox(height: 16),
          ..._rows.map((raw) {
            final m = Map<String, dynamic>.from(raw as Map);
            final id = m['_id']?.toString() ?? '';
            final sp = m['salePrice'];
            final unit = sp != null ? (sp as num).toDouble() : null;
            return Card(
              child: ListTile(
                title: Text(
                  Product.fromJson(m).localizedName(lang),
                ),
                subtitle: Text(
                  unit != null
                      ? l10n.productCardSubtitleSale(
                          '${m['price']}',
                          '$unit',
                          '${m['stock']}',
                        )
                      : l10n.productCardSubtitle(
                          '${m['price']}',
                          '${m['stock']}',
                        ),
                ),
                isThreeLine: true,
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
