import '../core/services/http_service.dart';
import '../core/config/app_config.dart';
import '../models/maintenance_model.dart';

/// Maintenance Service
/// Mengelola operasi maintenance/perbaikan melalui REST API
class MaintenanceService {
  // Get All Maintenance
  static Future<List<MaintenanceModel>> getAllMaintenance({
    String? status,
    String? roomId,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (roomId != null) queryParams['room_id'] = roomId;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await HttpService.get(
        AppConfig.maintenanceEndpoint,
        queryParams: queryParams,
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => MaintenanceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data maintenance: ${e.toString()}');
    }
  }
  
  // Get Maintenance by ID
  static Future<MaintenanceModel> getMaintenanceById(String id) async {
    try {
      final response = await HttpService.get('${AppConfig.maintenanceEndpoint}/$id');
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail maintenance: ${e.toString()}');
    }
  }
  
  // Create Maintenance
  static Future<MaintenanceModel> createMaintenance({
    required String roomId,
    required String judul,
    required String deskripsi,
    String? foto,
    String? reportedBy,
  }) async {
    try {
      final response = await HttpService.post(
        AppConfig.maintenanceEndpoint,
        body: {
          'room_id': roomId,
          'judul': judul,
          'deskripsi': deskripsi,
          'foto': foto,
          'reported_by': reportedBy,
          'status': 'pending',
        },
      );
      
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal membuat maintenance: ${e.toString()}');
    }
  }
  
  // Update Maintenance
  static Future<MaintenanceModel> updateMaintenance({
    required String id,
    String? judul,
    String? deskripsi,
    String? foto,
    String? status,
    String? keterangan,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (judul != null) body['judul'] = judul;
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (foto != null) body['foto'] = foto;
      if (status != null) body['status'] = status;
      if (keterangan != null) body['keterangan'] = keterangan;
      
      final response = await HttpService.put(
        '${AppConfig.maintenanceEndpoint}/$id',
        body: body,
      );
      
      return MaintenanceModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate maintenance: ${e.toString()}');
    }
  }
  
  // Delete Maintenance
  static Future<void> deleteMaintenance(String id) async {
    try {
      await HttpService.delete('${AppConfig.maintenanceEndpoint}/$id');
    } catch (e) {
      throw Exception('Gagal menghapus maintenance: ${e.toString()}');
    }
  }
}
