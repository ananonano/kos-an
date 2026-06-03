import '../core/services/http_service.dart';
import '../models/maintenance_model.dart';

/// Maintenance Service (Keluhan)
/// Mengelola operasi maintenance/keluhan melalui REST API
class MaintenanceService {
  static const String _endpoint = '/maintenance';

  // Get All Maintenance
  static Future<List<MaintenanceModel>> getAllMaintenance({
    String? tenantId,
    String? kamarId,
    String? status,
    String? prioritas,
    String? kategori,
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      print('🔍 [MaintenanceService] Getting all maintenance...');
      print('📍 Endpoint: $_endpoint');
      
      final queryParams = <String, String>{};
      if (tenantId != null) queryParams['tenant_id'] = tenantId;
      if (kamarId != null) queryParams['kamar_id'] = kamarId;
      if (status != null) queryParams['status'] = status;
      if (prioritas != null) queryParams['prioritas'] = prioritas;
      if (kategori != null) queryParams['kategori'] = kategori;
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await HttpService.get(
        _endpoint,
        queryParams: queryParams,
      );
      
      print('✅ [MaintenanceService] Response received: ${response['success']}');

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data keluhan');
      }

      final List<dynamic> data = response['data'] ?? [];
      print('📊 [MaintenanceService] Found ${data.length} maintenance requests');
      return data.map((json) => MaintenanceModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal mengambil data keluhan: ${e.toString()}');
    }
  }

  // Get Maintenance by ID
  static Future<MaintenanceModel> getMaintenanceById(String id) async {
    try {
      print('🔍 [MaintenanceService] Getting maintenance by ID: $id');
      
      final response = await HttpService.get(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil detail keluhan');
      }

      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal mengambil detail keluhan: ${e.toString()}');
    }
  }

  // Create Maintenance
  static Future<MaintenanceModel> createMaintenance({
    required int tenantId,
    required int kamarId,
    required String judul,
    required String deskripsi,
    required String kategori,
    String prioritas = 'sedang',
    List<String>? foto,
  }) async {
    try {
      print('🔍 [MaintenanceService] Creating maintenance...');
      
      final response = await HttpService.post(
        _endpoint,
        body: {
          'tenant_id': tenantId,
          'kamar_id': kamarId,
          'judul': judul,
          'deskripsi': deskripsi,
          'kategori': kategori,
          'prioritas': prioritas,
          if (foto != null && foto.isNotEmpty) 'foto': foto,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal membuat laporan keluhan');
      }

      print('✅ [MaintenanceService] Maintenance created successfully');
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal membuat laporan keluhan: ${e.toString()}');
    }
  }

  // Update Maintenance
  static Future<MaintenanceModel> updateMaintenance({
    required String id,
    String? judul,
    String? deskripsi,
    String? kategori,
    String? prioritas,
    String? status,
    List<String>? foto,
    String? komentarAdmin,
    double? biaya,
    DateTime? tanggalSelesai,
  }) async {
    try {
      print('🔍 [MaintenanceService] Updating maintenance: $id');
      
      final body = <String, dynamic>{};
      if (judul != null) body['judul'] = judul;
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (kategori != null) body['kategori'] = kategori;
      if (prioritas != null) body['prioritas'] = prioritas;
      if (status != null) body['status'] = status;
      if (foto != null) body['foto'] = foto;
      if (komentarAdmin != null) body['komentar_admin'] = komentarAdmin;
      if (biaya != null) body['biaya'] = biaya;
      if (tanggalSelesai != null) {
        body['tanggal_selesai'] = tanggalSelesai.toIso8601String();
      }

      final response = await HttpService.put(
        '$_endpoint/$id',
        body: body,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate keluhan');
      }

      print('✅ [MaintenanceService] Maintenance updated successfully');
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal mengupdate keluhan: ${e.toString()}');
    }
  }

  // Update Status (Admin only)
  static Future<MaintenanceModel> updateStatus({
    required String id,
    required String status,
    String? komentarAdmin,
    double? biaya,
  }) async {
    try {
      print('🔍 [MaintenanceService] Updating status: $id -> $status');
      
      final response = await HttpService.put(
        '$_endpoint/$id/status',
        body: {
          'status': status,
          if (komentarAdmin != null) 'komentar_admin': komentarAdmin,
          if (biaya != null) 'biaya': biaya,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate status');
      }

      print('✅ [MaintenanceService] Status updated successfully');
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal mengupdate status: ${e.toString()}');
    }
  }

  // Delete Maintenance (Admin only)
  static Future<void> deleteMaintenance(String id) async {
    try {
      print('🔍 [MaintenanceService] Deleting maintenance: $id');
      
      final response = await HttpService.delete(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus keluhan');
      }

      print('✅ [MaintenanceService] Maintenance deleted successfully');
    } catch (e) {
      print('❌ [MaintenanceService] Error: $e');
      throw Exception('Gagal menghapus keluhan: ${e.toString()}');
    }
  }

  // Get Statistics (Admin only)
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await HttpService.get(
        '$_endpoint/statistics',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil statistik');
      }

      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil statistik: ${e.toString()}');
    }
  }

  // Get Urgent Maintenance (Admin only)
  static Future<List<MaintenanceModel>> getUrgentMaintenance() async {
    try {
      final response = await HttpService.get(
        '$_endpoint/urgent',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil keluhan urgent');
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => MaintenanceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil keluhan urgent: ${e.toString()}');
    }
  }

  // Get By Category (Admin only)
  static Future<Map<String, dynamic>> getByCategory() async {
    try {
      final response = await HttpService.get(
        '$_endpoint/by-category',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data kategori');
      }

      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil data kategori: ${e.toString()}');
    }
  }
}
