import '../core/services/http_service.dart';

/// Dashboard Service
/// Mengelola operasi dashboard
class DashboardService {
  static const String _endpoint = '/dashboard';

  // Get Admin Dashboard
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      print('🔍 [DashboardService] Getting admin dashboard...');
      
      final response = await HttpService.get('$_endpoint/admin');
      
      print('✅ [DashboardService] Response received: ${response['success']}');
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data dashboard');
      }
      
      return response['data'];
    } catch (e) {
      print('❌ [DashboardService] Error: $e');
      throw Exception('Gagal mengambil data dashboard: ${e.toString()}');
    }
  }
  
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
