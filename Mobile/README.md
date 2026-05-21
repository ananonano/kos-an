# Kos Terpadu - Aplikasi Manajemen Kos Modern

Aplikasi mobile Flutter untuk manajemen kos terpadu yang menghubungkan pemilik kos (admin) dengan penghuni kos.

## 📱 Fitur Utama

### Untuk Penghuni:
- ✅ Login & Register
- ✅ Lihat daftar kamar dan detail kamar
- ✅ Buat keluhan dengan upload foto (realtime)
- ✅ Chat realtime dengan admin
- ✅ Riwayat pembayaran
- ✅ Upload bukti pembayaran

### Untuk Admin/Pemilik Kos:
- ✅ Login & Dashboard
- ✅ Manajemen kamar (CRUD)
- ✅ Manajemen penghuni
- ✅ Kelola keluhan penghuni (realtime)
- ✅ Chat realtime dengan penghuni
- ✅ Verifikasi pembayaran
- ✅ Laporan keuangan

## 🏗️ Arsitektur

Aplikasi ini menggunakan **MVC + Service Layer Pattern** untuk memisahkan concerns dan meningkatkan maintainability:

```
lib/
├── core/                    # Core utilities & configurations
│   ├── config/             # App configuration (API URLs, Firebase config)
│   ├── constants/          # App constants (roles, status, keys)
│   ├── services/           # Core services (HTTP, Firebase, Storage)
│   ├── theme/              # App theme & styling
│   └── utils/              # Helper functions & validators
│
├── models/                  # Data models
│   ├── user_model.dart
│   ├── kamar_model.dart
│   ├── penghuni_model.dart
│   ├── pembayaran_model.dart
│   ├── keluhan_model.dart
│   └── chat_model.dart
│
├── services/                # Service layer (API calls)
│   ├── auth_service.dart
│   ├── kamar_service.dart
│   ├── penghuni_service.dart
│   ├── pembayaran_service.dart
│   ├── keluhan_service.dart
│   └── chat_service.dart
│
├── controllers/             # State management (Provider)
│   ├── auth_controller.dart
│   ├── kamar_controller.dart
│   ├── penghuni_controller.dart
│   ├── pembayaran_controller.dart
│   ├── keluhan_controller.dart
│   └── chat_controller.dart
│
├── views/                   # UI screens
│   ├── splash/
│   ├── auth/               # Login, Register
│   ├── home/               # Dashboard
│   ├── kamar/              # Kamar list & detail
│   ├── penghuni/           # Penghuni management
│   ├── pembayaran/         # Payment management
│   ├── keluhan/            # Complaint management
│   └── chat/               # Realtime chat
│
├── widgets/                 # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── kamar_card.dart
│   └── menu_card.dart
│
├── routes/                  # App routing
│   └── app_routes.dart
│
└── main.dart               # Entry point
```

## 🔄 Alur Data

### PostgreSQL (via REST API)
```
Flutter App → HTTP Service → Express.js API → PostgreSQL
```

**Data yang disimpan di PostgreSQL:**
- Users (admin & penghuni)
- Kamar
- Penghuni
- Pembayaran
- Tagihan

### Firebase (Realtime & Storage)
```
Flutter App → Firebase Service → Cloud Firestore/Storage
```

**Data yang disimpan di Firebase:**
- Keluhan (Firestore - realtime)
- Chat Messages (Firestore - realtime)
- Chat Rooms (Firestore - realtime)
- Notifikasi (Firestore - realtime)
- Foto keluhan (Storage)
- Bukti pembayaran (Storage)

## 🗄️ Database Schema (ERD Sederhana)

### PostgreSQL Tables:

