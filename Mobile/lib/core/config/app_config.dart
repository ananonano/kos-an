/// App Configuration
/// Menyimpan konfigurasi aplikasi seperti base URL API, Firebase config, dll
class AppConfig {
  // API Configuration
  // PRODUCTION: Cloud Run backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kosan-backend-670153358279.asia-southeast2.run.app/api', // ✅ Production Cloud Run
  );
  
  static String get baseUrl => apiBaseUrl;
  
  // API Endpoints - sesuai dengan backend Express.js + PostgreSQL
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String roomsEndpoint = '/rooms'; // Tabel: rooms
  static const String tenantsEndpoint = '/tenants'; // Tabel: tenants
  static const String contractsEndpoint = '/contracts'; // Tabel: contracts
  static const String billsEndpoint = '/bills'; // Tabel: bills
  static const String paymentsEndpoint = '/payments'; // Tabel: payments
  static const String maintenanceEndpoint = '/maintenance'; // Tabel: maintenance
  static const String announcementsEndpoint = '/announcements'; // Tabel: announcements
  static const String notificationsEndpoint = '/notifications'; // Tabel: notifications (jika ada)
  static const String uploadEndpoint = '/upload'; // Untuk upload file (bukti bayar, foto keluhan, dll)
  
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
