import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_constants.dart';
import '../../core/api_config.dart';

/// Shopping (guest) + staff dashboard — unified shopping is always [userTypeGuest].
const String userTypeGuest = 'guest';
const String userTypeStaff = 'staff';

const _kLegacyToken = 'customer_jwt';
const _kLegacyUser = 'customer_user';

const _kStaffToken = 'daytoday_staff_jwt';
const _kStaffUser = 'daytoday_staff_user';
const _kShopping = 'daytoday_shopping_active';
const _kGuestName = 'daytoday_guest_name';
const _kGuestPhone = 'daytoday_guest_phone';
const _kGuestDistrict = 'daytoday_guest_district';
const _kGuestAddressDetail = 'daytoday_guest_address_detail';
const _kCustomerProfile = 'daytoday_customer_profile_v1';
const _kCartJson = 'daytoday_cart_lines_v1';

const _staffRoles = {'admin', 'app_admin', 'ops_admin'};

class AuthController extends ChangeNotifier {
  String? _staffToken;
  Map<String, dynamic>? _staffUser;
  bool _shoppingActive = false;
  String _guestName = '';
  String _guestPhone = '';
  String _guestDistrict = '';
  String _guestAddressDetail = '';

  /// `guest` أثناء التسوق (بدون تمييز واجهة)، `staff` للوحة التحكم.
  String get userType => isStaff ? userTypeStaff : userTypeGuest;

  bool get isShopping => _shoppingActive;
  bool get onWelcome => !isStaff && !isShopping;

  String? get staffToken => _staffToken;
  Map<String, dynamic>? get staffUser => _staffUser;
  String get guestName => _guestName;
  String get guestPhone => _guestPhone;
  String get guestDistrict => _guestDistrict;
  String get guestAddressDetail => _guestAddressDetail;

  /// توافق قديم: وجود جلسة تسوق أو staff.
  bool get isAuthenticated => isStaff || isShopping;

  Map<String, dynamic>? get user =>
      isStaff ? _staffUser : {'name': _guestName, 'phone': _guestPhone, 'role': userTypeGuest};

  String? get role =>
      isStaff ? (_staffUser?['role'] as String?) : userTypeGuest;

  bool get isStaff {
    final r = _staffUser?['role'] as String?;
    return _staffToken != null &&
        _staffToken!.isNotEmpty &&
        r != null &&
        _staffRoles.contains(r);
  }

  bool get canUseInAppDashboard {
    final r = _staffUser?['role'] as String?;
    return r == 'admin' || r == 'app_admin';
  }

  Future<String?> getToken() async => _staffToken;

  Future<void> loadSession() async {
    final p = await SharedPreferences.getInstance();
    await _migrateLegacy(p);

    _staffToken = p.getString(_kStaffToken);
    final staffRaw = p.getString(_kStaffUser);
    _staffUser = null;
    if (staffRaw != null) {
      try {
        _staffUser = jsonDecode(staffRaw) as Map<String, dynamic>;
      } catch (_) {
        _staffUser = null;
      }
    }
    if (_staffToken == null || _staffToken!.isEmpty) {
      _staffUser = null;
    }

    _shoppingActive = p.getBool(_kShopping) ?? false;
    _guestName = p.getString(_kGuestName) ?? '';
    _guestPhone = p.getString(_kGuestPhone) ?? '';
    _guestDistrict = p.getString(_kGuestDistrict) ?? '';
    _guestAddressDetail = p.getString(_kGuestAddressDetail) ?? '';

    if (isStaff) {
      _shoppingActive = false;
    }

    notifyListeners();
  }

