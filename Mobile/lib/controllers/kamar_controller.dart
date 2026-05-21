import 'package:flutter/material.dart';
import '../models/kamar_model.dart';
import '../services/kamar_service.dart';

/// Kamar Controller
/// Mengelola state dan logic untuk data kamar
class KamarController extends ChangeNotifier {
  List<KamarModel> _kamarList = [];
  KamarModel? _selectedKamar;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<KamarModel> get kamarList => _kamarList;
  KamarModel? get selectedKamar => _selectedKamar;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get All Kamar
  Future<void> getAllKamar({String? status}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _kamarList = await KamarService.getAllKamar(status: status);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Get Kamar by ID
  Future<void> getKamarById(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _selectedKamar = await KamarService.getKamarById(id);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // Create Kamar
  Future<bool> createKamar({
    required String nomorKamar,
    required String tipe,
    required double harga,
    String? deskripsi,
    List<String>? fasilitas,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await KamarService.createKamar(
        nomorKamar: nomorKamar,
        tipe: tipe,
        harga: harga,
        deskripsi: deskripsi,
        fasilitas: fasilitas,
      );
      
      // Refresh list
      await getAllKamar();
      
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
  
  // Update Kamar
  Future<bool> updateKamar({
    required String id,
    String? nomorKamar,
    String? tipe,
    double? harga,
    String? status,
    String? deskripsi,
    List<String>? fasilitas,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await KamarService.updateKamar(
        id: id,
        nomorKamar: nomorKamar,
        tipe: tipe,
        harga: harga,
        status: status,
        deskripsi: deskripsi,
        fasilitas: fasilitas,
      );
      
      // Refresh list
      await getAllKamar();
      
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
  
  // Delete Kamar
  Future<bool> deleteKamar(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await KamarService.deleteKamar(id);
      
      // Refresh list
      await getAllKamar();
      
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
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
