# Arsitektur Aplikasi Kos Terpadu

## 📐 Pola Arsitektur: MVC + Service Layer

Aplikasi ini menggunakan **MVC (Model-View-Controller) + Service Layer Pattern** untuk memisahkan concerns dan meningkatkan maintainability.

### Mengapa MVC + Service Layer?

1. **Separation of Concerns**: Setiap layer memiliki tanggung jawab yang jelas
2. **Testability**: Mudah untuk unit test setiap layer secara terpisah
3. **Scalability**: Mudah untuk menambah fitur baru tanpa mengubah kode existing
4. **Maintainability**: Kode lebih mudah dibaca dan di-maintain
5. **Reusability**: Service layer bisa digunakan oleh multiple controllers

## 🏗️ Layer Architecture

```
┌─────────────────────────────────────────────────────────┐
│                         VIEW                            │
│  (UI Layer - Widgets, Screens, Components)              │
│  - Menampilkan data ke user                             │
│  - Menerima input dari user                             │
│  - Tidak ada business logic                             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                     CONTROLLER                          │
│  (State Management - Provider)                          │
│  - Mengelola state aplikasi                             │
│  - Memanggil service layer                              │
│  - Notify view ketika state berubah                     │
│  - Tidak ada direct API calls                           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                   SERVICE LAYER                         │
│  (Business Logic & API Calls)                           │
│  - Komunikasi dengan backend API                        │
│  - Komunikasi dengan Firebase                           │
│  - Transform data dari/ke model                         │
│  - Error handling                                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                       MODEL                             │
│  (Data Layer)                                           │
│  - Representasi data                                    │
│  - Serialization/Deserialization                        │
│  - Data validation                                      │
└─────────────────────────────────────────────────────────┘
```

## 📂 Struktur Folder Detail

### 1. Core Layer (`lib/core/`)

**Purpose**: Menyimpan konfigurasi, utilities, dan services yang digunakan di seluruh aplikasi.

```
core/
├── config/
│   └── app_config.dart          # API URLs, Firebase config, app settings
├── constants/
│   └── app_constants.dart       # Constants (roles, status, keys)
├── services/
│   ├── http_service.dart        # HTTP client wrapper
│   ├── firebase_service.dart    # Firebase operations wrapper
│   └── storage_service.dart     # Local storage wrapper
├── theme/
│   └── app_theme.dart           # App theme & styling
└── utils/
    ├── helpers.dart             # Helper functions
    └── validators.dart          # Form validators
```

**Contoh Penggunaan:**
```dart
// HTTP Service - Wrapper untuk semua HTTP requests
final response = await HttpService.get('/kamar');

// Firebase Service - Wrapper untuk Firestore operations
await FirebaseService.addDocument('keluhan', data);

// Storage Service - Wrapper untuk SharedPreferences
await StorageService.saveString('token', token);
```

### 2. Model Layer (`lib/models/`)

**Purpose**: Representasi data dan transformasi JSON.

```
models/
├── user_model.dart
├── kamar_model.dart
├── penghuni_model.dart
├── pembayaran_model.dart
├── keluhan_model.dart
└── chat_model.dart
```

**Contoh Model:**
```dart
class KamarModel {
  final String id;
  final String nomorKamar;
  final double harga;
  final String status;
  
  // From JSON (dari API)
  factory KamarModel.fromJson(Map<String, dynamic> json) {
    return KamarModel(
      id: json['id'].toString(),
      nomorKamar: json['nomor_kamar'],
      harga: double.parse(json['harga'].toString()),
      status: json['status'],
    );
  }
  
  // To JSON (untuk API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_kamar': nomorKamar,
      'harga': harga,
      'status': status,
    };
  }
}
```

### 3. Service Layer (`lib/services/`)

**Purpose**: Business logic dan komunikasi dengan backend/Firebase.

```
services/
├── auth_service.dart
├── kamar_service.dart
├── penghuni_service.dart
├── pembayaran_service.dart
├── keluhan_service.dart
└── chat_service.dart
```

