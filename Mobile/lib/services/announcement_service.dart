import '../core/services/http_service.dart';
import '../models/announcement_model.dart';

/// Announcement Service
/// Mengelola operasi pengumuman
class AnnouncementService {
  static const String _endpoint = '/announcements';

  // Get All Announcements
  static Future<List<AnnouncementModel>> getAllAnnouncements({
    String? prioritas,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (prioritas != null) queryParams['prioritas'] = prioritas;

      final response = await HttpService.get(
        _endpoint,
        queryParams: queryParams,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data pengumuman');
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pengumuman: ${e.toString()}');
    }
  }

  // Get Announcement by ID
  static Future<AnnouncementModel> getAnnouncementById(String id) async {
    try {
      final response = await HttpService.get(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil detail pengumuman');
      }

      return AnnouncementModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail pengumuman: ${e.toString()}');
    }
  }

  // Create Announcement (Admin only)
  static Future<AnnouncementModel> createAnnouncement({
    required String judul,
    required String isi,
    required String prioritas,
  }) async {
    try {
      final response = await HttpService.post(
        _endpoint,
        body: {
          'judul': judul,
          'isi': isi,
          'prioritas': prioritas,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal membuat pengumuman');
      }

      return AnnouncementModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal membuat pengumuman: ${e.toString()}');
    }
  }

  // Update Announcement (Admin only)
  static Future<AnnouncementModel> updateAnnouncement({
    required String id,
    String? judul,
    String? isi,
    String? prioritas,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (judul != null) body['judul'] = judul;
      if (isi != null) body['isi'] = isi;
      if (prioritas != null) body['prioritas'] = prioritas;

      final response = await HttpService.put(
        '$_endpoint/$id',
        body: body,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate pengumuman');
      }

      return AnnouncementModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate pengumuman: ${e.toString()}');
    }
  }

  // Delete Announcement (Admin only)
  static Future<void> deleteAnnouncement(String id) async {
    try {
      final response = await HttpService.delete(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus pengumuman');
      }
    } catch (e) {
      throw Exception('Gagal menghapus pengumuman: ${e.toString()}');
    }
  }

  // Mark Announcement as Read
  static Future<void> markAsRead(String id) async {
    try {
      final response = await HttpService.post(
        '$_endpoint/$id/mark-read',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menandai pengumuman sebagai dibaca');
      }
    } catch (e) {
      // Silent fail - not critical if marking as read fails
      print('Warning: Failed to mark announcement as read: ${e.toString()}');
    }
  }

  // Get Unread Count
  static Future<int> getUnreadCount() async {
    try {
      final response = await HttpService.get(
        '$_endpoint/unread-count',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil jumlah pengumuman belum dibaca');
      }

      return response['data']['unread_count'] ?? 0;
    } catch (e) {
      print('Warning: Failed to get unread count: ${e.toString()}');
      return 0;
    }
  }
}
