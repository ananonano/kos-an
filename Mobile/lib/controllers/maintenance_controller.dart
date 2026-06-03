import 'package:flutter/material.dart';
import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';

/// Maintenance Controller (Keluhan)
/// Mengelola state dan logic untuk maintenance/keluhan
class MaintenanceController extends ChangeNotifier {
  List<MaintenanceModel> _maintenanceList = [];
  MaintenanceModel? _selectedMaintenance;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<MaintenanceModel> get maintenanceList => _maintenanceList;
  MaintenanceModel? get selectedMaintenance => _selectedMaintenance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get All Maintenance
  Future<void> getAllMaintenance({
    String? tenantId,
    String? kamarId,
    String? status,
    String? prioritas,
    String? kategori,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _maintenanceList = await MaintenanceService.getAllMaintenance(
        tenantId: tenantId,
        kamarId: kamarId,
        status: status,
        prioritas: prioritas,
        kategori: kategori,
        search: search,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Maintenance Detail
  Future<void> getMaintenanceDetail(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _selectedMaintenance = await MaintenanceService.getMaintenanceById(id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Create Maintenance
  Future<bool> createMaintenance({
    required int tenantId,
    required int kamarId,
    required String judul,
    required String deskripsi,
    required String kategori,
    String prioritas = 'sedang',
    List<String>? foto,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final maintenance = await MaintenanceService.createMaintenance(
        tenantId: tenantId,
        kamarId: kamarId,
        judul: judul,
        deskripsi: deskripsi,
        kategori: kategori,
        prioritas: prioritas,
        foto: foto,
      );
      
      // Add to list
      _maintenanceList.insert(0, maintenance);
      
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
  
  // Update Status (Admin only)
  Future<bool> updateStatus({
    required String id,
    required String status,
    String? komentarAdmin,
    double? biaya,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final updated = await MaintenanceService.updateStatus(
        id: id,
        status: status,
        komentarAdmin: komentarAdmin,
        biaya: biaya,
      );
      
      // Update in list
      final index = _maintenanceList.indexWhere((m) => m.id == id);
      if (index != -1) {
        _maintenanceList[index] = updated;
      }
      
      // Update selected if it's the same
      if (_selectedMaintenance?.id == id) {
        _selectedMaintenance = updated;
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
  
  // Delete Maintenance (Admin only)
  Future<bool> deleteMaintenance(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await MaintenanceService.deleteMaintenance(id);
      
      // Remove from list
      _maintenanceList.removeWhere((m) => m.id == id);
      
      // Clear selected if it's the same
      if (_selectedMaintenance?.id == id) {
        _selectedMaintenance = null;
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
  
  // Filter by Status
  List<MaintenanceModel> get newMaintenance {
    return _maintenanceList.where((m) => m.status == 'baru').toList();
  }
  
  List<MaintenanceModel> get inProgressMaintenance {
    return _maintenanceList.where((m) => m.status == 'diproses').toList();
  }
  
  List<MaintenanceModel> get completedMaintenance {
    return _maintenanceList.where((m) => m.status == 'selesai').toList();
  }
  
  List<MaintenanceModel> get rejectedMaintenance {
    return _maintenanceList.where((m) => m.status == 'ditolak').toList();
  }
  
  // Filter by Priority
  List<MaintenanceModel> get urgentMaintenance {
    return _maintenanceList.where((m) => m.prioritas == 'urgent').toList();
  }
  
  List<MaintenanceModel> get highPriorityMaintenance {
    return _maintenanceList.where((m) => m.prioritas == 'tinggi').toList();
  }
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Clear Selected
  void clearSelected() {
    _selectedMaintenance = null;
    notifyListeners();
  }
}
