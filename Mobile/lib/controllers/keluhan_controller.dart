import 'package:flutter/material.dart';
import '../models/keluhan_model.dart';
import '../services/keluhan_service.dart';

/// Keluhan Controller
/// Mengelola state dan logic untuk keluhan (realtime)
class KeluhanController extends ChangeNotifier {
  List<KeluhanModel> _keluhanList = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<KeluhanModel> get keluhanList => _keluhanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Stream Keluhan (Realtime)
  Stream<List<KeluhanModel>> streamKeluhan({
    String? penghuniId,
    String? status,
  }) {
    return KeluhanService.streamKeluhan(
      penghuniId: penghuniId,
      status: status,
    );
  }
  
  // Create Keluhan
  Future<bool> createKeluhan({
    required String penghuniId,
    required String kamarId,
    required String judul,
    required String deskripsi,
    List<String>? fotoPaths,
    String? namaPenghuni,
    String? nomorKamar,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Upload photos if any
      List<String>? fotoUrls;
      if (fotoPaths != null && fotoPaths.isNotEmpty) {
        fotoUrls = [];
        for (var path in fotoPaths) {
          final url = await KeluhanService.uploadFotoKeluhan(path);
          fotoUrls.add(url);
        }
      }
      
      await KeluhanService.createKeluhan(
        penghuniId: penghuniId,
        kamarId: kamarId,
        judul: judul,
        deskripsi: deskripsi,
        foto: fotoUrls,
        namaPenghuni: namaPenghuni,
        nomorKamar: nomorKamar,
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
  
  // Update Keluhan Status (Admin)
  Future<bool> updateKeluhanStatus({
    required String id,
    required String status,
    String? komentar,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      await KeluhanService.updateKeluhanStatus(
        id: id,
        status: status,
        komentar: komentar,
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
  
  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
