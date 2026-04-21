class OrderItem {
  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.weightSnapshot,
    this.image,
  });

  final String? productId;
  final String name;
  final double price;
  final int quantity;
  final String? weightSnapshot;
  final String? image;

  factory OrderItem.fromJson(Map<String, dynamic> j) {
    final pid = j['productId'];
    String? productId;
    if (pid is String) {
      productId = pid;
    } else if (pid is Map && pid['_id'] != null) {
      productId = pid['_id'].toString();
    }
    return OrderItem(
      productId: productId,
      name: j['name'] as String? ?? '',
      price: (j['price'] as num?)?.toDouble() ?? 0,
      quantity: (j['quantity'] as num?)?.toInt() ?? 1,
      weightSnapshot: j['weightSnapshot'] as String?,
      image: j['image'] as String?,
    );
  }
}

class Order {
  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.total,
    required this.createdAt,
    this.assignedDelivery,
    this.deliveryAddress,
  });

  final String id;
  final String orderNumber;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double total;
  final DateTime createdAt;
  final String? assignedDelivery;
  final Map<String, dynamic>? deliveryAddress;

  factory Order.fromJson(Map<String, dynamic> j) {
    final itemsRaw = j['items'] as List<dynamic>? ?? [];
    return Order(
      id: j['_id'] as String,
      orderNumber: j['orderNumber'] as String? ?? '',
      status: j['status'] as String? ?? 'pending',
      items: itemsRaw
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (j['deliveryFee'] as num?)?.toDouble() ?? 0,
      discountAmount: (j['discountAmount'] as num?)?.toDouble() ?? 0,
      total: (j['total'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(j['createdAt'] as String),
      assignedDelivery: j['assignedDelivery'] as String?,
      deliveryAddress: j['deliveryAddress'] as Map<String, dynamic>?,
    );
  }

  static String statusLabel(String s) {
    switch (s) {
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'on_the_way':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
