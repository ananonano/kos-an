import 'package:cloud_firestore/cloud_firestore.dart';

/// Keluhan Model
/// Model untuk data keluhan (disimpan di Firebase Firestore)
class KeluhanModel {
  final String id;
  final String penghuniId;
  final String kamarId;
  final String judul;
  final String deskripsi;
  final List<String>? foto;
  final String status; // 'baru', 'diproses', 'selesai', 'ditolak'
  final String? komentar;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations
  final String? namaPenghuni;
  final String? nomorKamar;
  
  KeluhanModel({
    required this.id,
    required this.penghuniId,
    required this.kamarId,
    required this.judul,
    required this.deskripsi,
    this.foto,
    required this.status,
    this.komentar,
    required this.createdAt,
    required this.updatedAt,
    this.namaPenghuni,
    this.nomorKamar,
  });
  
  // From Firestore
  factory KeluhanModel.fromFirestore(Map<String, dynamic> data) {
    return KeluhanModel(
      id: data['id'],
      penghuniId: data['penghuni_id'],
      kamarId: data['kamar_id'],
      judul: data['judul'],
      deskripsi: data['deskripsi'],
      foto: data['foto'] != null ? List<String>.from(data['foto']) : null,
      status: data['status'],
      komentar: data['komentar'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      namaPenghuni: data['nama_penghuni'],
      nomorKamar: data['nomor_kamar'],
    );
  }
  
  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'penghuni_id': penghuniId,
      'kamar_id': kamarId,
      'judul': judul,
      'deskripsi': deskripsi,
      'foto': foto,
      'status': status,
      'komentar': komentar,
      'nama_penghuni': namaPenghuni,
      'nomor_kamar': nomorKamar,
    };
  }
}
