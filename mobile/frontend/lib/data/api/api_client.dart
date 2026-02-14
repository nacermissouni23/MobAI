import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Exception thrown when the API returns an error.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({required this.statusCode, required this.message, this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Low-level HTTP client for the backend API.
/// Handles auth token injection, JSON encoding/decoding, and error mapping.
class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set the JWT auth token (after login).
  void setToken(String token) => _authToken = token;

  /// Clear the auth token (on logout).
  void clearToken() => _authToken = null;

  /// Whether the client has an auth token.
  bool get hasToken => _authToken != null;

  /// Standard headers with optional auth.
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ── HTTP Methods ────────────────────────────────────────────

  Future<dynamic> get(String url, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: ApiConfig.receiveTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } on TimeoutException {
      throw ApiException(statusCode: 0, message: 'Request timed out');
    }
  }

  Future<dynamic> post(String url, {dynamic body}) async {
    final uri = Uri.parse(url);
    try {
      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: ApiConfig.receiveTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } on TimeoutException {
      throw ApiException(statusCode: 0, message: 'Request timed out');
    }
  }

  Future<dynamic> put(String url, {dynamic body}) async {
    final uri = Uri.parse(url);
    try {
      final response = await _client
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: ApiConfig.receiveTimeout));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } on TimeoutException {
      throw ApiException(statusCode: 0, message: 'Request timed out');
    }
  }

  Future<void> delete(String url) async {
    final uri = Uri.parse(url);
    try {
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: ApiConfig.receiveTimeout));
      if (response.statusCode != 204 && response.statusCode != 200) {
        _handleResponse(response);
      }
    } on SocketException {
      throw ApiException(statusCode: 0, message: 'No internet connection');
    } on TimeoutException {
      throw ApiException(statusCode: 0, message: 'Request timed out');
    }
  }

  // ── Response Handling ─────────────────────────────────────

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(response.body) as Map<String, dynamic>?;
    } catch (_) {}

    throw ApiException(
      statusCode: response.statusCode,
      message:
          errorBody?['message'] ?? errorBody?['detail'] ?? 'Request failed',
      details: errorBody,
    );
  }

  /// Check if backend is reachable.
  Future<bool> isServerReachable() async {
    try {
      final uri = Uri.parse(ApiConfig.baseUrl.replaceAll('/api', '/'));
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
