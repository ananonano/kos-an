/// Kamar Model
/// Model untuk data kamar kos - sesuai dengan tabel rooms di PostgreSQL
class KamarModel {
  final String id;
  final String nomorKamar;
  final String tipe; // Standard, Deluxe, Premium
  final double harga;
  final String status; // 'kosong', 'terisi'
  final String? deskripsi;
  final List<String>? fasilitas;
  final String? foto; // Backend pakai single foto (text), bukan array
  final DateTime createdAt;
  final DateTime updatedAt;
  
  KamarModel({
    required this.id,
    required this.nomorKamar,
    required this.tipe,
    required this.harga,
    required this.status,
    this.deskripsi,
    this.fasilitas,
    this.foto,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // From JSON
  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      id: json['id'].toString(),
      nomorKamar: json['nomor_kamar'], // Backend pakai 'nomor_kamar'
      tipe: json['tipe'], // Standard, Deluxe, Premium
      harga: double.parse(json['harga']?.toString() ?? '0'),
      status: json['status'], // kosong, terisi
      deskripsi: json['deskripsi'],
      fasilitas: json['fasilitas'] != null 
          ? List<String>.from(json['fasilitas']) 
          : null,
      foto: json['foto'], // Single foto URL
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_kamar': nomorKamar,
      'tipe': tipe,
      'harga': harga,
      'status': status,
      'deskripsi': deskripsi,
      'fasilitas': fasilitas,
      'foto': foto,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'kosong':
        return 'Tersedia';
      case 'terisi':
        return 'Terisi';
      default:
        return status;
    }
  }
}
