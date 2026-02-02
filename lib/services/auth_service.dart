import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<User> login(String email, String password) async {
    final response = await _api.post(
      '/users/login',
      body: {'email': email, 'password': password},
    );

    final result = response['result'];
    final accessToken = result['access_token'] as String;
    final refreshToken = result['refresh_token'] as String;

    await _api.saveTokens(accessToken, refreshToken);

    // Get current user info
    return await getMe();
  }

  Future<User> getMe() async {
    final response = await _api.get('/users/me');
    return User.fromJson(response['result']);
  }

  Future<void> refreshToken() async {
    final response = await _api.post(
      '/users/refresh-token',
      body: {'refresh_token': _api.refreshToken},
    );

    final result = response['result'];
    final accessToken = result['access_token'] as String;
    final refreshToken = result['refresh_token'] as String;

    await _api.saveTokens(accessToken, refreshToken);
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  bool get isAuthenticated => _api.isAuthenticated;
}
