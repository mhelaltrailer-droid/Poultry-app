import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(LocaleController.prefKey);
  final initial =
      code == 'ar' ? const Locale('ar') : const Locale('en');
  runApp(DayTodayApp(initialLocale: initial));
}
