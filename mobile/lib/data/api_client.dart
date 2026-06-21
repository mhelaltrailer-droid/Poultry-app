import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';

typedef TokenGetter = Future<String?> Function();

class ApiClient {
  ApiClient({TokenGetter? getToken}) : _getToken = getToken;

  final TokenGetter? _getToken;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = resolveApiBase();
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    final tokenGetter = _getToken;
    if (auth && tokenGetter != null) {
      final t = await tokenGetter();
      if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Future<dynamic> get(String path, {bool auth = false, Map<String, String>? query}) async {
    final r = await http.get(_uri(path, query), headers: await _headers(auth: auth));
    return _decode(r);
  }

  Future<dynamic> post(String path, Object? body, {bool auth = false}) async {
    final r = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(r);
  }

  Future<dynamic> patch(String path, Object? body, {bool auth = false}) async {
    final r = await http.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(r);
  }

  Future<dynamic> put(String path, Object? body, {bool auth = false}) async {
    final r = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(r);
  }

  Future<dynamic> delete(String path, {bool auth = false}) async {
    final r = await http.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );
    return _decode(r);
  }

  dynamic _decode(http.Response r) {
    final text = r.body.isEmpty ? '{}' : r.body;
    final data = jsonDecode(text);
    if (r.statusCode >= 400) {
      final msg = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Request failed (${r.statusCode})';
      throw ApiException(r.statusCode, msg);
    }
    return data;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
