/// Payment Model (Pembayaran)
/// Model untuk data pembayaran - sesuai dengan tabel payments di PostgreSQL
class PaymentModel {
  final String id;
  final String tagihanId;
  final String tenantId;
  final double jumlah;
  final DateTime tanggalBayar;
  final String metodePembayaran; // 'transfer', 'tunai', 'e-wallet'
  final String? buktiPembayaran; // URL foto bukti
  final String status; // 'menunggu_verifikasi', 'lunas', 'ditolak'
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations (optional, dari join query)
  final String? namaTenant;
  final String? nomorKamar;
  final String? bulanTagihan;
  final int? tahunTagihan;

  PaymentModel({
    required this.id,
    required this.tagihanId,
    required this.tenantId,
    required this.jumlah,
    required this.tanggalBayar,
    required this.metodePembayaran,
    this.buktiPembayaran,
    required this.status,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
    this.namaTenant,
    this.nomorKamar,
    this.bulanTagihan,
    this.tahunTagihan,
  });

  // From JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'].toString(),
      tagihanId: json['tagihan_id'].toString(),
      tenantId: json['tenant_id'].toString(),
      jumlah: double.parse(json['jumlah'].toString()),
      tanggalBayar: DateTime.parse(json['tanggal_bayar']),
      metodePembayaran: json['metode_pembayaran'],
      buktiPembayaran: json['bukti_pembayaran'],
      status: json['status'],
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      namaTenant: json['nama_tenant'],
      nomorKamar: json['nomor_kamar'],
      bulanTagihan: json['bulan_tagihan'],
      tahunTagihan: json['tahun_tagihan'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagihan_id': tagihanId,
      'tenant_id': tenantId,
      'jumlah': jumlah,
      'tanggal_bayar': tanggalBayar.toIso8601String().split('T')[0],
      'metode_pembayaran': metodePembayaran,
      'bukti_pembayaran': buktiPembayaran,
      'status': status,
      'keterangan': keterangan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'lunas':
        return 'Lunas';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Helper untuk metode pembayaran label
  String get metodePembayaranLabel {
    switch (metodePembayaran) {
      case 'transfer':
        return 'Transfer Bank';
      case 'tunai':
        return 'Tunai';
      case 'e-wallet':
        return 'E-Wallet';
      default:
        return metodePembayaran;
    }
  }

  // Helper untuk periode tagihan
  String get periodeTagihan {
    if (bulanTagihan != null && tahunTagihan != null) {
      return '$bulanTagihan $tahunTagihan';
    }
    return '-';
  }

  // Helper untuk check apakah pending
  bool get isPending => status == 'menunggu_verifikasi';

  // Helper untuk check apakah sudah lunas
  bool get isLunas => status == 'lunas';

  // Helper untuk check apakah ditolak
  bool get isDitolak => status == 'ditolak';
}
