import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'customer_profile.dart';

class CustomerProfileLocalService {
  static const _kProfile = 'daytoday_customer_profile_v1';

  Future<void> save(CustomerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfile, jsonEncode(profile.toJson()));
  }

  Future<CustomerProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CustomerProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
