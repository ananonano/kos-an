/// Contract Model (Kontrak)
/// Model untuk data kontrak - sesuai dengan tabel contracts di PostgreSQL
class ContractModel {
  final String id;
  final String tenantId;
  final String kamarId;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final double hargaPerBulan;
  final double deposit;
  final String status; // 'aktif', 'selesai', 'dibatalkan'
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? namaTenant;
  final String? nomorKamar;
  
  ContractModel({
    required this.id,
    required this.tenantId,
    required this.kamarId,
    required this.tanggalMulai,
    this.tanggalSelesai,
    required this.hargaPerBulan,
    required this.deposit,
    required this.status,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.namaTenant,
    this.nomorKamar,
  });
  
  // From JSON
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      kamarId: json['kamar_id'].toString(),
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: json['tanggal_selesai'] != null 
          ? DateTime.parse(json['tanggal_selesai']) 
          : null,
      hargaPerBulan: double.parse(json['harga_per_bulan'].toString()),
      deposit: double.parse(json['deposit']?.toString() ?? '0'),
      status: json['status'],
      catatan: json['catatan'],
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
      'tanggal_mulai': tanggalMulai.toIso8601String().split('T')[0],
      'tanggal_selesai': tanggalSelesai?.toIso8601String().split('T')[0],
      'harga_per_bulan': hargaPerBulan,
      'deposit': deposit,
      'status': status,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
  
  // Helper untuk durasi kontrak (dalam bulan)
  int? get durasiKontrak {
    if (tanggalSelesai == null) return null;
    return tanggalSelesai!.difference(tanggalMulai).inDays ~/ 30;
  }
}
