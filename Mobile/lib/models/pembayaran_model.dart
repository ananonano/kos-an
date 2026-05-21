/// Pembayaran Model (Payment)
/// Model untuk data pembayaran - sesuai backend schema
class PembayaranModel {
  final String id;
  final String billId;
  final double amount;
  final String? proofImage;
  final String status; // 'pending', 'verified', 'rejected'
  final DateTime paymentDate;
  final String? rejectionReason;
  final DateTime createdAt;
  
  // Relations (optional, dari join query)
  final String? tenantName;
  final String? roomNumber;
  final int? month;
  final int? year;
  
  PembayaranModel({
    required this.id,
    required this.billId,
    required this.amount,
    this.proofImage,
    required this.status,
    required this.paymentDate,
    this.rejectionReason,
    required this.createdAt,
    this.tenantName,
    this.roomNumber,
    this.month,
    this.year,
  });
  
  // From JSON
  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      id: json['id'].toString(),
      billId: json['bill_id'].toString(),
      amount: double.parse(json['amount'].toString()),
      proofImage: json['proof_image'],
      status: json['status'],
      paymentDate: DateTime.parse(json['payment_date']),
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      tenantName: json['tenant_name'],
      roomNumber: json['room_number'],
      month: json['month'],
      year: json['year'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_id': billId,
      'amount': amount,
      'proof_image': proofImage,
      'status': status,
      'payment_date': paymentDate.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Helper untuk format periode (jika ada data month/year)
  String? get periode {
    if (month == null || year == null) return null;
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[month! - 1]} $year';
  }
}