**Contoh Service:**
```dart
class KamarService {
  // Get All Kamar
  static Future<List<KamarModel>> getAllKamar({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      
      final response = await HttpService.get(
        AppConfig.kamarEndpoint,
        queryParams: queryParams,
      );
      
      final List<dynamic> data = response['data'];
      return data.map((json) => KamarModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kamar: ${e.toString()}');
    }
  }
  
  // Create Kamar
  static Future<KamarModel> createKamar({
    required String nomorKamar,
    required double harga,
  }) async {
    try {
      final response = await HttpService.post(
        AppConfig.kamarEndpoint,
        body: {
          'nomor_kamar': nomorKamar,
          'harga': harga,
          'status': 'kosong',
        },
      );
      
      return KamarModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Gagal menambah kamar: ${e.toString()}');
    }
  }
}
```

### 4. Controller Layer (`lib/controllers/`)

**Purpose**: State management menggunakan Provider.

```
controllers/
├── auth_controller.dart
├── kamar_controller.dart
├── penghuni_controller.dart
├── pembayaran_controller.dart
├── keluhan_controller.dart
└── chat_controller.dart
```

**Contoh Controller:**
```dart
class KamarController extends ChangeNotifier {
  List<KamarModel> _kamarList = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<KamarModel> get kamarList => _kamarList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get All Kamar
  Future<void> getAllKamar({String? status}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners(); // Update UI
      
      _kamarList = await KamarService.getAllKamar(status: status);
      
      _isLoading = false;
      notifyListeners(); // Update UI
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners(); // Update UI
    }
  }
}
```

### 5. View Layer (`lib/views/`)

**Purpose**: UI dan presentasi data.

```
views/
├── splash/
│   └── splash_view.dart
├── auth/
│   ├── login_view.dart
│   └── register_view.dart
├── home/
│   └── home_view.dart
├── kamar/
│   ├── kamar_list_view.dart
│   └── kamar_detail_view.dart
├── keluhan/
│   ├── keluhan_list_view.dart
│   └── create_keluhan_view.dart
└── chat/
    ├── chat_list_view.dart
    └── chat_room_view.dart
```

**Contoh View:**
```dart
class KamarListView extends StatefulWidget {
  @override
  State<KamarListView> createState() => _KamarListViewState();
}

class _KamarListViewState extends State<KamarListView> {
  @override
  void initState() {
    super.initState();
    // Load data saat view dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KamarController>().getAllKamar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Kamar')),
      body: Consumer<KamarController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }
          
          return ListView.builder(
            itemCount: controller.kamarList.length,
            itemBuilder: (context, index) {
              final kamar = controller.kamarList[index];
              return KamarCard(kamar: kamar);
            },
          );
        },
      ),
    );
  }
}
```

### 6. Widgets Layer (`lib/widgets/`)

**Purpose**: Reusable UI components.

```
widgets/
├── custom_button.dart
├── custom_text_field.dart
├── kamar_card.dart
└── menu_card.dart
```

## 🔄 Data Flow

### 1. User Action → View → Controller → Service → API

```
User clicks button
    ↓
View calls controller method
    ↓
Controller calls service method
    ↓
Service makes HTTP request
    ↓
API returns data
    ↓
Service transforms to Model
    ↓
Controller updates state
    ↓
View rebuilds with new data
```

**Contoh:**
```dart
// 1. User clicks button in View
ElevatedButton(
  onPressed: () async {
    // 2. View calls Controller
    final controller = context.read<KamarController>();
    await controller.getAllKamar();
  },
  child: Text('Load Kamar'),
)

// 3. Controller calls Service
class KamarController extends ChangeNotifier {
  Future<void> getAllKamar() async {
    _kamarList = await KamarService.getAllKamar(); // Service call
    notifyListeners();
  }
}

// 4. Service makes HTTP request
class KamarService {
  static Future<List<KamarModel>> getAllKamar() async {
    final response = await HttpService.get('/kamar'); // HTTP call
    return response['data'].map((json) => KamarModel.fromJson(json)).toList();
  }
}
```

### 2. Realtime Data Flow (Firebase)

```
Firebase Firestore
    ↓
Service streams data
    ↓
Controller exposes stream
    ↓
View listens to stream
    ↓
View rebuilds on data change
```

**Contoh:**
```dart
// Service provides stream
class KeluhanService {
  static Stream<List<KeluhanModel>> streamKeluhan() {
    return FirebaseService.streamDocuments('keluhan')
      .map((docs) => docs.map((doc) => KeluhanModel.fromFirestore(doc)).toList());
  }
}

// Controller exposes stream
class KeluhanController extends ChangeNotifier {
  Stream<List<KeluhanModel>> streamKeluhan() {
    return KeluhanService.streamKeluhan();
  }
}

// View listens to stream
StreamBuilder<List<KeluhanModel>>(
  stream: controller.streamKeluhan(),
  builder: (context, snapshot) {
    final keluhanList = snapshot.data ?? [];
    return ListView.builder(...);
  },
)
```

