import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

/// Dashboard Controller
/// Mengelola state dan logic untuk dashboard
class DashboardController extends ChangeNotifier {
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _pendingPayments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get pendingPayments => _pendingPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get Dashboard Data
  Future<void> getDashboardData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final data = await DashboardService.getAdminDashboard();
      _dashboardData = data;
      
      // Get pending payments
      _pendingPayments = await DashboardService.getPendingPayments();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Helper getters for stats
  int get totalTenants => _dashboardData?['tenants']?['aktif'] ?? 0;
  int get totalRooms => _dashboardData?['rooms']?['total'] ?? 0;
  int get occupiedRooms => _dashboardData?['rooms']?['terisi'] ?? 0;
  int get availableRooms => _dashboardData?['rooms']?['kosong'] ?? 0;
  double get totalIncome => (_dashboardData?['payments']?['total_amount'] ?? 0).toDouble();
  int get unpaidBills => _dashboardData?['bills']?['total_belum_lunas'] ?? 0;
  int get pendingPaymentsCount => _dashboardData?['payments']?['total_pending'] ?? 0;
  int get pendingMaintenance => _dashboardData?['maintenance']?['baru'] ?? 0;
  
  double get occupancyRate {
    if (totalRooms == 0) return 0;
    return (occupiedRooms / totalRooms) * 100;
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
