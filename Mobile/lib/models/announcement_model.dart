/// Announcement Model (Pengumuman)
/// Model untuk data pengumuman - sesuai dengan tabel announcements di PostgreSQL
class AnnouncementModel {
  final String id;
  final String judul;
  final String konten;
  final String prioritas; // 'info', 'penting', 'urgent'
  final String? kategori;
  final String? target; // 'semua', 'tenant', 'admin'
  final bool isRead; // Status sudah dibaca atau belum
  final DateTime createdAt;
  final DateTime updatedAt;

  AnnouncementModel({
    required this.id,
    required this.judul,
    required this.konten,
    required this.prioritas,
    this.kategori,
    this.target,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      judul: json['judul'],
      konten: json['konten'],
      prioritas: json['prioritas'],
      kategori: json['kategori'],
      target: json['target'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'konten': konten,
      'prioritas': prioritas,
      'kategori': kategori,
      'target': target,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk prioritas label
  String get prioritasLabel {
    switch (prioritas) {
      case 'urgent':
        return 'Urgent';
      case 'penting':
        return 'Penting';
      case 'info':
        return 'Info';
      default:
        return prioritas;
    }
  }

  // Helper untuk check apakah prioritas urgent
  bool get isUrgent => prioritas == 'urgent';
  
  // Helper untuk check apakah prioritas penting
  bool get isPenting => prioritas == 'penting';
  
  // Backward compatibility
  String get isi => konten;
}
