/// Maintenance Model (Keluhan)
class MaintenanceModel {
  final String id;
  final int tenantId;
  final int kamarId;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String prioritas; // rendah, sedang, tinggi, urgent
  final String status; // baru, diproses, selesai, ditolak
  final List<String>? foto;
  final String? komentarAdmin;
  final double? biaya;
  final DateTime tanggalLapor;
  final DateTime? tanggalSelesai;
  
  // Joined fields
  final String? namaTenant;
  final String? tenantEmail;
  final String? tenantPhone;
  final String? nomorKamar;
  final String? tipeKamar;

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
    this.komentarAdmin,
    this.biaya,
    required this.tanggalLapor,
    this.tanggalSelesai,
    this.namaTenant,
    this.tenantEmail,
    this.tenantPhone,
    this.nomorKamar,
    this.tipeKamar,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'] ?? 0,
      kamarId: json['kamar_id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? '',
      prioritas: json['prioritas'] ?? 'sedang',
      status: json['status'] ?? 'baru',
      foto: json['foto'] != null
          ? (json['foto'] is List
              ? List<String>.from(json['foto'])
              : [json['foto'].toString()])
          : null,
      komentarAdmin: json['komentar_admin'],
      biaya: json['biaya'] != null ? double.parse(json['biaya'].toString()) : null,
      tanggalLapor: json['tanggal_lapor'] != null
          ? DateTime.parse(json['tanggal_lapor'])
          : DateTime.now(),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      namaTenant: json['nama_tenant'],
      tenantEmail: json['tenant_email'],
      tenantPhone: json['tenant_phone'],
      nomorKamar: json['nomor_kamar'],
      tipeKamar: json['tipe_kamar'],
    );
  }

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
      'komentar_admin': komentarAdmin,
      'biaya': biaya,
      'tanggal_lapor': tanggalLapor.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
    };
  }

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
