import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists UI language (Arabic / English).
class LocaleController extends ChangeNotifier {
  LocaleController({required Locale initial}) : _locale = initial;

  static const prefKey = 'daytoday_app_locale';

  Locale _locale;
  Locale get locale => _locale;

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(prefKey, value.languageCode);
  }

  Future<void> toggleEnAr() async {
    final next =
        _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}
