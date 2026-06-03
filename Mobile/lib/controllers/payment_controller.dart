import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

/// Payment Controller
/// Mengelola state dan logic untuk pembayaran
class PaymentController extends ChangeNotifier {
  List<PaymentModel> _paymentList = [];
  PaymentModel? _selectedPayment;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<PaymentModel> get paymentList => _paymentList;
  PaymentModel? get selectedPayment => _selectedPayment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get Payment History
  Future<void> getPaymentHistory({String? tenantId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _paymentList = await PaymentService.getAllPayments(penghuniId: tenantId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Payment Detail
  Future<void> getPaymentDetail(String paymentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _selectedPayment = await PaymentService.getPaymentById(paymentId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Create Payment
  Future<bool> createPayment({
    required String billId,
    required int tenantId,
    required double jumlah,
    required String metodePembayaran,
    String? buktiPembayaran,
    String? keterangan,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await PaymentService.createPayment(
        billId: billId,
        tenantId: tenantId,
        jumlah: jumlah,
        metodePembayaran: metodePembayaran,
        buktiPembayaran: buktiPembayaran,
        keterangan: keterangan,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Upload Payment Proof
  Future<bool> uploadPaymentProof({
    required String paymentId,
    required String imagePath,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await PaymentService.uploadPaymentProof(
        paymentId: paymentId,
        imagePath: imagePath,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
  
  // Get Pending Payments
  List<PaymentModel> get pendingPayments {
    return _paymentList.where((payment) => payment.status == 'menunggu_verifikasi').toList();
  }
  
  // Get Verified Payments
  List<PaymentModel> get verifiedPayments {
    return _paymentList.where((payment) => payment.status == 'lunas').toList();
  }
  
  // Get Rejected Payments
  List<PaymentModel> get rejectedPayments {
    return _paymentList.where((payment) => payment.status == 'ditolak').toList();
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Clear Selected Payment
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }
}
