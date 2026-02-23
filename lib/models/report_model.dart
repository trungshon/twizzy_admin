import 'user_model.dart';
import 'twizz_model.dart';

enum ReportReason {
  spam,
  harassment,
  hateSpeech,
  violence,
  nudity,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.spam:
        return 'Nội dung spam';
      case ReportReason.harassment:
        return 'Quấy rối';
      case ReportReason.hateSpeech:
        return 'Ngôn từ thù địch';
      case ReportReason.violence:
        return 'Bạo lực';
      case ReportReason.nudity:
        return 'Nội dung khiêu dâm';
      case ReportReason.other:
        return 'Lý do khác';
    }
  }
}

enum ReportStatus { pending, resolved, ignored }

class Report {
  final String id;
  final List<String> userIds;
  final String twizzId;
  final List<ReportReason> reasons;
  final List<String> descriptions;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? action;
  final String? adminId;
  final User? reporter;
  final List<User>? reporters;
  final Twizz? twizz;

  Report({
    required this.id,
    required this.userIds,
    required this.twizzId,
    required this.reasons,
    required this.descriptions,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.action,
    this.adminId,
    this.reporter,
    this.reporters,
    this.twizz,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    List<String> extractIds(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((v) => v.toString()).toList();
      }
      return [value.toString()];
    }

    List<ReportReason> extractReasons(
      Map<String, dynamic> json,
    ) {
      if (json['reasons'] != null && json['reasons'] is List) {
        return (json['reasons'] as List)
            .map((e) => ReportReason.values[e as int])
            .toList();
      }
      if (json['reason'] != null) {
        return [ReportReason.values[json['reason'] as int]];
      }
      return [ReportReason.other];
    }

    List<String> extractDescriptions(Map<String, dynamic> json) {
      if (json['descriptions'] != null &&
          json['descriptions'] is List) {
        return (json['descriptions'] as List)
            .map((e) => e.toString())
            .toList();
      }
      if (json['description'] != null &&
          json['description'].toString().isNotEmpty) {
        return [json['description'].toString()];
      }
      return [];
    }

    return Report(
      id: json['_id'],
      userIds: extractIds(json['user_ids'] ?? json['user_id']),
      twizzId: json['twizz_id'],
      reasons: extractReasons(json),
      descriptions: extractDescriptions(json),
      status: ReportStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      action: json['action'],
      adminId: json['admin_id'],
      reporter:
          json['reporter'] != null
              ? User.fromJson(json['reporter'])
              : null,
      reporters:
          json['reporters'] != null
              ? (json['reporters'] as List)
                  .map((e) => User.fromJson(e))
                  .toList()
              : null,
      twizz:
          json['twizz'] != null
              ? Twizz.fromJson(json['twizz'])
              : null,
    );
  }
}
