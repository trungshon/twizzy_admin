import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 1;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.init();

    // Register refresh token callback
    _apiService.setOnRefreshToken(_authService.refreshToken);

    // Register logout callback
    _apiService.setOnLogout(() {
      _currentUser = null;
      notifyListeners();
    });

    if (_apiService.isAuthenticated) {
      await _loadCurrentUser();
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getMe();
    } catch (e) {
      await _authService.logout();
      _currentUser = null;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);

      // Check if user is admin
      if (_currentUser?.role != 1) {
        _error = 'Access denied. Admin privileges required.';
        await _authService.logout();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
