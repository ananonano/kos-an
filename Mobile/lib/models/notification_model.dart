/// Notification Model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // payment, maintenance, announcement, system
  final int? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      relatedId: json['related_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (type) {
      case 'payment':
        return 'Pembayaran';
      case 'maintenance':
        return 'Keluhan';
      case 'announcement':
        return 'Pengumuman';
      case 'system':
        return 'Sistem';
      default:
        return 'Notifikasi';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'payment':
        return '💳';
      case 'maintenance':
        return '🔧';
      case 'announcement':
        return '📢';
      case 'system':
        return '⚙️';
      default:
        return '🔔';
    }
  }
}

