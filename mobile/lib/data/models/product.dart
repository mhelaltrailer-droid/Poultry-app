class Product {
  Product({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.description,
    this.descriptionEn,
    this.descriptionAr,
    required this.images,
    required this.price,
    this.salePrice,
    required this.weightValue,
    required this.weightUnit,
    required this.stock,
    required this.maxOrderQty,
    required this.category,
    required this.isActive,
  });

  final String id;
  /// Default / fallback name (also used for slug on server).
  final String name;
  final String? nameEn;
  final String? nameAr;
  final String description;
  final String? descriptionEn;
  final String? descriptionAr;
  final List<String> images;
  final double price;
  final double? salePrice;
  final double weightValue;
  final String weightUnit;
  final int stock;
  final int maxOrderQty;
  final String category;
  final bool isActive;

  double get unitPrice => salePrice ?? price;

  int get maxSelectableQty {
    if (stock < 1) return 0;
    final cap = maxOrderQty < 1 ? 50 : maxOrderQty;
    return stock < cap ? stock : cap;
  }

  static String? _optString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// BCP47 language code, e.g. `ar`, `en`.
  String localizedName(String languageCode) {
    final ar = languageCode.toLowerCase().startsWith('ar');
    if (ar) {
      final t = nameAr;
      if (t != null && t.isNotEmpty) return t;
    } else {
      final t = nameEn;
      if (t != null && t.isNotEmpty) return t;
    }
    return name;
  }

  String localizedDescription(String languageCode, String emptyFallback) {
    final ar = languageCode.toLowerCase().startsWith('ar');
    if (ar) {
      final t = descriptionAr;
      if (t != null && t.isNotEmpty) return t;
    } else {
      final t = descriptionEn;
      if (t != null && t.isNotEmpty) return t;
    }
    final d = description.trim();
    if (d.isNotEmpty) return d;
    return emptyFallback;
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    final id = j['_id'] as String? ?? j['id'] as String? ?? '';
    final sp = j['salePrice'];
    return Product(
      id: id,
      name: j['name'] as String,
      nameEn: _optString(j['nameEn']),
      nameAr: _optString(j['nameAr']),
      description: (j['description'] as String?) ?? '',
      descriptionEn: _optString(j['descriptionEn']),
      descriptionAr: _optString(j['descriptionAr']),
      images: List<String>.from(j['images'] as List? ?? const []),
      price: (j['price'] as num).toDouble(),
      salePrice: sp == null ? null : (sp as num).toDouble(),
      weightValue: (j['weightValue'] as num).toDouble(),
      weightUnit: (j['weightUnit'] as String?) ?? 'kg',
      stock: (j['stock'] as num?)?.toInt() ?? 0,
      maxOrderQty: (j['maxOrderQty'] as num?)?.toInt() ?? 50,
      category: (j['category'] as String?) ?? 'poultry',
      isActive: j['isActive'] as bool? ?? true,
    );
  }

  String get weightLabel => '$weightValue$weightUnit';
}
