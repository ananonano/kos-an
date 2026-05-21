/// App Configuration
/// Menyimpan konfigurasi aplikasi seperti base URL API, Firebase config, dll
class AppConfig {
  // API Configuration
  // TODO: Ganti dengan URL backend dari temen lu
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api', // Sesuaikan dengan backend
  );
  
  static String get baseUrl => apiBaseUrl;
  
  // API Endpoints - sesuai backend schema
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String roomsEndpoint = '/rooms'; // Backend pakai 'rooms'
  static const String tenantsEndpoint = '/tenants'; // Backend pakai 'tenants'
  static const String billsEndpoint = '/bills'; // Backend pakai 'bills'
  static const String paymentsEndpoint = '/payments'; // Backend pakai 'payments'
  static const String maintenanceEndpoint = '/maintenance'; // Untuk maintenance reports
  static const String announcementsEndpoint = '/announcements';
  static const String notificationsEndpoint = '/notifications';
  
  // Firebase Collections
  static const String keluhanCollection = 'keluhan';
  static const String chatCollection = 'chats';
  static const String notificationCollection = 'notifications';
  
  // Firebase Storage Paths
  static const String keluhanImagesPath = 'keluhan_images';
  static const String buktiPembayaranPath = 'bukti_pembayaran';
  static const String profileImagesPath = 'profile_images';
  
  // App Settings
  static const int requestTimeout = 30; // seconds
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Pagination
  static const int defaultPageSize = 20;
  
  static Future<void> initialize() async {
    // Initialize any required configurations
    // Load environment variables, check API connectivity, etc.
  }
}
