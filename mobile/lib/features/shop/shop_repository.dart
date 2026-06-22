import '../../data/api_client.dart';
import '../../data/models/flash_offer.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../core/app_constants.dart';
import '../cart/cart_model.dart';

class ShopRepository {
  ShopRepository(this._api);

  final ApiClient _api;

  Future<List<Product>> fetchProducts({String? category, String? q}) async {
    if (AppConstants.demoMode) {
      return _filterDemoProducts(_demoProducts(), category: category, q: q);
    }
    final query = <String, String>{};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (q != null && q.isNotEmpty) query['q'] = q;
    try {
      final data = await _api.get(
            '/api/products',
            query: query.isEmpty ? null : query,
          ) as List<dynamic>;
      return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      if (!AppConstants.demoMode) rethrow;
      return _filterDemoProducts(_demoProducts(), category: category, q: q);
    }
  }

  Future<Product> fetchProduct(String id) async {
    final data = await _api.get('/api/products/$id') as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  Future<List<Order>> fetchMyOrders() async {
    final data = await _api.get('/api/orders', auth: true) as List<dynamic>;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Order>> fetchGuestOrdersByPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\s'), '');
    if (normalized.isEmpty) return const [];
    final data = await _api.get('/api/orders/guest/by-phone/$normalized') as List<dynamic>;
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Order> fetchGuestOrder(String orderId, String phone) async {
    final normalized = phone.replaceAll(RegExp(r'\s'), '');
    final data = await _api.get(
      '/api/orders/guest/$orderId',
      query: {'phone': normalized},
    ) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<Order> cancelGuestOrder(String orderId, String phone, {String? reason}) async {
    final normalized = phone.replaceAll(RegExp(r'\s'), '');
    final data = await _api.patch(
      '/api/orders/guest/$orderId/cancel',
      {
        'phone': normalized,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    ) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<Order> cancelCustomerOrder(String orderId, {String? reason}) async {
    final data = await _api.patch(
      '/api/orders/$orderId/cancel',
      {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
      auth: true,
    ) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<Order> fetchOrder(String id) async {
    final data = await _api.get('/api/orders/$id', auth: true) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  /// Build cart lines from a past order using current catalog prices when possible.
  Future<List<CartLine>> buildReorderLines(Order order) async {
    final lines = <CartLine>[];
    for (final item in order.items) {
      final pid = item.productId;
      if (pid == null || pid.isEmpty) continue;
      try {
        final product = await fetchProduct(pid);
        final line = CartLine.fromOrderItem(item, product: product);
        if (line != null) lines.add(line);
      } catch (_) {
        final line = CartLine.fromOrderItem(item);
        if (line != null) lines.add(line);
      }
    }
    return lines;
  }

  Future<Order> placeOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    double deliveryFee = 0,
    String? promoCode,
    String? notes,
    String? deliverySlotId,
  }) async {
    final data = await _api.post(
      '/api/orders',
      {
        'items': items,
        'deliveryAddress': deliveryAddress,
        'deliveryFee': deliveryFee,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (deliverySlotId != null && deliverySlotId.isNotEmpty)
          'deliverySlotId': deliverySlotId,
      },
      auth: true,
    ) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  /// طلب بدون تسجيل (userType guest).
  Future<Order> placeGuestOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> deliveryAddress,
    required String guestName,
    required String guestPhone,
    double deliveryFee = 0,
    String? promoCode,
    String? notes,
    String locale = 'en',
    String? deliverySlotId,
  }) async {
    final data = await _api.post(
      '/api/orders/guest',
      {
        'items': items,
        'deliveryAddress': deliveryAddress,
        'guestName': guestName.trim(),
        'guestPhone': guestPhone.replaceAll(RegExp(r'\s'), ''),
        'deliveryFee': deliveryFee,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'locale': locale.startsWith('ar') ? 'ar' : 'en',
        if (deliverySlotId != null && deliverySlotId.isNotEmpty)
          'deliverySlotId': deliverySlotId,
      },
      auth: false,
    ) as Map<String, dynamic>;
    return Order.fromJson(data);
  }

  Future<List<DeliverySlot>> fetchDeliverySlots() async {
    final data = await _api.get('/api/orders/delivery-slots') as List<dynamic>;
    return data
        .map((e) => DeliverySlot.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Call after Firebase Messaging provides a token (see `docs/fcm_setup.md`).
  Future<void> registerFcmToken(String token) async {
    await _api.post('/api/me/fcm-token', {'token': token}, auth: true);
  }

  Future<List<FlashOffer>> fetchFlashOffers({bool liveOnly = true}) async {
    if (AppConstants.demoMode) return const [];
    final data = await _api.get(
      '/api/flash-offers',
      query: {'live': liveOnly ? 'true' : 'false'},
    ) as List<dynamic>;
    return data
        .map((e) => FlashOffer.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<Product> _filterDemoProducts(
    List<Product> products, {
    String? category,
    String? q,
  }) {
    final qNorm = q?.trim().toLowerCase() ?? '';
    return products.where((p) {
      final categoryMatch = category == null || category.isEmpty || p.category == category;
      if (!categoryMatch) return false;
      if (qNorm.isEmpty) return true;
      return p.name.toLowerCase().contains(qNorm) ||
          (p.nameEn ?? '').toLowerCase().contains(qNorm) ||
          (p.nameAr ?? '').toLowerCase().contains(qNorm);
    }).toList();
  }

  List<Product> _demoProducts() {
    return [
      Product(
        id: 'demo-1',
        name: 'دجاجة كاملة طازجة',
        nameEn: 'Fresh Whole Chicken',
        nameAr: 'دجاجة كاملة طازجة',
        description: 'Fresh whole chicken.',
        images: const ['asset:demo_products/fresh_whole_chicken.webp'],
        price: 210,
        salePrice: 189,
        weightValue: 1.2,
        weightUnit: 'kg',
        stock: 85,
        maxOrderQty: 6,
        category: 'whole-chicken',
        isActive: true,
      ),
      Product(
        id: 'demo-2',
        name: 'صدور دجاج فيليه',
        nameEn: 'Chicken Breast Fillet',
        nameAr: 'صدور دجاج فيليه',
        description: 'Premium skinless breast fillet.',
        images: const ['asset:demo_products/chicken_breast_fillet.webp'],
        price: 255,
        salePrice: 229,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 70,
        maxOrderQty: 5,
        category: 'fillet',
        isActive: true,
      ),
      Product(
        id: 'demo-3',
        name: 'أوراك دجاج',
        nameEn: 'Chicken Thighs',
        nameAr: 'أوراك دجاج',
        description: 'Juicy chicken thighs.',
        images: const ['asset:demo_products/chicken_thighs.webp'],
        price: 185,
        salePrice: 169,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 95,
        maxOrderQty: 8,
        category: 'cuts',
        isActive: true,
      ),
      Product(
        id: 'demo-4',
        name: 'أجنحة دجاج',
        nameEn: 'Chicken Wings',
        nameAr: 'أجنحة دجاج',
        description: 'Tender chicken wings.',
        images: const ['asset:demo_products/chicken_wings.webp'],
        price: 165,
        salePrice: 149,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 92,
        maxOrderQty: 10,
        category: 'cuts',
        isActive: true,
      ),
      Product(
        id: 'demo-5',
        name: 'دبابيس دجاج',
        nameEn: 'Chicken Drumsticks',
        nameAr: 'دبابيس دجاج',
        description: 'Fresh chicken drumsticks.',
        images: const ['asset:demo_products/chicken_drumsticks.webp'],
        price: 175,
        salePrice: 159,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 88,
        maxOrderQty: 8,
        category: 'cuts',
        isActive: true,
      ),
      Product(
        id: 'demo-6',
        name: 'كبد وقوانص',
        nameEn: 'Chicken Liver and Gizzards',
        nameAr: 'كبد وقوانص',
        description: 'Fresh liver and gizzards.',
        images: const ['asset:demo_products/chicken_liver_gizzards.webp'],
        price: 145,
        salePrice: 129,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 60,
        maxOrderQty: 6,
        category: 'offal',
        isActive: true,
      ),
      Product(
        id: 'demo-7',
        name: 'صدور دجاج فيليه شرائح',
        nameEn: 'Sliced Chicken Breast Fillet',
        nameAr: 'صدور دجاج فيليه شرائح',
        description: 'Thin sliced breast fillet.',
        images: const ['asset:demo_products/sliced_chicken_breast_fillet.webp'],
        price: 245,
        salePrice: 219,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 62,
        maxOrderQty: 5,
        category: 'fillet',
        isActive: true,
      ),
      Product(
        id: 'demo-8',
        name: 'شيش طاووق',
        nameEn: 'Chicken Shish Tawook',
        nameAr: 'شيش طاووق',
        description: 'Chicken cubes for grilling.',
        images: const ['asset:demo_products/chicken_shish_tawook.webp'],
        price: 265,
        salePrice: 239,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 48,
        maxOrderQty: 4,
        category: 'marinated',
        isActive: true,
      ),
      Product(
        id: 'demo-9',
        name: 'كبد دجاج',
        nameEn: 'Chicken Liver',
        nameAr: 'كبد دجاج',
        description: 'Fresh chicken liver.',
        images: const ['asset:demo_products/chicken_liver.webp'],
        price: 135,
        salePrice: 119,
        weightValue: 1,
        weightUnit: 'kg',
        stock: 64,
        maxOrderQty: 6,
        category: 'offal',
        isActive: true,
      ),
    ];
  }
}

class DeliverySlot {
  DeliverySlot({
    required this.id,
    required this.fromHour,
    required this.toHour,
    required this.label,
    required this.capacity,
    required this.used,
    required this.isFull,
    required this.isVisible,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      id: json['id']?.toString() ?? '',
      fromHour: (json['fromHour'] as num?)?.toInt() ?? 0,
      toHour: (json['toHour'] as num?)?.toInt() ?? 0,
      label: json['label']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      used: (json['used'] as num?)?.toInt() ?? 0,
      isFull: json['isFull'] == true,
      isVisible: json['isVisible'] == true,
    );
  }

  final String id;
  final int fromHour;
  final int toHour;
  final String label;
  final int capacity;
  final int used;
  final bool isFull;
  final bool isVisible;
}