  Future<void> _migrateLegacy(SharedPreferences p) async {
    final legTok = p.getString(_kLegacyToken);
    final legUser = p.getString(_kLegacyUser);
    if (legTok == null || legUser == null) return;
    try {
      final u = jsonDecode(legUser) as Map<String, dynamic>;
      final role = u['role'] as String? ?? '';
      if (_staffRoles.contains(role)) {
        await p.setString(_kStaffToken, legTok);
        await p.setString(_kStaffUser, legUser);
      } else {
        await p.setBool(_kShopping, true);
        await p.setString(_kGuestName, u['name']?.toString() ?? '');
        await p.setString(_kGuestPhone, u['phone']?.toString() ?? '');
      }
    } catch (_) {}
    await p.remove(_kLegacyToken);
    await p.remove(_kLegacyUser);
  }

  Future<void> _persistStaff() async {
    final p = await SharedPreferences.getInstance();
    if (_staffToken != null && _staffToken!.isNotEmpty) {
      await p.setString(_kStaffToken, _staffToken!);
      await p.setString(_kStaffUser, jsonEncode(_staffUser ?? {}));
    } else {
      await p.remove(_kStaffToken);
      await p.remove(_kStaffUser);
    }
  }

  Future<void> _persistShopping() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShopping, _shoppingActive);
    await p.setString(_kGuestName, _guestName);
    await p.setString(_kGuestPhone, _guestPhone);
    await p.setString(_kGuestDistrict, _guestDistrict);
    await p.setString(_kGuestAddressDetail, _guestAddressDetail);
  }

  /// بدء التسوق — بدون اسم/هاتف يُصفَّر التواصل المحلي (جلسة جديدة).
  Future<void> startShopping({String? name, String? phone}) async {
    _staffToken = null;
    _staffUser = null;
    await _persistStaff();
    _shoppingActive = true;
    if (name != null || phone != null) {
      if (name != null) _guestName = name.trim();
      if (phone != null) _guestPhone = phone.trim();
    } else {
      _guestName = '';
      _guestPhone = '';
      _guestDistrict = '';
      _guestAddressDetail = '';
    }
    await _persistShopping();
    notifyListeners();
  }

  Future<void> setGuestContact({required String name, required String phone}) async {
    _guestName = name.trim();
    _guestPhone = phone.trim();
    await _persistShopping();
    notifyListeners();
  }

  Future<void> leaveShopping() async {
    _shoppingActive = false;
    _guestName = '';
    _guestPhone = '';
    _guestDistrict = '';
    _guestAddressDetail = '';
    await _persistShopping();
    notifyListeners();
  }

  Uri _uri(String path) => Uri.parse('${resolveApiBase()}$path');

  /// تسجيل دخول: staff → لوحة التحكم؛ عميل مسجّل → نفس تجربة الضيف مع تعبئة الاسم/الهاتف (بدون JWT للتسوق).
  Future<void> signInWithPassword(String phone, String password) async {
    late http.Response r;
    try {
      r = await http.post(
        _uri('/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone.replaceAll(RegExp(r'\s'), ''),
          'password': password,
        }),
      );
    } catch (_) {
      if (kIsWeb) {
        throw Exception(
          'تعذّر الاتصال بالخادم على ${resolveApiBase()}.\n'
          '• شغّل MongoDB: من جذر المشروع نفّذ: docker compose up -d\n'
          '• ثم شغّل الـ API: cd backend ثم npm run dev\n'
          '• جرّب في المتصفح: ${resolveApiBase()}/health',
        );
      }
      rethrow;
    }
    final data = _decodeJson(r);
    if (r.statusCode >= 400) {
      throw Exception(data is Map && data['message'] is String
          ? data['message'] as String
          : 'فشل تسجيل الدخول');
    }
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final role = user?['role'] as String? ?? '';

    if (_staffRoles.contains(role)) {
      _staffToken = token;
      _staffUser = user;
      _shoppingActive = false;
      await _persistStaff();
      await _persistShopping();
      notifyListeners();
      return;
    }

    if (role == 'customer') {
      _staffToken = null;
      _staffUser = null;
      await _persistStaff();
      _shoppingActive = true;
      _guestName = user?['name']?.toString() ?? '';
      _guestPhone = user?['phone']?.toString() ?? phone.replaceAll(RegExp(r'\s'), '');
      _guestDistrict = user?['district']?.toString() ?? '';
      _guestAddressDetail = user?['addressDetail']?.toString() ?? '';
      await _persistShopping();
      notifyListeners();
      return;
    }

    throw Exception('Account role not supported');
  }

  Future<void> signInDemoAdmin() async {
    _staffToken = 'demo-token-admin';
    _staffUser = {
      'id': 'demo-admin',
      'name': 'Demo Admin',
      'phone': '01111989094',
      'role': 'app_admin',
    };
    _shoppingActive = false;
    await _persistStaff();
    await _persistShopping();
    notifyListeners();
  }

  Future<void> signInDemoCustomer() async {
    _staffToken = null;
    _staffUser = null;
    await _persistStaff();
    _shoppingActive = true;
    _guestName = 'Demo Customer';
    _guestPhone = AppConstants.demoContactPhone;
    _guestDistrict = 'Nasr City';
    _guestAddressDetail = 'Demo Address';
    await _persistShopping();
    notifyListeners();
  }

  Future<void> registerCustomer({
    required String name,
    required String familyName,
    required String phone,
    required String password,
    required String city,
    required String district,
    required String addressDetail,
    String deliveryNotes = '',
  }) async {
    late http.Response r;
    try {
      r = await http.post(
        _uri('/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'familyName': familyName.trim(),
          'phone': phone.replaceAll(RegExp(r'\s'), ''),
          'password': password,
          'city': city.trim(),
          'district': district.trim(),
          'addressDetail': addressDetail.trim(),
          'deliveryNotes': deliveryNotes.trim(),
        }),
      );
    } catch (_) {
      if (kIsWeb) {
        throw Exception(
          'تعذّر الاتصال بالخادم على ${resolveApiBase()}.\n'
          '• شغّل MongoDB: من جذر المشروع نفّذ: docker compose up -d\n'
          '• ثم شغّل الـ API: cd backend ثم npm run dev\n'
          '• جرّب في المتصفح: ${resolveApiBase()}/health',
        );
      }
      rethrow;
    }
    final data = _decodeJson(r);
    if (r.statusCode >= 400) {
      throw Exception(
        data is Map && data['message'] is String
            ? data['message'] as String
            : 'فشل إنشاء الحساب',
      );
    }
    final user = data['user'] as Map<String, dynamic>?;
    _staffToken = null;
    _staffUser = null;
    await _persistStaff();
    _shoppingActive = true;
    _guestName = user?['name']?.toString() ?? name.trim();
    _guestPhone = user?['phone']?.toString() ?? phone.replaceAll(RegExp(r'\s'), '');
    _guestDistrict = user?['district']?.toString() ?? district.trim();
    _guestAddressDetail = user?['addressDetail']?.toString() ?? addressDetail.trim();
    await _persistShopping();
    notifyListeners();
  }

  dynamic _decodeJson(http.Response r) {
    if (r.body.isEmpty) return {};
    return jsonDecode(r.body);
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    _staffToken = null;
    _staffUser = null;
    _shoppingActive = false;
    _guestName = '';
    _guestPhone = '';
    _guestDistrict = '';
    _guestAddressDetail = '';
    await p.remove(_kStaffToken);
    await p.remove(_kStaffUser);
    await p.remove(_kShopping);
    await p.remove(_kGuestName);
    await p.remove(_kGuestPhone);
    await p.remove(_kGuestDistrict);
    await p.remove(_kGuestAddressDetail);
    await p.remove(_kLegacyToken);
    await p.remove(_kLegacyUser);
    await p.remove(_kCustomerProfile);
    await p.remove(_kCartJson);
    await p.remove(AppConstants.prefLastOrderNumber);
    notifyListeners();
  }
}
