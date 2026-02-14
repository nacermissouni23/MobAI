import '../models/user.dart';
import 'api_service.dart';

/// Handles authentication API calls (login, register, me).
class AuthApiService {
  final ApiService _api;

  AuthApiService(this._api);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    // data = { access_token, token_type, user: {...} }
    _api.setToken(data['access_token']);
    return data;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    final data = await _api.post(
      '/api/auth/register',
      body: {'name': name, 'email': email, 'password': password, 'role': role},
    );
    return User.fromJson(data);
  }

  Future<User> getMe() async {
    final data = await _api.get('/api/auth/me');
    return User.fromJson(data);
  }

  void logout() {
    _api.setToken(null);
  }
}
