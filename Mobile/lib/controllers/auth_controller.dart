import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/services/notification_polling_service.dart';

/// Authentication Controller
/// Mengelola state dan logic untuk autentikasi
class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  
  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _currentUser = AuthService.getCurrentUser();
    
    // Start notification polling if user is logged in
    if (_currentUser != null) {
      await NotificationPollingService.start();
    }
    
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentUser = await AuthService.login(email, password);
      
      // Start notification polling after successful login
      if (_currentUser != null) {
        await NotificationPollingService.start();
      }
      
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
  
  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String noTelepon,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _currentUser = await AuthService.register(
        email: email,
        password: password,
        nama: nama,
        noTelepon: noTelepon,
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
  
  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Stop notification polling
      NotificationPollingService.stop();
      
      await AuthService.logout();
      _currentUser = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Get Admin User (for chat)
  Future<Map<String, dynamic>?> getAdminUser() async {
    try {
      return await AuthService.getAdminUser();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
