/// Bill Model (Tagihan)
/// Model untuk data tagihan bulanan - sesuai backend schema
class BillModel {
  final String id;
  final String tenantId;
  final int month; // 1-12
  final int year;
  final double amount;
  final DateTime dueDate;
  final String status; // 'pending', 'paid', 'overdue'
  final DateTime createdAt;
  
  // Relations (optional, dari join query)
  final String? tenantName;
  final String? roomNumber;
  
  BillModel({
    required this.id,
    required this.tenantId,
    required this.month,
    required this.year,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.tenantName,
    this.roomNumber,
  });
  
  // From JSON
  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      month: json['month'] is int ? json['month'] : int.parse(json['month'].toString()),
      year: json['year'] is int ? json['year'] : int.parse(json['year'].toString()),
      amount: double.parse(json['amount'].toString()),
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      tenantName: json['tenant_name'],
      roomNumber: json['room_number'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'month': month,
      'year': year,
      'amount': amount,
      'due_date': dueDate.toIso8601String().split('T')[0], // Date only
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Helper untuk format bulan
  String get monthName {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
  
  // Helper untuk format periode
  String get periode => '$monthName $year';
  
  // Helper untuk check overdue
  bool get isOverdue => status == 'pending' && DateTime.now().isAfter(dueDate);
}
