import 'package:flutter/material.dart';

/// Pembayaran Controller
/// Mengelola state dan logic untuk pembayaran
class PembayaranController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // TODO: Implement pembayaran methods
  // Similar pattern to KamarController
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
