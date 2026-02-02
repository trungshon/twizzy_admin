import 'api_service.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../models/twizz_model.dart';
import '../core/constants/app_constants.dart';

class AdminService {
  final ApiService _api = ApiService();

  // Dashboard
  Future<DashboardStats> getStats() async {
    final response = await _api.get(
      '${AppConstants.adminApiPath}/stats',
    );
    return DashboardStats.fromJson(response['result']);
  }

  Future<List<GrowthData>> getGrowthData({
    int days = 7,
    int offset = 0,
  }) async {
    final response = await _api.get(
      '${AppConstants.adminApiPath}/growth',
      queryParams: {
        'days': days.toString(),
        'offset': offset.toString(),
      },
    );
    final List<dynamic> data = response['result'];
    return data.map((e) => GrowthData.fromJson(e)).toList();
  }

  // Users Management
  Future<({List<User> users, Pagination pagination})> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    int? verifyStatus,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (verifyStatus != null) {
      queryParams['verify_status'] = verifyStatus.toString();
    }

    final response = await _api.get(
      '${AppConstants.adminApiPath}/users',
      queryParams: queryParams,
    );

    final result = response['result'];
    final users =
        (result['users'] as List<dynamic>)
            .map((e) => User.fromJson(e))
            .toList();
    final pagination = Pagination.fromJson(result['pagination']);

    return (users: users, pagination: pagination);
  }

  Future<User> getUserDetail(String userId) async {
    final response = await _api.get(
      '${AppConstants.adminApiPath}/users/$userId',
    );
    return User.fromJson(response['result']);
  }

  Future<void> updateUserStatus(
    String userId,
    int verifyStatus,
  ) async {
    await _api.patch(
      '${AppConstants.adminApiPath}/users/$userId/status',
      body: {'verify': verifyStatus},
    );
  }

  Future<void> deleteUser(String userId) async {
    await _api.delete(
      '${AppConstants.adminApiPath}/users/$userId',
    );
  }

  // Twizzs Management
  Future<({List<Twizz> twizzs, Pagination pagination})>
  getTwizzs({
    int page = 1,
    int limit = 10,
    String? search,
    int? type,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (type != null) {
      queryParams['type'] = type.toString();
    }

    final response = await _api.get(
      '${AppConstants.adminApiPath}/twizzs',
      queryParams: queryParams,
    );

    final result = response['result'];
    final twizzs =
        (result['twizzs'] as List<dynamic>)
            .map((e) => Twizz.fromJson(e))
            .toList();
    final pagination = Pagination.fromJson(result['pagination']);

    return (twizzs: twizzs, pagination: pagination);
  }

  Future<void> deleteTwizz(String twizzId) async {
    await _api.delete(
      '${AppConstants.adminApiPath}/twizzs/$twizzId',
    );
  }
}
