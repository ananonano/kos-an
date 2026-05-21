import '../core/services/firebase_service.dart';
import '../core/config/app_config.dart';
import '../models/keluhan_model.dart';

/// Keluhan Service
/// Mengelola operasi keluhan melalui Firebase Firestore (realtime)
class KeluhanService {
  // Create Keluhan
  static Future<String> createKeluhan({
    required String penghuniId,
    required String kamarId,
    required String judul,
    required String deskripsi,
    List<String>? foto,
    String? namaPenghuni,
    String? nomorKamar,
  }) async {
    try {
      final data = {
        'penghuni_id': penghuniId,
        'kamar_id': kamarId,
        'judul': judul,
        'deskripsi': deskripsi,
        'foto': foto ?? [],
        'status': 'baru',
        'komentar': null,
        'nama_penghuni': namaPenghuni,
        'nomor_kamar': nomorKamar,
      };
      
      final docId = await FirebaseService.addDocument(
        AppConfig.keluhanCollection,
        data,
      );
      
      return docId;
    } catch (e) {
      throw Exception('Gagal membuat keluhan: ${e.toString()}');
    }
  }
  
  // Update Keluhan Status (Admin)
  static Future<void> updateKeluhanStatus({
    required String id,
    required String status,
    String? komentar,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
      };
      
      if (komentar != null) {
        data['komentar'] = komentar;
      }
      
      await FirebaseService.updateDocument(
        AppConfig.keluhanCollection,
        id,
        data,
      );
    } catch (e) {
      throw Exception('Gagal mengupdate status keluhan: ${e.toString()}');
    }
  }
  
  // Get Keluhan (Realtime Stream)
  static Stream<List<KeluhanModel>> streamKeluhan({
    String? penghuniId,
    String? status,
  }) {
    try {
      final where = <String, dynamic>{};
      if (penghuniId != null) where['penghuni_id'] = penghuniId;
      if (status != null) where['status'] = status;
      
      return FirebaseService.streamDocuments(
        AppConfig.keluhanCollection,
        orderBy: 'createdAt',
        descending: true,
        where: where.isNotEmpty ? where : null,
      ).map((docs) {
        return docs.map((doc) => KeluhanModel.fromFirestore(doc)).toList();
      });
    } catch (e) {
      throw Exception('Gagal streaming keluhan: ${e.toString()}');
    }
  }
  
  // Get Keluhan by ID
  static Future<KeluhanModel?> getKeluhanById(String id) async {
    try {
      final doc = await FirebaseService.getDocument(
        AppConfig.keluhanCollection,
        id,
      );
      
      if (doc != null) {
        return KeluhanModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil detail keluhan: ${e.toString()}');
    }
  }
  
  // Upload Foto Keluhan
  static Future<String> uploadFotoKeluhan(String filePath) async {
    try {
      final url = await FirebaseService.uploadFile(
        filePath,
        AppConfig.keluhanImagesPath,
      );
      return url;
    } catch (e) {
      throw Exception('Gagal upload foto: ${e.toString()}');
    }
  }
}
