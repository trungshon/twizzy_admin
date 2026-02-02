import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/dashboard_model.dart';

class DashboardViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  DashboardStats? _stats;
  List<GrowthData> _growthData = [];
  bool _isLoading = false;
  String? _error;
  int _selectedDays = 7;
  int _offset = 0;

  DashboardStats? get stats => _stats;
  List<GrowthData> get growthData => _growthData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedDays => _selectedDays;
  int get offset => _offset;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    _offset = 0;
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminService.getStats(),
        _adminService.getGrowthData(
          days: _selectedDays,
          offset: _offset,
        ),
      ]);

      _stats = results[0] as DashboardStats;
      _growthData = results[1] as List<GrowthData>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeGrowthPeriod(int days) async {
    if (_selectedDays == days) return;

    _selectedDays = days;
    _offset = 0;
    _isLoading = true;
    notifyListeners();

    try {
      _growthData = await _adminService.getGrowthData(
        days: days,
        offset: _offset,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPeriod() async {
    if (_offset == 0) return;

    final newOffset =
        (_offset - _selectedDays).clamp(0, 9999).toInt();
    await _updateGrowthData(newOffset);
  }

  Future<void> previousPeriod() async {
    final newOffset = _offset + _selectedDays;
    await _updateGrowthData(newOffset);
  }

  Future<void> _updateGrowthData(int newOffset) async {
    _isLoading = true;
    notifyListeners();

    try {
      _growthData = await _adminService.getGrowthData(
        days: _selectedDays,
        offset: newOffset,
      );
      _offset = newOffset;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
