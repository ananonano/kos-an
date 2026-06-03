import '../core/services/http_service.dart';
import '../models/penghuni_model.dart';

/// Tenant Service (Penghuni)
/// Mengelola operasi tenant/penghuni melalui REST API
class TenantService {
  static const String _endpoint = '/tenants';

  // Get All Tenants
  static Future<List<PenghuniModel>> getAllTenants({
    String? status,
    String? kamarId,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (kamarId != null) queryParams['kamar_id'] = kamarId;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await HttpService.get(
        _endpoint,
        queryParams: queryParams,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data penghuni');
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PenghuniModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data penghuni: ${e.toString()}');
    }
  }

  // Get Tenant by ID
  static Future<PenghuniModel> getTenantById(String id) async {
    try {
      final response = await HttpService.get(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil detail penghuni');
      }

      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail penghuni: ${e.toString()}');
    }
  }

  // Create Tenant
  static Future<PenghuniModel> createTenant({
    required String nama,
    required String email,
    required String noTelepon,
    String? kamarId,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    DateTime? tanggalMasuk,
  }) async {
    try {
      final response = await HttpService.post(
        _endpoint,
        body: {
          'nama': nama,
          'email': email,
          'no_telepon': noTelepon,
          if (kamarId != null) 'kamar_id': kamarId,
          if (alamatAsal != null) 'alamat_asal': alamatAsal,
          if (pekerjaan != null) 'pekerjaan': pekerjaan,
          if (kontakDarurat != null) 'kontak_darurat': kontakDarurat,
          if (tanggalMasuk != null)
            'tanggal_masuk': tanggalMasuk.toIso8601String().split('T')[0],
          'status': 'aktif',
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menambah penghuni');
      }

      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal menambah penghuni: ${e.toString()}');
    }
  }

  // Update Tenant
  static Future<PenghuniModel> updateTenant({
    required String id,
    String? nama,
    String? email,
    String? noTelepon,
    String? kamarId,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    DateTime? tanggalMasuk,
    DateTime? tanggalKeluar,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nama != null) body['nama'] = nama;
      if (email != null) body['email'] = email;
      if (noTelepon != null) body['no_telepon'] = noTelepon;
      if (kamarId != null) body['kamar_id'] = kamarId;
      if (alamatAsal != null) body['alamat_asal'] = alamatAsal;
      if (pekerjaan != null) body['pekerjaan'] = pekerjaan;
      if (kontakDarurat != null) body['kontak_darurat'] = kontakDarurat;
      if (tanggalMasuk != null)
        body['tanggal_masuk'] = tanggalMasuk.toIso8601String().split('T')[0];
      if (tanggalKeluar != null)
        body['tanggal_keluar'] = tanggalKeluar.toIso8601String().split('T')[0];
      if (status != null) body['status'] = status;

      final response = await HttpService.put(
        '$_endpoint/$id',
        body: body,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate penghuni');
      }

      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate penghuni: ${e.toString()}');
    }
  }

  // Delete Tenant
  static Future<void> deleteTenant(String id) async {
    try {
      final response = await HttpService.delete(
        '$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus penghuni');
      }
    } catch (e) {
      throw Exception('Gagal menghapus penghuni: ${e.toString()}');
    }
  }

  // Assign Room to Tenant
  static Future<PenghuniModel> assignRoom({
    required String tenantId,
    required String kamarId,
    required DateTime tanggalMasuk,
  }) async {
    try {
      final response = await HttpService.put(
        '$_endpoint/$tenantId/assign-room',
        body: {
          'kamar_id': kamarId,
          'tanggal_masuk': tanggalMasuk.toIso8601String().split('T')[0],
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal assign kamar');
      }

      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal assign kamar: ${e.toString()}');
    }
  }

  // Remove Room from Tenant
  static Future<PenghuniModel> removeRoom({
    required String tenantId,
    required DateTime tanggalKeluar,
  }) async {
    try {
      final response = await HttpService.put(
        '$_endpoint/$tenantId/remove-room',
        body: {
          'tanggal_keluar': tanggalKeluar.toIso8601String().split('T')[0],
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal remove kamar');
      }

      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal remove kamar: ${e.toString()}');
    }
  }

  // Get Tenant Statistics (Admin only)
  static Future<Map<String, dynamic>> getTenantStatistics() async {
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
  
  // Get Tenant by User ID
  static Future<PenghuniModel?> getTenantByUserId(String userId) async {
    try {
      print('🔍 [TenantService] Getting tenant by user_id: $userId');
      
      // Use new backend endpoint instead of filtering client-side
      final response = await HttpService.get(
        '$_endpoint/by-user/$userId',
      );

      if (response['success'] != true) {
        print('⚠️ [TenantService] ❌ Tenant not found for user_id: $userId');
        print('⚠️ [TenantService] ${response['message']}');
        return null;
      }

      print('✅ [TenantService] Found tenant from backend');
      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      print('❌ [TenantService] Error: $e');
      return null;
    }
  }
}
