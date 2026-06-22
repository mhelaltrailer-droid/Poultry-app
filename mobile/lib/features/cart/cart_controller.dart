import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_model.dart';

const _kCartJson = 'daytoday_cart_lines_v1';

class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();

  int get itemCount => _lines.values.fold(0, (a, b) => a + b.quantity);

  double get subtotal => _lines.values.fold(0.0, (a, b) => a + b.lineTotal);

  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kCartJson);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _lines.clear();
      for (final e in list) {
        final line = CartLine.fromJson(Map<String, dynamic>.from(e as Map));
        _lines[line.productId] = line;
      }
      notifyListeners();
    } catch (_) {
      _lines.clear();
    }
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    final list = _lines.values.map((e) => e.toJson()).toList();
    await p.setString(_kCartJson, jsonEncode(list));
  }

  void add(CartLine line) {
    final existing = _lines[line.productId];
    if (existing != null) {
      existing.quantity += line.quantity;
    } else {
      _lines[line.productId] = line;
    }
    notifyListeners();
    _persist();
  }

  void setQuantity(String productId, int qty) {
    final line = _lines[productId];
    if (line == null) return;
    if (qty <= 0) {
      _lines.remove(productId);
    } else {
      line.quantity = qty;
    }
    notifyListeners();
    _persist();
  }

  void remove(String productId) {
    _lines.remove(productId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
    _persist();
  }

  Future<void> replaceLines(List<CartLine> lines) async {
    _lines.clear();
    for (final line in lines) {
      if (line.quantity <= 0) continue;
      _lines[line.productId] = line.copyWith();
    }
    notifyListeners();
    await _persist();
  }

  Future<void> mergeLines(List<CartLine> lines) async {
    for (final line in lines) {
      if (line.quantity <= 0) continue;
      add(line.copyWith());
    }
    await _persist();
  }
}
