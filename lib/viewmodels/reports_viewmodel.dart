import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/dashboard_model.dart';
import '../services/admin_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<Report> _reports = [];
  Pagination? _pagination;
  bool _isLoading = false;
  String? _error;
  int? _selectedStatus;

  List<Report> get reports => _reports;
  Pagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedStatus => _selectedStatus;

  Future<void> loadReports({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _adminService.getReports(
        page: page,
        status: _selectedStatus,
      );
      _reports = result.reports;
      _pagination = result.pagination;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeStatusFilter(int? status) async {
    _selectedStatus = status;
    await loadReports();
  }

  Future<void> handleReport(
    String reportId,
    String action,
  ) async {
    try {
      await _adminService.handleReport(reportId, action);
      await loadReports(page: _pagination?.page ?? 1);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _adminService.deleteReport(reportId);
      await loadReports(page: _pagination?.page ?? 1);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProcessedReports() async {
    try {
      await _adminService.deleteProcessedReports();
      await loadReports(page: 1);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
