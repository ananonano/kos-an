/// Maintenance Model (Keluhan/Perbaikan)
/// Model untuk data maintenance - sesuai dengan tabel maintenance di PostgreSQL
class MaintenanceModel {
  final String id;
  final String tenantId;
  final String kamarId;
  final String judul;
  final String deskripsi;
  final String kategori; // AC, Listrik, Air, dll
  final String prioritas; // 'rendah', 'sedang', 'tinggi', 'urgent'
  final String status; // 'baru', 'diproses', 'selesai', 'ditolak'
  final List<String>? foto; // Array foto dari JSONB
  final DateTime tanggalLapor;
  final DateTime? tanggalSelesai;
  final String? komentarAdmin;
  final double? biaya;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? namaTenant;
  final String? nomorKamar;
  
  MaintenanceModel({
    required this.id,
    required this.tenantId,
    required this.kamarId,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.prioritas,
    required this.status,
    this.foto,
    required this.tanggalLapor,
    this.tanggalSelesai,
    this.komentarAdmin,
    this.biaya,
    required this.createdAt,
    required this.updatedAt,
    this.namaTenant,
    this.nomorKamar,
  });
  
  // From JSON
  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      kamarId: json['kamar_id'].toString(),
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      prioritas: json['prioritas'],
      status: json['status'],
      foto: json['foto'] != null ? List<String>.from(json['foto']) : null,
      tanggalLapor: DateTime.parse(json['tanggal_lapor']),
      tanggalSelesai: json['tanggal_selesai'] != null 
          ? DateTime.parse(json['tanggal_selesai']) 
          : null,
      komentarAdmin: json['komentar_admin'],
      biaya: json['biaya'] != null ? double.parse(json['biaya'].toString()) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      namaTenant: json['nama_tenant'],
      nomorKamar: json['nomor_kamar'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'kamar_id': kamarId,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'prioritas': prioritas,
      'status': status,
      'foto': foto,
      'tanggal_lapor': tanggalLapor.toIso8601String().split('T')[0],
      'tanggal_selesai': tanggalSelesai?.toIso8601String().split('T')[0],
      'komentar_admin': komentarAdmin,
      'biaya': biaya,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'baru':
        return 'Baru';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
  
  // Helper untuk prioritas label
  String get prioritasLabel {
    switch (prioritas) {
      case 'rendah':
        return 'Rendah';
      case 'sedang':
        return 'Sedang';
      case 'tinggi':
        return 'Tinggi';
      case 'urgent':
        return 'Urgent';
      default:
        return prioritas;
    }
  }
}
