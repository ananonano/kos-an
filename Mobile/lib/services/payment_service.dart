import '../core/services/http_service.dart';
import '../core/config/app_config.dart';
import '../models/payment_model.dart';

/// Payment Service
/// Mengelola operasi pembayaran
class PaymentService {
  static const String _endpoint = '/payments';

  // Get All Payments
  static Future<List<PaymentModel>> getAllPayments({
    String? status,
    String? penghuniId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (penghuniId != null) queryParams['penghuni_id'] = penghuniId;

      final response = await HttpService.get(
        '${AppConfig.apiBaseUrl}$_endpoint',
        queryParams: queryParams,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data pembayaran');
      }

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pembayaran: ${e.toString()}');
    }
  }

  // Get Payment by ID
  static Future<PaymentModel> getPaymentById(String id) async {
    try {
      final response = await HttpService.get(
        '${AppConfig.apiBaseUrl}$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil detail pembayaran');
      }

      return PaymentModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengambil detail pembayaran: ${e.toString()}');
    }
  }

  // Create Payment
  static Future<PaymentModel> createPayment({
    required String tagihanId,
    required double jumlah,
    required String metodePembayaran,
    String? buktiPembayaran,
    String? keterangan,
  }) async {
    try {
      final response = await HttpService.post(
        '${AppConfig.apiBaseUrl}$_endpoint',
        body: {
          'tagihan_id': tagihanId,
          'jumlah': jumlah,
          'metode_pembayaran': metodePembayaran,
          if (buktiPembayaran != null) 'bukti_pembayaran': buktiPembayaran,
          if (keterangan != null) 'keterangan': keterangan,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal membuat pembayaran');
      }

      return PaymentModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal membuat pembayaran: ${e.toString()}');
    }
  }

  // Upload Payment Proof
  static Future<PaymentModel> uploadPaymentProof({
    required String paymentId,
    required String imagePath,
  }) async {
    try {
      // TODO: Implement file upload using multipart
      // For now, just update with image path
      final response = await HttpService.put(
        '${AppConfig.apiBaseUrl}$_endpoint/$paymentId',
        body: {
          'bukti_pembayaran': imagePath,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal upload bukti pembayaran');
      }

      return PaymentModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal upload bukti pembayaran: ${e.toString()}');
    }
  }

  // Update Payment Status (Admin only)
  static Future<PaymentModel> updatePaymentStatus({
    required String id,
    required String status,
    String? keterangan,
  }) async {
    try {
      final response = await HttpService.put(
        '${AppConfig.apiBaseUrl}$_endpoint/$id',
        body: {
          'status': status,
          if (keterangan != null) 'keterangan': keterangan,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengupdate status pembayaran');
      }

      return PaymentModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal mengupdate status pembayaran: ${e.toString()}');
    }
  }

  // Delete Payment
  static Future<void> deletePayment(String id) async {
    try {
      final response = await HttpService.delete(
        '${AppConfig.apiBaseUrl}$_endpoint/$id',
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal menghapus pembayaran');
      }
    } catch (e) {
      throw Exception('Gagal menghapus pembayaran: ${e.toString()}');
    }
  }
}
