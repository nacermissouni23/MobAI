import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Central API client for all backend communication.
class ApiService {
  // Android emulator uses 10.0.2.2 to reach host localhost.
  // For physical devices / iOS simulator, use your machine's LAN IP.
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000'; // iOS / desktop
  }

  static String get baseUrl => _baseUrl;

  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  // ── Generic HTTP helpers ──────────────────────────────────────

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers);
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(res);
  }

  Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (res.statusCode != 204 && res.statusCode < 200 ||
        res.statusCode >= 300) {
      throw ApiException(res.statusCode, _parseError(res));
    }
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    throw ApiException(res.statusCode, _parseError(res));
  }

  String _parseError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      return body['detail'] ?? body['message'] ?? res.body;
    } catch (_) {
      return res.body;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
