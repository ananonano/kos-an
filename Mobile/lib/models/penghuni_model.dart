/// Penghuni Model (Tenant)
/// Model untuk data penghuni kos - sesuai dengan tabel tenants di PostgreSQL
class PenghuniModel {
  final String id;
  final String? userId; // Bisa null
  final String? kamarId; // Bisa null
  final String nama;
  final String email;
  final String noTelepon;
  final String? alamatAsal;
  final String? pekerjaan;
  final String? kontakDarurat;
  final DateTime? tanggalMasuk;
  final DateTime? tanggalKeluar;
  final String status; // 'aktif' atau 'tidak_aktif'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? nomorKamar;
  
  PenghuniModel({
    required this.id,
    this.userId,
    this.kamarId,
    required this.nama,
    required this.email,
    required this.noTelepon,
    this.alamatAsal,
    this.pekerjaan,
    this.kontakDarurat,
    this.tanggalMasuk,
    this.tanggalKeluar,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.nomorKamar,
  });
  
  // From JSON
  factory PenghuniModel.fromJson(Map<String, dynamic> json) {
    return PenghuniModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString(),
      kamarId: json['kamar_id']?.toString(),
      nama: json['nama'],
      email: json['email'],
      noTelepon: json['no_telepon'],
      alamatAsal: json['alamat_asal'],
      pekerjaan: json['pekerjaan'],
      kontakDarurat: json['kontak_darurat'],
      tanggalMasuk: json['tanggal_masuk'] != null 
          ? DateTime.parse(json['tanggal_masuk']) 
          : null,
      tanggalKeluar: json['tanggal_keluar'] != null 
          ? DateTime.parse(json['tanggal_keluar']) 
          : null,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      nomorKamar: json['nomor_kamar'], // Dari JOIN dengan rooms
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'kamar_id': kamarId,
      'nama': nama,
      'email': email,
      'no_telepon': noTelepon,
      'alamat_asal': alamatAsal,
      'pekerjaan': pekerjaan,
      'kontak_darurat': kontakDarurat,
      'tanggal_masuk': tanggalMasuk?.toIso8601String().split('T')[0],
      'tanggal_keluar': tanggalKeluar?.toIso8601String().split('T')[0],
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'tidak_aktif':
        return 'Tidak Aktif';
      default:
        return status;
    }
  }
}
