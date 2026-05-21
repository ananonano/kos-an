/// Kamar Model
/// Model untuk data kamar kos
class KamarModel {
  final String id;
  final String nomorKamar;
  final double harga;
  final String status; // 'available', 'occupied', 'maintenance'
  final String? deskripsi;
  final List<String>? fasilitas;
  final List<String>? images; // Backend pakai array images
  final DateTime createdAt;
  final DateTime updatedAt;
  
  KamarModel({
    required this.id,
    required this.nomorKamar,
    required this.harga,
    required this.status,
    this.deskripsi,
    this.fasilitas,
    this.images,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // From JSON
  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      id: json['id'].toString(),
      nomorKamar: json['room_number'] ?? json['nomor_kamar'], // Backend pakai 'room_number'
      harga: double.parse(json['price']?.toString() ?? json['harga']?.toString() ?? '0'),
      status: json['status'],
      deskripsi: json['description'] ?? json['deskripsi'],
      fasilitas: json['facilities'] != null 
          ? List<String>.from(json['facilities']) 
          : (json['fasilitas'] != null ? List<String>.from(json['fasilitas']) : null),
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': nomorKamar,
      'price': harga,
      'status': status,
      'description': deskripsi,
      'facilities': fasilitas,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Helper untuk get first image
  String? get firstImage => images != null && images!.isNotEmpty ? images!.first : null;
}
