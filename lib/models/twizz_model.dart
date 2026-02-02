class Twizz {
  final String id;
  final String userId;
  final int type;
  final int audience;
  final String content;
  final String? parentId;
  final List<String> hashtags;
  final List<String> mentions;
  final List<Media> medias;
  final int guestViews;
  final int userViews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TwizzUser? user;

  Twizz({
    required this.id,
    required this.userId,
    required this.type,
    required this.audience,
    required this.content,
    this.parentId,
    required this.hashtags,
    required this.mentions,
    required this.medias,
    required this.guestViews,
    required this.userViews,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Twizz.fromJson(Map<String, dynamic> json) {
    return Twizz(
      id: json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 0,
      audience: json['audience'] ?? 0,
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      hashtags:
          (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mentions:
          (json['mentions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medias:
          (json['medias'] as List<dynamic>?)
              ?.map((e) => Media.fromJson(e))
              .toList() ??
          [],
      guestViews: json['guest_views'] ?? 0,
      userViews: json['user_views'] ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      user:
          json['user'] != null
              ? TwizzUser.fromJson(json['user'])
              : null,
    );
  }

  String get typeText {
    switch (type) {
      case 0:
        return 'Bài viết';
      case 1:
        return 'Bình luận';
      case 2:
        return 'Trích dẫn';
      default:
        return 'Không xác định';
    }
  }

  int get totalViews => guestViews + userViews;
}

class TwizzUser {
  final String id;
  final String name;
  final String username;
  final String? avatar;

  TwizzUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatar,
  });

  factory TwizzUser.fromJson(Map<String, dynamic> json) {
    return TwizzUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class Media {
  final String url;
  final int type;

  Media({required this.url, required this.type});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      url: json['url'] ?? '',
      type: json['type'] ?? 0,
    );
  }
}