## 🗄️ Database Strategy

### PostgreSQL (via REST API)
**Digunakan untuk data yang memerlukan:**
- ✅ Relational data (foreign keys)
- ✅ Complex queries & joins
- ✅ Transactions
- ✅ Data integrity
- ✅ Historical data

**Contoh:**
- Users
- Kamar
- Penghuni
- Pembayaran
- Tagihan

### Firebase Firestore
**Digunakan untuk data yang memerlukan:**
- ✅ Realtime updates
- ✅ Offline support
- ✅ Scalability
- ✅ Simple queries
- ✅ Fast reads

**Contoh:**
- Keluhan (realtime updates)
- Chat messages (realtime)
- Notifications (realtime)

### Firebase Storage
**Digunakan untuk:**
- ✅ File uploads
- ✅ Images
- ✅ Documents

**Contoh:**
- Foto keluhan
- Bukti pembayaran
- Profile pictures

## 🔐 Authentication Flow

```
1. User enters credentials
    ↓
2. View calls AuthController.login()
    ↓
3. AuthController calls AuthService.login()
    ↓
4. AuthService makes POST /auth/login
    ↓
5. API returns token + user data
    ↓
6. AuthService saves token to StorageService
    ↓
7. AuthService returns UserModel
    ↓
8. AuthController updates currentUser
    ↓
9. View navigates to Home
```

**Subsequent Requests:**
```
1. Service makes API call
    ↓
2. HttpService gets token from StorageService
    ↓
3. HttpService adds token to Authorization header
    ↓
4. API validates token
    ↓
5. API returns data
```

## 🎯 Best Practices

### 1. Separation of Concerns
- ❌ **Jangan** panggil API langsung dari View
- ✅ **Gunakan** Controller → Service → API

### 2. Error Handling
- ✅ Try-catch di semua async operations
- ✅ User-friendly error messages
- ✅ Log errors untuk debugging

### 3. Loading States
- ✅ Tampilkan loading indicator
- ✅ Disable button saat loading
- ✅ Handle empty states

### 4. Code Reusability
- ✅ Buat reusable widgets
- ✅ Buat reusable services
- ✅ Buat helper functions

### 5. State Management
- ✅ Gunakan Provider untuk global state
- ✅ Gunakan setState untuk local state
- ✅ Dispose controllers dengan benar

## 📊 Performance Optimization

### 1. Lazy Loading
```dart
// Load data only when needed
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<KamarController>().getAllKamar();
  });
}
```

### 2. Pagination
```dart
// Load data in chunks
Future<void> loadMore() async {
  await controller.getAllKamar(page: currentPage + 1);
}
```

### 3. Caching
```dart
// Cache data locally
if (controller.kamarList.isEmpty) {
  await controller.getAllKamar();
}
```

### 4. Debouncing
```dart
// Debounce search input
Timer? _debounce;
void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    controller.search(query);
  });
}
```

## 🧪 Testing Strategy

### 1. Unit Tests
- Test models (fromJson, toJson)
- Test services (API calls)
- Test controllers (state management)
- Test utilities (helpers, validators)

### 2. Widget Tests
- Test individual widgets
- Test user interactions
- Test navigation

### 3. Integration Tests
- Test complete user flows
- Test API integration
- Test Firebase integration

## 📝 Naming Conventions

### Files
- `snake_case.dart` untuk semua file
- `model_name_model.dart` untuk models
- `feature_name_service.dart` untuk services
- `feature_name_controller.dart` untuk controllers
- `feature_name_view.dart` untuk views

### Classes
- `PascalCase` untuk class names
- `Model` suffix untuk models
- `Service` suffix untuk services
- `Controller` suffix untuk controllers
- `View` suffix untuk views

### Variables
- `camelCase` untuk variables
- `_privateVariable` untuk private variables
- `SCREAMING_SNAKE_CASE` untuk constants

## 🚀 Scalability

Arsitektur ini dirancang untuk scalable:

1. **Horizontal Scaling**: Mudah menambah fitur baru
2. **Vertical Scaling**: Mudah menambah complexity pada fitur existing
3. **Team Scaling**: Multiple developers bisa bekerja parallel
4. **Code Reusability**: Service layer bisa digunakan di multiple places

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
