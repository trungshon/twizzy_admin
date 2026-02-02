class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String adminApiPath = '/admin';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';

  // User Verify Status
  static const int unverified = 0;
  static const int verified = 1;
  static const int banned = 2;

  // Twizz Types
  static const int twizzType = 0;
  static const int commentType = 1;
  static const int quoteTwizzType = 2;

  // Pagination
  static const int defaultPageSize = 10;
}
