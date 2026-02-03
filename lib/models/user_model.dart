class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String? avatar;
  final String? coverPhoto;
  final String? bio;
  final String? location;
  final String? website;
  final int verify;
  final int role;
  final int violationCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserStats? stats;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    this.avatar,
    this.coverPhoto,
    this.bio,
    this.location,
    this.website,
    required this.verify,
    required this.role,
    required this.violationCount,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      coverPhoto: json['cover_photo'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      verify: json['verify'] ?? 0,
      role: json['role'] ?? 0,
      violationCount: json['violation_count'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      stats:
          json['stats'] != null
              ? UserStats.fromJson(json['stats'])
              : null,
    );
  }

  String get verifyStatusText {
    switch (verify) {
      case 0:
        return 'Chưa xác minh';
      case 1:
        return 'Đã xác minh';
      case 2:
        return 'Bị cấm';
      default:
        return 'Không xác định';
    }
  }
}

class UserStats {
  final int twizzs;
  final int followers;
  final int following;

  UserStats({
    required this.twizzs,
    required this.followers,
    required this.following,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      twizzs: json['twizzs'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}
