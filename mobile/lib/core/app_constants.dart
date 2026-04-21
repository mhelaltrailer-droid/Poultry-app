class AppConstants {
  AppConstants._();

  /// Enables local demo login/data flow when built with:
  /// --dart-define=DEMO_MODE=true
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: false,
  );

  // Egypt number in international format for wa.me (without +)
  static const String whatsappPhoneNumber = '201550490790';

  static String get whatsappUrl => 'https://wa.me/$whatsappPhoneNumber';

  /// Prefilled contact for the same shopping flow as blank start (userType = guest).
  static const String demoContactName = 'عميل تجريبي';
  static const String demoContactPhone = '01157563840';

  static const String prefLastOrderNumber = 'daytoday_last_order_number';
}
