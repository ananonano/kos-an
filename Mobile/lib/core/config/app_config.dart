/// App Configuration
/// Menyimpan konfigurasi aplikasi seperti base URL API, Firebase config, dll
class AppConfig {
  // API Configuration
  // Backend running di port 5000 (bukan 3000!)
  // Untuk test di emulator: http://10.0.2.2:5000/api
  // Untuk test di device fisik: http://192.168.x.x:5000/api (ganti dengan IP komputer)
  // 
  // PENTING: Pastikan device dan komputer terhubung ke WiFi yang sama!
  // IP komputer kamu: 192.168.31.97 (Updated!)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.31.97:5000/api', // ✅ IP komputer di jaringan WiFi
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
