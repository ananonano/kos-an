import '../core/services/http_service.dart';
import '../core/services/storage_service.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Authentication Service
/// Mengelola operasi autentikasi (login, logout)
class AuthService {
  // Login
  static Future<UserModel> login(String email, String password) async {
    try {
      final response = await HttpService.post(
        '${AppConfig.authEndpoint}/login',
        body: {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );
      
      // Backend response format: { "success": true, "message": "...", "token": "...", "user": {...} }
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Login gagal');
      }
      
      // Save token
      await StorageService.saveString(
        AppConstants.tokenKey,
        response['token'],
      );
      
      // Save user data
      // Backend return user dengan field 'name' dan 'phone' (transformed), tapi kita tetap simpan sebagai 'nama' dan 'no_telepon'
      final userData = response['user'];
      final user = UserModel.fromJson(userData);
      await StorageService.saveObject(AppConstants.userKey, user.toJson());
      await StorageService.saveString(AppConstants.roleKey, user.role);
      
      return user;
    } catch (e) {
      throw Exception('Login gagal: ${e.toString()}');
    }
  }
  
  // Logout
  static Future<void> logout() async {
    try {
      await HttpService.post('${AppConfig.authEndpoint}/logout');
      
      // Clear local storage
      await StorageService.remove(AppConstants.tokenKey);
      await StorageService.remove(AppConstants.userKey);
      await StorageService.remove(AppConstants.roleKey);
    } catch (e) {
      // Even if API call fails, clear local storage
      await StorageService.remove(AppConstants.tokenKey);
      await StorageService.remove(AppConstants.userKey);
      await StorageService.remove(AppConstants.roleKey);
    }
  }
  
  // Get Current User
  static UserModel? getCurrentUser() {
    final userData = StorageService.getObject(AppConstants.userKey);
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }
  
  // Check if Logged In
  static bool isLoggedIn() {
    return StorageService.getString(AppConstants.tokenKey) != null;
  }
  
  // Get User Role
  static String? getUserRole() {
    return StorageService.getString(AppConstants.roleKey);
  }
  
  // Check if Admin
  static bool isAdmin() {
    return getUserRole() == AppConstants.roleAdmin;
  }
  
  // Update Profile
  static Future<UserModel> updateProfile({
    required String userId,
    String? nama,
    String? noTelepon,
    String? foto,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nama != null) body['nama'] = nama;
      if (noTelepon != null) body['no_telepon'] = noTelepon;
      if (foto != null) body['foto'] = foto;
      
      print('🔄 [AuthService] Updating profile...');
      print('📝 [AuthService] User ID: $userId');
      print('📝 [AuthService] Body: $body');
      
      final response = await HttpService.put(
        '${AppConfig.authEndpoint}/profile', // Backend endpoint: PUT /api/auth/profile
        body: body,
      );
      
      print('📦 [AuthService] Response: $response');
      
      // Backend response format: { "success": true, "message": "...", "data": {...} }
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Update profile gagal');
      }
      
      print('✅ [AuthService] Update successful, saving to storage...');
      
      final user = UserModel.fromJson(response['data']);
      await StorageService.saveObject(AppConstants.userKey, user.toJson());
      
      print('✅ [AuthService] User saved to storage');
      print('📦 [AuthService] Saved user: ${user.nama}, ${user.noTelepon}');
      
      return user;
    } catch (e) {
      print('❌ [AuthService] Update profile error: $e');
      throw Exception('Update profile gagal: ${e.toString()}');
    }
  }
  
  // Get Admin User (for chat with admin)
  static Future<Map<String, dynamic>> getAdminUser() async {
    try {
      final response = await HttpService.get(
        '${AppConfig.usersEndpoint}?role=admin&limit=1',
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Gagal mengambil data admin');
      }
      
      final List<dynamic> data = response['data'] ?? [];
      if (data.isEmpty) {
        throw Exception('Admin tidak ditemukan');
      }
      
      return data.first as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal mengambil data admin: ${e.toString()}');
    }
  }
}
