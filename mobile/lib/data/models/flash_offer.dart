import 'product.dart';

class FlashOffer {
  FlashOffer({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.products,
    required this.originalPrice,
    required this.discountedPrice,
    required this.startsAt,
    required this.endsAt,
    required this.maxQtyPerOrder,
    required this.totalAvailable,
    required this.totalUsed,
    required this.isEnabled,
    required this.isLive,
    required this.remainingCount,
  });

  final String id;
  final String title;
  final String imageUrl;
  final List<Product> products;
  final double originalPrice;
  final double discountedPrice;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxQtyPerOrder;
  final int totalAvailable;
  final int totalUsed;
  final bool isEnabled;
  final bool isLive;
  final int remainingCount;

  factory FlashOffer.fromJson(Map<String, dynamic> j) {
    final rawProducts = List<dynamic>.from(j['productIds'] as List? ?? const []);
    return FlashOffer(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      imageUrl: (j['imageUrl'] ?? '').toString(),
      products: rawProducts
          .whereType<Map>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      originalPrice: (j['originalPrice'] as num?)?.toDouble() ?? 0,
      discountedPrice: (j['discountedPrice'] as num?)?.toDouble() ?? 0,
      startsAt: DateTime.tryParse((j['startsAt'] ?? '').toString()) ?? DateTime.now(),
      endsAt: DateTime.tryParse((j['endsAt'] ?? '').toString()) ?? DateTime.now(),
      maxQtyPerOrder: (j['maxQtyPerOrder'] as num?)?.toInt() ?? 1,
      totalAvailable: (j['totalAvailable'] as num?)?.toInt() ?? 0,
      totalUsed: (j['totalUsed'] as num?)?.toInt() ?? 0,
      isEnabled: j['isEnabled'] as bool? ?? false,
      isLive: j['isLive'] as bool? ?? false,
      remainingCount: (j['remainingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
