import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../models/dashboard_model.dart';

class UsersViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<User> _users = [];
  Pagination? _pagination;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _filterStatus;
  int _currentPage = 1;

  List<User> get users => _users;
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get filterStatus => _filterStatus;
  int get currentPage => _currentPage;

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getUsers(
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        verifyStatus: _filterStatus,
      );

      _users = result.users;
      _pagination = result.pagination;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    loadUsers();
  }

  void setFilterStatus(int? status) {
    _filterStatus = status;
    _currentPage = 1;
    loadUsers();
  }

  void goToPage(int page) {
    _currentPage = page;
    loadUsers();
  }

  Future<bool> updateUserStatus(
    String userId,
    int status,
  ) async {
    try {
      await _adminService.updateUserStatus(userId, status);
      await loadUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _adminService.deleteUser(userId);
      await loadUsers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
