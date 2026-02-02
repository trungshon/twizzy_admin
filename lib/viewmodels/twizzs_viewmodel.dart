import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/twizz_model.dart';
import '../models/dashboard_model.dart';

class TwizzsViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Twizz> _twizzs = [];
  Pagination? _pagination;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _filterType;
  int _currentPage = 1;

  List<Twizz> get twizzs => _twizzs;
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get filterType => _filterType;
  int get currentPage => _currentPage;

  Future<void> loadTwizzs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getTwizzs(
        page: _currentPage,
        limit: 10,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        type: _filterType,
      );

      _twizzs = result.twizzs;
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
    loadTwizzs();
  }

  void setFilterType(int? type) {
    _filterType = type;
    _currentPage = 1;
    loadTwizzs();
  }

  void goToPage(int page) {
    _currentPage = page;
    loadTwizzs();
  }

  Future<bool> deleteTwizz(String twizzId) async {
    try {
      await _adminService.deleteTwizz(twizzId);
      await loadTwizzs();
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
