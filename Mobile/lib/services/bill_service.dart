import '../core/services/http_service.dart';
import '../core/config/app_config.dart';
import '../models/bill_model.dart';

/// Bill Service (Tagihan)
/// Mengelola operasi tagihan melalui REST API
class BillService {
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
        AppConfig.billsEndpoint,
        queryParams: queryParams,
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => BillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data tagihan: ${e.toString()}');
    }
  }
  
  // Get Bill Statistics (Admin only)
  static Future<Map<String, dynamic>> getBillStatistics() async {
    try {
      final response = await HttpService.get('${AppConfig.billsEndpoint}/statistics');
      return response['data'];
    } catch (e) {
      throw Exception('Gagal mengambil statistik tagihan: ${e.toString()}');
    }
  }
  
  // Get Bill by ID
  static Future<BillModel> getBillById(String id) async {
    try {
      final response = await HttpService.get('${AppConfig.billsEndpoint}/$id');
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
        AppConfig.billsEndpoint,
        body: {
          'tenant_id': tenantId,
          'bulan': bulan,
          'tahun': tahun,
          'jumlah': jumlah,
          'tanggal_jatuh_tempo': tanggalJatuhTempo,
          'keterangan': keterangan,
          'status': 'belum_bayar',
        },
      );
      
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
      if (tanggalJatuhTempo != null) body['tanggal_jatuh_tempo'] = tanggalJatuhTempo;
      if (keterangan != null) body['keterangan'] = keterangan;
      if (status != null) body['status'] = status;
      
      final response = await HttpService.put(
        '${AppConfig.billsEndpoint}/$id',
        body: body,
      );
      
      return BillModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate tagihan: ${e.toString()}');
    }
  }
  
  // Delete Bill (Admin only)
  static Future<void> deleteBill(String id) async {
    try {
      await HttpService.delete('${AppConfig.billsEndpoint}/$id');
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
        '${AppConfig.billsEndpoint}/generate-monthly',
        body: {
          'bulan': bulan,
          'tahun': tahun,
        },
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => BillModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal generate tagihan bulanan: ${e.toString()}');
    }
  }
  
  // Update Overdue Bills (Admin only)
  static Future<Map<String, dynamic>> updateOverdueBills() async {
    try {
      final response = await HttpService.post(
        '${AppConfig.billsEndpoint}/update-overdue',
        body: {},
      );
      
      return response['data'];
    } catch (e) {
      throw Exception('Gagal update tagihan terlambat: ${e.toString()}');
    }
  }
}
