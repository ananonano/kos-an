/// App Constants
/// Menyimpan konstanta yang digunakan di seluruh aplikasi
class AppConstants {
  // User Roles
  static const String roleAdmin = 'admin';
  static const String rolePenghuni = 'penghuni';
  
  // Kamar Status
  static const String kamarKosong = 'kosong';
  static const String kamarTerisi = 'terisi';
  
  // Pembayaran Status
  static const String pembayaranBelumLunas = 'belum_lunas';
  static const String pembayaranMenungguVerifikasi = 'menunggu_verifikasi';
  static const String pembayaranLunas = 'lunas';
  static const String pembayaranDitolak = 'ditolak';
  
  // Keluhan Status
  static const String keluhanBaru = 'baru';
  static const String keluhanDiproses = 'diproses';
  static const String keluhanSelesai = 'selesai';
  static const String keluhanDitolak = 'ditolak';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxImageSizeMB = 5;
}
