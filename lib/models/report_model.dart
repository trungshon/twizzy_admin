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
  final String userId;
  final String twizzId;
  final ReportReason reason;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? action;
  final String? adminId;
  final User? reporter;
  final Twizz? twizz;

  Report({
    required this.id,
    required this.userId,
    required this.twizzId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.action,
    this.adminId,
    this.reporter,
    this.twizz,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['_id'],
      userId: json['user_id'],
      twizzId: json['twizz_id'],
      reason: ReportReason.values[json['reason']],
      description: json['description'] ?? '',
      status: ReportStatus.values[json['status']],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      action: json['action'],
      adminId: json['admin_id'],
      reporter:
          json['reporter'] != null
              ? User.fromJson(json['reporter'])
              : null,
      twizz:
          json['twizz'] != null
              ? Twizz.fromJson(json['twizz'])
              : null,
    );
  }
}
