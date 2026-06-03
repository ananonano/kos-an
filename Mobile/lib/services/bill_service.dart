import '../core/services/http_service.dart';
import '../models/bill_model.dart';

/// Bill Service (Tagihan)
/// Mengelola operasi tagihan melalui REST API
class BillService {
  static const String _endpoint = '/bills';

  // Get All Bills
  static Future<List<BillModel>> getAllBills({
    String? status,
    String? tenantId,
    String? bulan,
    String? tahun,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (tenantId != null) queryParams['tenant_id'] = tenantId;
      if (bulan != null) queryParams['bulan'] = bulan;
      if (tahun != null) queryParams['tahun'] = tahun;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await HttpService.get(
        _endpoint,
        queryParams: queryParams,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data tagihan');
      }
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data tagihan: ${e.toString()}');
    }
  }
  
  // Get Bill Statistics (Admin only)
  static Future<Map<String, dynamic>> getBillStatistics() async {
    try {
      final response = await HttpService.get('$_endpoint/statistics');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil statistik tagihan');
      }
      
      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil statistik tagihan: ${e.toString()}');
    }
  }
  
  // Get Bill by ID
  static Future<BillModel> getBillById(String id) async {
    try {
      final response = await HttpService.get('$_endpoint/$id');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil detail tagihan');
      }
      
      return BillModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail tagihan: ${e.toString()}');
    }
  }
  
  // Create Bill (Admin only)
  static Future<BillModel> createBill({
    required String tenantId,
    required String bulan,
    required String tahun,
    required double jumlah,
    required String tanggalJatuhTempo,
    String? keterangan,
  }) async {
    try {
      final response = await HttpService.post(
        _endpoint,
        body: {
          'tenant_id': tenantId,
          'bulan': bulan,
          'tahun': tahun,
          'jumlah': jumlah,
          'jatuh_tempo': tanggalJatuhTempo,
          'catatan': keterangan,
          'status': 'belum_lunas',
        },
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal membuat tagihan');
      }
      
      return BillModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal membuat tagihan: ${e.toString()}');
    }
  }
  
  // Update Bill (Admin only)
  static Future<BillModel> updateBill({
    required String id,
    String? bulan,
    String? tahun,
    double? jumlah,
    String? tanggalJatuhTempo,
    String? keterangan,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (bulan != null) body['bulan'] = bulan;
      if (tahun != null) body['tahun'] = tahun;
      if (jumlah != null) body['jumlah'] = jumlah;
      if (tanggalJatuhTempo != null) body['jatuh_tempo'] = tanggalJatuhTempo;
      if (keterangan != null) body['catatan'] = keterangan;
      if (status != null) body['status'] = status;
      
      final response = await HttpService.put(
        '$_endpoint/$id',
        body: body,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate tagihan');
      }
      
      return BillModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate tagihan: ${e.toString()}');
    }
  }
  
  // Delete Bill (Admin only)
  static Future<void> deleteBill(String id) async {
    try {
      final response = await HttpService.delete('$_endpoint/$id');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus tagihan');
      }
    } catch (e) {
      throw Exception('Gagal menghapus tagihan: ${e.toString()}');
    }
  }
  
  // Generate Monthly Bills (Admin only)
  static Future<List<BillModel>> generateMonthlyBills({
    required String bulan,
    required String tahun,
  }) async {
    try {
      final response = await HttpService.post(
        '$_endpoint/generate-monthly',
        body: {
          'bulan': bulan,
          'tahun': tahun,
        },
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal generate tagihan bulanan');
      }
      
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal generate tagihan bulanan: ${e.toString()}');
    }
  }
  
  // Update Overdue Bills (Admin only)
  static Future<Map<String, dynamic>> updateOverdueBills() async {
    try {
      final response = await HttpService.post(
        '$_endpoint/update-overdue',
        body: {},
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal update tagihan terlambat');
      }
      
      return response['data'];
    } catch (e) {
      throw Exception('Gagal update tagihan terlambat: ${e.toString()}');
    }
  }
}
