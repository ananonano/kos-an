import '../core/services/http_service.dart';
import '../core/config/app_config.dart';
import '../models/kamar_model.dart';

/// Kamar Service
/// Mengelola operasi CRUD kamar melalui REST API
class KamarService {
  // Get All Kamar
  static Future<List<KamarModel>> getAllKamar({
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
        AppConfig.kamarEndpoint,
        queryParams: queryPar
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => KamarModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kamar: ${e.toString()}');
    }
  }
  
  // Get Kamar by ID
  static Future<KamarModel> getKamarById(String id) async {
    try {
      final response = await HttpService.get('${AppConfig.kamarEndpoint}/$id');
      return KamarModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail kamar: ${e.toString()}');
    }
  }
  
  // Create Kamar (Admin only)
  static Future<KamarModel> createKamar({
    required String nomorKamar,
    required String tipe,
    required double harga,
    String? deskripsi,
    List<String>? fasilitas,
  }) async {
    try {
      final response = await HttpService.post(
        AppConfig.kamarEndpoint,
        body: {
          'nomor_kamar': nomorKamar,
          'tipe': tipe,
          'harga': harga,
          'deskripsi': deskripsi,
          'fasilitas': fasilitas,
          'status': 'kosong',
        },
      );
      
      return KamarModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal menambah kamar: ${e.toString()}');
    }
  }
  
  // Update Kamar (Admin only)
  static Future<KamarModel> updateKamar({
    required String id,
    String? nomorKamar,
    String? tipe,
    double? harga,
    String? status,
    String? deskripsi,
    List<String>? fasilitas,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nomorKamar != null) body['nomor_kamar'] = nomorKamar;
      if (tipe != null) body['tipe'] = tipe;
      if (harga != null) body['harga'] = harga;
      if (status != null) body['status'] = status;
      if (deskripsi != null) body['deskripsi'] = deskripsi;
      if (fasilitas != null) body['fasilitas'] = fasilitas;
      
      final response = await HttpService.put(
        '${AppConfig.kamarEndpoint}/$id',
        body: body,
      );
      
      return KamarModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate kamar: ${e.toString()}');
    }
  }
  
  // Delete Kamar (Admin only)
  static Future<void> deleteKamar(String id) async {
    try {
      await HttpService.delete('${AppConfig.kamarEndpoint}/$id');
    } catch (e) {
      throw Exception('Gagal menghapus kamar: ${e.toString()}');
    }
  }
}
