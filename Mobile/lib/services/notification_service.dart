import '../core/services/http_service.dart';
import '../models/notification_model.dart';

/// Notification Service
/// Service untuk mengelola notifikasi dari backend
class NotificationService {
  static const String _endpoint = '/notifications';

  // Get All Notifications
  static Future<List<NotificationModel>> getAllNotifications({
    bool? isRead,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (isRead != null) queryParams['is_read'] = isRead.toString();
      if (type != null) queryParams['type'] = type;

      final response = await HttpService.get(
        _endpoint,
        queryParams: queryParams,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data notifikasi');
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data notifikasi: ${e.toString()}');
    }
  }

  // Get Unread Count
  static Future<int> getUnreadCount() async {
    try {
      final response = await HttpService.get(
        '$_endpoint/unread-count',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil jumlah notifikasi belum dibaca');
      }

      return response['data']['unread_count'] ?? 0;
    } catch (e) {
      print('Warning: Failed to get unread count: ${e.toString()}');
      return 0;
    }
  }

  // Mark Notification as Read
  static Future<void> markAsRead(String id) async {
    try {
      final response = await HttpService.post(
        '$_endpoint/$id/mark-read',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menandai notifikasi sebagai dibaca');
      }
    } catch (e) {
      // Silent fail - not critical if marking as read fails
      print('Warning: Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark All Notifications as Read
  static Future<void> markAllAsRead() async {
    try {
      final response = await HttpService.post(
        '$_endpoint/mark-all-read',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menandai semua notifikasi sebagai dibaca');
      }
    } catch (e) {
      throw Exception('Gagal menandai semua notifikasi sebagai dibaca: ${e.toString()}');
    }
  }

  // Delete Notification
  static Future<void> deleteNotification(String id) async {
    try {
      final response = await HttpService.delete(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus notifikasi');
      }
    } catch (e) {
      throw Exception('Gagal menghapus notifikasi: ${e.toString()}');
    }
  }
}

