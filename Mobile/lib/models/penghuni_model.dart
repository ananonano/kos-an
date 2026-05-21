/// Penghuni Model (Tenant)
/// Model untuk data penghuni kos - sesuai backend schema
class PenghuniModel {
  final String id;
  final String userId;
  final String kamarId;
  final DateTime tanggalMasuk; // start_date
  final DateTime? tanggalKeluar; // end_date
  final String status; // 'active' atau 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? nomorKamar;
  final String? namaUser;
  final String? emailUser;
  
  PenghuniModel({
    required this.id,
    required this.userId,
    required this.kamarId,
    required this.tanggalMasuk,
    this.tanggalKeluar,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.nomorKamar,
    this.namaUser,
    this.emailUser,
  });
  
  // From JSON
  factory PenghuniModel.fromJson(Map<String, dynamic> json) {
    return PenghuniModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      kamarId: json['room_id']?.toString() ?? json['kamar_id']?.toString() ?? '',
      tanggalMasuk: DateTime.parse(json['start_date'] ?? json['tanggal_masuk']),
      tanggalKeluar: json['end_date'] != null || json['tanggal_keluar'] != null
          ? DateTime.parse(json['end_date'] ?? json['tanggal_keluar']) 
          : null,
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      nomorKamar: json['room_number'] ?? json['nomor_kamar'],
      namaUser: json['user_name'] ?? json['nama'],
      emailUser: json['user_email'] ?? json['email'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'room_id': kamarId,
      'start_date': tanggalMasuk.toIso8601String().split('T')[0], // Date only
      'end_date': tanggalKeluar?.toIso8601String().split('T')[0],
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
