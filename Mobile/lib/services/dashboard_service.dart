import '../core/services/http_service.dart';

/// Dashboard Service
/// Mengelola operasi dashboard untuk tenant
class DashboardService {
  // Note: Dashboard data untuk tenant diambil langsung dari endpoints masing-masing
  // (bills, payments, maintenance, announcements)
  // Service ini bisa dihapus jika tidak digunakan
  
  // Get Pending Payments
  static Future<List<dynamic>> getPendingPayments() async {
    try {
      final response = await HttpService.get(
        '/payments',
        queryParams: {
          'status': 'menunggu_verifikasi',
          'limit': '5',
        },
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil pembayaran pending');
      }
      
      return response['data'] ?? [];
    } catch (e) {
      print('❌ [DashboardService] Error getting pending payments: $e');
      return [];
    }
  }
}
