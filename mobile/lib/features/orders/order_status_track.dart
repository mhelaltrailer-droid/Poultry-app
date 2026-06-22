/// Progress steps for customer order tracking (excludes cancelled).
abstract final class OrderStatusTrack {
  static const steps = [
    'pending',
    'confirmed',
    'preparing',
    'on_the_way',
    'delivered',
  ];

  static int indexOf(String status) {
    if (status == 'cancelled') return -1;
    final idx = steps.indexOf(status);
    return idx < 0 ? 0 : idx;
  }

  static bool isActive(String status) =>
      status != 'delivered' && status != 'cancelled';
}
