/// Maintenance Report Model (Keluhan/Laporan Kerusakan)
/// Model untuk data laporan kerusakan - sesuai backend schema
class MaintenanceModel {
  final String id;
  final String tenantId;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relations (optional, dari join query)
  final String? tenantName;
  final String? roomNumber;
  final List<MaintenanceProgress>? progressList;
  
  MaintenanceModel({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.tenantName,
    this.roomNumber,
    this.progressList,
  });
  
  // From JSON
  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'].toString(),
      tenantId: json['tenant_id'].toString(),
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tenantName: json['tenant_name'],
      roomNumber: json['room_number'],
      progressList: json['progress'] != null
          ? (json['progress'] as List)
              .map((p) => MaintenanceProgress.fromJson(p))
              .toList()
          : null,
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk status label
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Sedang Dikerjakan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}

/// Maintenance Progress Model
/// Model untuk progress/update dari maintenance report
class MaintenanceProgress {
  final String id;
  final String reportId;
  final String description;
  final String? image;
  final DateTime createdAt;
  
  MaintenanceProgress({
    required this.id,
    required this.reportId,
    required this.description,
    this.image,
    required this.createdAt,
  });
  
  // From JSON
  factory MaintenanceProgress.fromJson(Map<String, dynamic> json) {
    return MaintenanceProgress(
      id: json['id'].toString(),
      reportId: json['report_id'].toString(),
      description: json['description'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'description': description,
      'image': image,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
