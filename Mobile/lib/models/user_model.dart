/// User Model
/// Model untuk data user (admin dan penghuni)
class UserModel {
  final String id;
  final String email;
  final String nama;
  final String role; // 'admin' atau 'penghuni'
  final String? noTelepon;
  final String? foto;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    required this.role,
    this.noTelepon,
    this.foto,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // From JSON (dari API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      // Backend transform 'nama' jadi 'name' untuk compatibility, tapi kita handle both
      nama: json['nama'] ?? json['name'] ?? '',
      role: json['role'],
      // Backend transform 'no_telepon' jadi 'phone' untuk compatibility, tapi kita handle both
      noTelepon: json['no_telepon'] ?? json['phone'],
      foto: json['foto'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // To JSON (untuk API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama, // Backend pakai 'nama'
      'role': role,
      'no_telepon': noTelepon, // Backend pakai 'no_telepon'
      'foto': foto, // Backend pakai 'foto'
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Copy With
  UserModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? role,
    String? noTelepon,
    String? foto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      noTelepon: noTelepon ?? this.noTelepon,
      foto: foto ?? this.foto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
