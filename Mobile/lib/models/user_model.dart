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
      nama: json['name'] ?? json['nama'], // Backend pakai 'name'
      role: json['role'],
      noTelepon: json['phone'] ?? json['no_telepon'], // Backend pakai 'phone'
      foto: json['avatar'] ?? json['foto'], // Backend pakai 'avatar'
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // To JSON (untuk API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': nama, // Backend pakai 'name'
      'role': role,
      'phone': noTelepon, // Backend pakai 'phone'
      'avatar': foto, // Backend pakai 'avatar'
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