```sql
-- Users Table
users (
  id SERIAL PRIMARY KEY,
  email VARCHAR UNIQUE,
  password VARCHAR,
  nama VARCHAR,
  role VARCHAR, -- 'admin' atau 'penghuni'
  no_telepon VARCHAR,
  foto VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Kamar Table
kamar (
  id SERIAL PRIMARY KEY,
  nomor_kamar VARCHAR UNIQUE,
  tipe VARCHAR,
  harga DECIMAL,
  status VARCHAR, -- 'kosong' atau 'terisi'
  deskripsi TEXT,
  fasilitas JSON,
  foto VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Penghuni Table
penghuni (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  kamar_id INTEGER REFERENCES kamar(id),
  nama VARCHAR,
  email VARCHAR,
  no_telepon VARCHAR,
  alamat_asal TEXT,
  pekerjaan VARCHAR,
  kontak_darurat VARCHAR,
  tanggal_masuk DATE,
  tanggal_keluar DATE,
  status VARCHAR, -- 'aktif' atau 'tidak_aktif'
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Tagihan Table
tagihan (
  id SERIAL PRIMARY KEY,
  penghuni_id INTEGER REFERENCES penghuni(id),
  bulan VARCHAR,
  tahun INTEGER,
  jumlah DECIMAL,
  status VARCHAR, -- 'belum_lunas', 'lunas'
  jatuh_tempo DATE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Pembayaran Table
pembayaran (
  id SERIAL PRIMARY KEY,
  tagihan_id INTEGER REFERENCES tagihan(id),
  penghuni_id INTEGER REFERENCES penghuni(id),
  jumlah DECIMAL,
  tanggal_bayar DATE,
  metode_pembayaran VARCHAR,
  bukti_pembayaran VARCHAR,
  status VARCHAR, -- 'menunggu_verifikasi', 'lunas', 'ditolak'
  keterangan TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### Firebase Firestore Collections:

```javascript
// keluhan collection
keluhan: {
  id: string,
  penghuni_id: string,
  kamar_id: string,
  judul: string,
  deskripsi: string,
  foto: string[], // URLs from Firebase Storage
  status: string, // 'baru', 'diproses', 'selesai', 'ditolak'
  komentar: string,
  nama_penghuni: string,
  nomor_kamar: string,
  createdAt: timestamp,
  updatedAt: timestamp
}

// chats collection
chats: {
  id: string,
  penghuni_id: string,
  admin_id: string,
  last_message: string,
  last_message_time: timestamp,
  unread_count: number,
  penghuni_name: string,
  admin_name: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  
  // Subcollection: messages
  messages: {
    id: string,
    chat_room_id: string,
    sender_id: string,
    message: string,
    image_url: string,
    sender_name: string,
    sender_role: string,
    createdAt: timestamp
  }
}

// notifications collection
notifications: {
  id: string,
  user_id: string,
  title: string,
  body: string,
  type: string, // 'pembayaran', 'keluhan', 'chat'
  data: object,
  is_read: boolean,
  createdAt: timestamp
}
```

## 🚀 Setup & Installation

### Prerequisites:
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Firebase Account
- PostgreSQL Database
- Express.js Backend API

### 1. Clone Repository
```bash
git clone <repository-url>
cd kos_terpadu
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
3. Letakkan file di folder yang sesuai:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Enable Firebase Authentication, Firestore, dan Storage

### 4. Configure API Base URL
Edit file `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'https://your-api-url.com/api';
```

Atau gunakan environment variable:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-url.com/api
```

### 5. Run Application
```bash
flutter run
```

## 🔧 Backend API Requirements

Backend Express.js harus menyediakan endpoints berikut:

### Authentication
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/register` - Register user baru
- `POST /api/v1/auth/logout` - Logout user
- `PUT /api/v1/auth/profile/:id` - Update profile

### Kamar
- `GET /api/v1/kamar` - Get all kamar (with query params: status, page, limit)
- `GET /api/v1/kamar/:id` - Get kamar by ID
- `POST /api/v1/kamar` - Create kamar (admin only)
- `PUT /api/v1/kamar/:id` - Update kamar (admin only)
- `DELETE /api/v1/kamar/:id` - Delete kamar (admin only)

### Penghuni
- `GET /api/v1/penghuni` - Get all penghuni
- `GET /api/v1/penghuni/:id` - Get penghuni by ID
- `POST /api/v1/penghuni` - Create penghuni
- `PUT /api/v1/penghuni/:id` - Update penghuni
- `DELETE /api/v1/penghuni/:id` - Delete penghuni

### Pembayaran
- `GET /api/v1/pembayaran` - Get all pembayaran
- `GET /api/v1/pembayaran/:id` - Get pembayaran by ID
- `POST /api/v1/pembayaran` - Create pembayaran
- `PUT /api/v1/pembayaran/:id` - Update pembayaran status
- `POST /api/v1/pembayaran/:id/upload` - Upload bukti pembayaran

