import '../core/services/http_service.dart';
import '../core/config/app_config.dart';
import '../models/penghuni_model.dart';

/// Tenant Service (Penghuni)
/// Mengelola operasi CRUD penghuni melalui REST API
class TenantService {
  // Get All Tenants
  static Future<List<PenghuniModel>> getAllTenants({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await HttpService.get(
        AppConfig.tenantsEndpoint,
        queryParams: queryParams,
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => PenghuniModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data penghuni: ${e.toString()}');
    }
  }
  
  // Get Tenant by ID
  static Future<PenghuniModel> getTenantById(String id) async {
    try {
      final response = await HttpService.get('${AppConfig.tenantsEndpoint}/$id');
      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail penghuni: ${e.toString()}');
    }
  }
  
  // Get Tenant Statistics (Admin only)
  static Future<Map<String, dynamic>> getTenantStatistics() async {
    try {
      final response = await HttpService.get('${AppConfig.tenantsEndpoint}/statistics');
      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil statistik penghuni: ${e.toString()}');
    }
  }
  
  // Create Tenant (Admin only)
  static Future<PenghuniModel> createTenant({
    required String userId,
    required String roomId,
    required String nama,
    required String noTelepon,
    required String email,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    String? fotoKtp,
  }) async {
    try {
      final response = await HttpService.post(
        AppConfig.tenantsEndpoint,
        body: {
          'user_id': userId,
          'room_id': roomId,
          'nama': nama,
          'no_telepon': noTelepon,
          'email': email,
          'alamat_asal': alamatAsal,
          'pekerjaan': pekerjaan,
          'kontak_darurat': kontakDarurat,
          'foto_ktp': fotoKtp,
          'status': 'aktif',
        },
      );
      
      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal menambah penghuni: ${e.toString()}');
    }
  }
  
  // Update Tenant (Admin only)
  static Future<PenghuniModel> updateTenant({
    required String id,
    String? roomId,
    String? nama,
    String? noTelepon,
    String? email,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    String? fotoKtp,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (roomId != null) body['room_id'] = roomId;
      if (nama != null) body['nama'] = nama;
      if (noTelepon != null) body['no_telepon'] = noTelepon;
      if (email != null) body['email'] = email;
      if (alamatAsal != null) body['alamat_asal'] = alamatAsal;
      if (pekerjaan != null) body['pekerjaan'] = pekerjaan;
      if (kontakDarurat != null) body['kontak_darurat'] = kontakDarurat;
      if (fotoKtp != null) body['foto_ktp'] = fotoKtp;
      if (status != null) body['status'] = status;
      
      final response = await HttpService.put(
        '${AppConfig.tenantsEndpoint}/$id',
        body: body,
      );
      
      return PenghuniModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate penghuni: ${e.toString()}');
    }
  }
  
  // Delete Tenant (Admin only)
  static Future<void> deleteTenant(String id) async {
    try {
      await HttpService.delete('${AppConfig.tenantsEndpoint}/$id');
    } catch (e) {
      throw Exception('Gagal menghapus penghuni: ${e.toString()}');
    }
  }
}
