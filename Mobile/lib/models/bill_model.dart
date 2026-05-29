/// Bill Model (Tagihan)
/// Model untuk data tagihan - sesuai dengan tabel bills di PostgreSQL
class BillModel {
  final String id;
  final String tenantId;
  final String? contractId;
  final String bulan; // Maret, April, dll (string)
  final int tahun;
  final double jumlah;
  final String status; // 'belum_lunas', 'lunas', 'terlambat'
  final DateTime jatuhTempo;
  final double denda;
  final String? catatan;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? namaTenant;
  final String? nomorKamar;
  
  BillModel({
    required this.id,
    required this.tenantId,
    this.contractId,
    required this.bulan,
    required this.tahun,
    required this.jumlah,
    required this.status,
    required this.jatuhTempo,
    required this.denda,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.namaTenant,
    this.nomorKamar,
  });
  
  // From JSON
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      contractId: json['contract_id']?.toString(),
      bulan: json['bulan'],
      tahun: json['tahun'],
      jumlah: double.parse(json['jumlah'].toString()),
      status: json['status'],
      jatuhTempo: DateTime.parse(json['jatuh_tempo']),
      denda: double.parse(json['denda']?.toString() ?? '0'),
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
      'contract_id': contractId,
      'bulan': bulan,
      'tahun': tahun,
      'jumlah': jumlah,
      'status': status,
      'jatuh_tempo': jatuhTempo.toIso8601String().split('T')[0],
      'denda': denda,
      'catatan': catatan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk periode
  String get periode => '$bulan $tahun';
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'belum_lunas':
        return 'Belum Lunas';
      case 'lunas':
        return 'Lunas';
      case 'terlambat':
        return 'Terlambat';
      default:
        return status;
    }
  }
  
  // Helper untuk check apakah sudah jatuh tempo
  bool get isOverdue {
    return DateTime.now().isAfter(jatuhTempo) && status != 'lunas';
  }
  
  // Helper untuk total yang harus dibayar (jumlah + denda)
  double get totalBayar => jumlah + denda;
}