### Tagihan
- `GET /api/v1/tagihan` - Get all tagihan
- `GET /api/v1/tagihan/:id` - Get tagihan by ID
- `POST /api/v1/tagihan` - Create tagihan
- `PUT /api/v1/tagihan/:id` - Update tagihan

**Response Format:**
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

**Error Format:**
```json
{
  "success": false,
  "message": "Error message"
}
```

## 📦 State Management

Aplikasi ini menggunakan **Provider** untuk state management:

### Keuntungan Provider:
- ✅ Official dari Flutter team
- ✅ Simple dan mudah dipahami
- ✅ Performance yang baik
- ✅ Cocok untuk aplikasi medium-large
- ✅ Terintegrasi baik dengan Flutter

### Struktur Controller:
```dart
class KamarController extends ChangeNotifier {
  List<KamarModel> _kamarList = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<KamarModel> get kamarList => _kamarList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Methods
  Future<void> getAllKamar() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _kamarList = await KamarService.getAllKamar();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
```

## 🎨 UI/UX Design

### Design System:
- **Primary Color:** Blue (#2196F3)
- **Secondary Color:** Light Blue (#03A9F4)
- **Accent Color:** Orange (#FF9800)
- **Success Color:** Green (#4CAF50)
- **Error Color:** Red (#F44336)
- **Warning Color:** Yellow (#FFC107)

### Typography:
- **Heading 1:** 32px, Bold
- **Heading 2:** 24px, Bold
- **Heading 3:** 20px, Semi-Bold
- **Body Text 1:** 16px, Regular
- **Body Text 2:** 14px, Regular
- **Caption:** 12px, Regular

### Components:
- Custom Button dengan loading state
- Custom Text Field dengan validation
- Reusable Cards
- Status Badges
- Loading Indicators

## 🔐 Security Best Practices

1. **Authentication:**
   - JWT Token disimpan di SharedPreferences
   - Token dikirim di header setiap request
   - Auto logout jika token expired

2. **Input Validation:**
   - Client-side validation menggunakan Validators
   - Server-side validation di backend

3. **Error Handling:**
   - Try-catch di semua async operations
   - User-friendly error messages
   - Logging untuk debugging

4. **Data Privacy:**
   - Password tidak pernah disimpan di local storage
   - Sensitive data di-encrypt di backend

## 📱 Contoh Penggunaan

### 1. Login
```dart
final authController = context.read<AuthController>();
final success = await authController.login(email, password);

if (success) {
  Navigator.pushReplacementNamed(context, AppRoutes.home);
} else {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authController.errorMessage ?? 'Login gagal')),
  );
}
```

### 2. Get Data Kamar
```dart
final kamarController = context.read<KamarController>();
await kamarController.getAllKamar(status: 'kosong');

// Access data
final kamarList = kamarController.kamarList;
```

### 3. Create Keluhan (Realtime)
```dart
final keluhanController = context.read<KeluhanController>();
final success = await keluhanController.createKeluhan(
  penghuniId: user.id,
  kamarId: kamarId,
  judul: 'AC Rusak',
  deskripsi: 'AC di kamar tidak dingin',
  fotoPaths: ['/path/to/image.jpg'],
);
```

### 4. Realtime Chat
```dart
// Stream messages
StreamBuilder<List<ChatMessageModel>>(
  stream: chatController.streamMessages(chatRoomId),
  builder: (context, snapshot) {
    final messages = snapshot.data ?? [];
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(message: messages[index]);
      },
    );
  },
)

// Send message
await chatController.sendMessage(
  chatRoomId: chatRoomId,
  senderId: user.id,
  message: 'Hello!',
);
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

## 📝 TODO / Future Improvements

- [ ] Implement image picker untuk upload foto
- [ ] Add push notifications
- [ ] Add offline mode dengan local database
- [ ] Add data caching
- [ ] Add unit tests & integration tests
- [ ] Add dark mode
- [ ] Add multi-language support
- [ ] Add analytics
- [ ] Add crash reporting
- [ ] Optimize performance
- [ ] Add pagination untuk list yang panjang
- [ ] Add search & filter functionality
- [ ] Add export data to PDF/Excel

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributors

- Your Name - Initial work

## 📞 Support

Untuk pertanyaan atau bantuan, silakan hubungi:
- Email: support@kosterpadu.com
- Website: https://kosterpadu.com
