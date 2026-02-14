import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';

/// Manages authentication state: login, logout, persist token.
class AuthProvider extends ChangeNotifier {
  final ApiService _api;
  late final AuthApiService _authApi;

  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._api) {
    _authApi = AuthApiService(_api);
  }

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _api.isAuthenticated;
  bool get isSupervisor => _user?.isSupervisor ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Try to restore session from persisted token.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return false;

    _api.setToken(token);
    try {
      _user = await _authApi.getMe();
      notifyListeners();
      return true;
    } catch (_) {
      _api.setToken(null);
      await prefs.remove('auth_token');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authApi.login(email, password);
      _user = User.fromJson(data['user']);

      // persist token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['access_token']);

      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Is the server running?';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _authApi.logout();
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _authApi.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
