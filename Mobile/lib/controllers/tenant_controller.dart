import 'package:flutter/material.dart';
import '../models/penghuni_model.dart';
import '../services/tenant_service.dart';

/// Tenant Controller
/// Mengelola state dan logic untuk tenant/penghuni
class TenantController extends ChangeNotifier {
  List<PenghuniModel> _tenantList = [];
  PenghuniModel? _selectedTenant;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;

  // Getters
  List<PenghuniModel> get tenantList => _tenantList;
  PenghuniModel? get selectedTenant => _selectedTenant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;

  // Get All Tenants
  Future<void> getAllTenants({String? status}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _tenantList = await TenantService.getAllTenants(status: status);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Get Tenant Detail
  Future<void> getTenantDetail(String tenantId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedTenant = await TenantService.getTenantById(tenantId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Get Tenant by User ID
  Future<void> getTenantByUserId(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedTenant = await TenantService.getTenantByUserId(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Create Tenant
  Future<bool> createTenant({
    required String nama,
    required String email,
    required String noTelepon,
    String? kamarId,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    DateTime? tanggalMasuk,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await TenantService.createTenant(
        nama: nama,
        email: email,
        noTelepon: noTelepon,
        kamarId: kamarId,
        alamatAsal: alamatAsal,
        pekerjaan: pekerjaan,
        kontakDarurat: kontakDarurat,
        tanggalMasuk: tanggalMasuk,
      );

      // Refresh list
      await getAllTenants();

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

  // Update Tenant
  Future<bool> updateTenant({
    required String id,
    String? nama,
    String? email,
    String? noTelepon,
    String? kamarId,
    String? alamatAsal,
    String? pekerjaan,
    String? kontakDarurat,
    DateTime? tanggalMasuk,
    DateTime? tanggalKeluar,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await TenantService.updateTenant(
        id: id,
        nama: nama,
        email: email,
        noTelepon: noTelepon,
        kamarId: kamarId,
        alamatAsal: alamatAsal,
        pekerjaan: pekerjaan,
        kontakDarurat: kontakDarurat,
        tanggalMasuk: tanggalMasuk,
        tanggalKeluar: tanggalKeluar,
        status: status,
      );

      // Refresh list
      await getAllTenants();

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

  // Delete Tenant
  Future<bool> deleteTenant(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await TenantService.deleteTenant(id);

      // Refresh list
      await getAllTenants();

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

  // Assign Room
  Future<bool> assignRoom({
    required String tenantId,
    required String kamarId,
    required DateTime tanggalMasuk,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await TenantService.assignRoom(
        tenantId: tenantId,
        kamarId: kamarId,
        tanggalMasuk: tanggalMasuk,
      );

      // Refresh detail
      await getTenantDetail(tenantId);

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

  // Remove Room
  Future<bool> removeRoom({
    required String tenantId,
    required DateTime tanggalKeluar,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await TenantService.removeRoom(
        tenantId: tenantId,
        tanggalKeluar: tanggalKeluar,
      );

      // Refresh detail
      await getTenantDetail(tenantId);

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

  // Get Statistics
  Future<void> getStatistics() async {
    try {
      _statistics = await TenantService.getTenantStatistics();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Filter tenants
  List<PenghuniModel> get activeTenants {
    return _tenantList.where((tenant) => tenant.status == 'aktif').toList();
  }

  List<PenghuniModel> get inactiveTenants {
    return _tenantList.where((tenant) => tenant.status == 'tidak_aktif').toList();
  }

  List<PenghuniModel> get tenantsWithRoom {
    return _tenantList.where((tenant) => tenant.kamarId != null).toList();
  }

  List<PenghuniModel> get tenantsWithoutRoom {
    return _tenantList.where((tenant) => tenant.kamarId == null).toList();
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear Selected Tenant
  void clearSelectedTenant() {
    _selectedTenant = null;
    notifyListeners();
  }
}
