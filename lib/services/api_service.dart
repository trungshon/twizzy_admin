import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;
  bool _isRefreshing = false;
  Future<void> Function()? _onRefreshToken;
  void Function()? _onLogout;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(AppConstants.accessTokenKey);
    _refreshToken = prefs.getString(
      AppConstants.refreshTokenKey,
    );
  }

  void setAccessToken(String token) {
    _accessToken = token;
  }

  void setOnRefreshToken(Future<void> Function() callback) {
    _onRefreshToken = callback;
  }

  void setOnLogout(void Function() callback) {
    _onLogout = callback;
  }

  String? get refreshToken => _refreshToken;

  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.accessTokenKey,
      accessToken,
    );
    await prefs.setString(
      AppConstants.refreshTokenKey,
      refreshToken,
    );
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
  }

  bool get isAuthenticated =>
      _accessToken != null && _accessToken!.isNotEmpty;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null)
      'Authorization': 'Bearer $_accessToken',
  };

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);
      return _handleResponse(
        response,
        () => get(endpoint, queryParams: queryParams),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(
        response,
        () => post(endpoint, body: body),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(
        response,
        () => patch(endpoint, body: body),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response, () => delete(endpoint));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    Future<Map<String, dynamic>> Function() retry,
  ) async {
    final data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401 &&
        _refreshToken != null &&
        !_isRefreshing &&
        _onRefreshToken != null) {
      _isRefreshing = true;
      try {
        await _onRefreshToken!();
        _isRefreshing = false;
        return await retry();
      } catch (e) {
        _isRefreshing = false;
        await clearTokens();
        _onLogout?.call();
        throw UnauthorizedException(
          message:
              'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
          statusCode: 401,
        );
      }
    } else {
      throw ApiException(
        message: data['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    required super.message,
    required super.statusCode,
  });
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => message;
}
