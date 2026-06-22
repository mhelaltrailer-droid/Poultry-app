import '../../data/models/product.dart';
import '../../data/models/order.dart';

class CartLine {
  CartLine({
    required this.productId,
    required this.name,
    this.nameEn,
    this.nameAr,
    required this.price,
    required this.quantity,
    this.image,
    this.weightLabel,
  });

  final String productId;
  final String name;
  final String? nameEn;
  final String? nameAr;
  final double price;
  int quantity;
  final String? image;
  final String? weightLabel;

  double get lineTotal => price * quantity;

  static CartLine fromProduct(Product p, {int quantity = 1}) {
    return CartLine(
      productId: p.id,
      name: p.name,
      nameEn: p.nameEn,
      nameAr: p.nameAr,
      price: p.unitPrice,
      quantity: quantity,
      image: p.images.isNotEmpty ? p.images.first : null,
      weightLabel: p.weightLabel,
    );
  }

  static CartLine? fromOrderItem(OrderItem item, {Product? product, int? quantity}) {
    final productId = item.productId;
    if (productId == null || productId.isEmpty) return null;
    if (product != null) {
      return CartLine.fromProduct(product, quantity: quantity ?? item.quantity);
    }
    return CartLine(
      productId: productId,
      name: item.name,
      price: item.price,
      quantity: quantity ?? item.quantity,
      image: item.image,
      weightLabel: item.weightSnapshot,
    );
  }

  CartLine copyWith({int? quantity}) {
    return CartLine(
      productId: productId,
      name: name,
      nameEn: nameEn,
      nameAr: nameAr,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
      weightLabel: weightLabel,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        if (nameEn != null) 'nameEn': nameEn,
        if (nameAr != null) 'nameAr': nameAr,
        'price': price,
        'quantity': quantity,
        'image': image,
        'weightLabel': weightLabel,
      };

  static CartLine fromJson(Map<String, dynamic> j) {
    return CartLine(
      productId: j['productId'] as String,
      name: j['name'] as String,
      nameEn: j['nameEn'] as String?,
      nameAr: j['nameAr'] as String?,
      price: (j['price'] as num).toDouble(),
      quantity: (j['quantity'] as num).toInt(),
      image: j['image'] as String?,
      weightLabel: j['weightLabel'] as String?,
    );
  }
}
