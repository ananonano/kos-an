import 'package:flutter/material.dart';

/// Penghuni Controller
/// Mengelola state dan logic untuk data penghuni
class PenghuniController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // TODO: Implement penghuni methods
  // Similar pattern to KamarController
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
