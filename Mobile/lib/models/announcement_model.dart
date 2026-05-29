/// Announcement Model (Pengumuman)
/// Model untuk data pengumuman - sesuai dengan tabel announcements di PostgreSQL
class AnnouncementModel {
  final String id;
  final String judul;
  final String isi;
  final String prioritas; // 'rendah', 'sedang', 'tinggi'
  final DateTime createdAt;
  final DateTime updatedAt;

  AnnouncementModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.prioritas,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      judul: json['judul'],
      isi: json['isi'],
      prioritas: json['prioritas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'prioritas': prioritas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper untuk prioritas label
  String get prioritasLabel {
    switch (prioritas) {
      case 'tinggi':
        return 'Penting';
      case 'sedang':
        return 'Sedang';
      case 'rendah':
        return 'Biasa';
      default:
        return prioritas;
    }
  }

  // Helper untuk check apakah prioritas tinggi
  bool get isUrgent => prioritas == 'tinggi';
}
