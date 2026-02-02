class DashboardStats {
  final UserStats users;
  final TwizzStats twizzs;
  final EngagementStats engagement;

  DashboardStats({
    required this.users,
    required this.twizzs,
    required this.engagement,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      users: UserStats.fromJson(json['users'] ?? {}),
      twizzs: TwizzStats.fromJson(json['twizzs'] ?? {}),
      engagement: EngagementStats.fromJson(
        json['engagement'] ?? {},
      ),
    );
  }
}

class UserStats {
  final int total;
  final int verified;
  final int unverified;
  final int banned;
  final int newToday;

  UserStats({
    required this.total,
    required this.verified,
    required this.unverified,
    required this.banned,
    required this.newToday,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] ?? 0,
      verified: json['verified'] ?? 0,
      unverified: json['unverified'] ?? 0,
      banned: json['banned'] ?? 0,
      newToday: json['new_today'] ?? 0,
    );
  }
}

class TwizzStats {
  final int total;
  final int newToday;

  TwizzStats({required this.total, required this.newToday});

  factory TwizzStats.fromJson(Map<String, dynamic> json) {
    return TwizzStats(
      total: json['total'] ?? 0,
      newToday: json['new_today'] ?? 0,
    );
  }
}

class EngagementStats {
  final int totalLikes;
  final int totalBookmarks;

  EngagementStats({
    required this.totalLikes,
    required this.totalBookmarks,
  });

  factory EngagementStats.fromJson(Map<String, dynamic> json) {
    return EngagementStats(
      totalLikes: json['total_likes'] ?? 0,
      totalBookmarks: json['total_bookmarks'] ?? 0,
    );
  }
}

class GrowthData {
  final String date;
  final int users;
  final int twizzs;

  GrowthData({
    required this.date,
    required this.users,
    required this.twizzs,
  });

  factory GrowthData.fromJson(Map<String, dynamic> json) {
    return GrowthData(
      date: json['date'] ?? '',
      users: json['users'] ?? 0,
      twizzs: json['twizzs'] ?? 0,
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
