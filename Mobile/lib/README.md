# Source Code - Kos Terpadu

Dokumentasi untuk source code aplikasi Kos Terpadu.

## 📂 Struktur Folder

```
lib/
├── core/           # Core utilities & configurations
├── models/         # Data models
├── services/       # Service layer (API calls)
├── controllers/    # State management (Provider)
├── views/          # UI screens
├── widgets/        # Reusable widgets
├── routes/         # App routing
└── main.dart      # Entry point
```

## 🎯 Penjelasan Setiap Layer

### 1. Core (`core/`)

**Purpose**: Menyediakan utilities dan konfigurasi yang digunakan di seluruh aplikasi.

**Isi:**
- `config/` - Konfigurasi aplikasi (API URLs, Firebase config)
- `constants/` - Konstanta aplikasi (roles, status, keys)
- `services/` - Core services (HTTP, Firebase, Storage)
- `theme/` - Tema aplikasi (colors, text styles)
- `utils/` - Helper functions dan validators

**Kapan digunakan:**
- Saat butuh konfigurasi global
- Saat butuh konstanta
- Saat butuh helper functions
- Saat butuh akses ke HTTP/Firebase/Storage

### 2. Models (`models/`)

**Purpose**: Representasi data dan transformasi JSON.

**Isi:**
- `user_model.dart` - Model untuk user
- `kamar_model.dart` - Model untuk kamar
- `penghuni_model.dart` - Model untuk penghuni
- `pembayaran_model.dart` - Model untuk pembayaran
- `keluhan_model.dart` - Model untuk keluhan
- `chat_model.dart` - Model untuk chat

**Kapan digunakan:**
- Saat menerima data dari API
- Saat mengirim data ke API
- Saat menyimpan data di state

**Contoh:**
```dart
final kamar = KamarModel.fromJson(jsonData);
final json = kamar.toJson();
```

### 3. Services (`services/`)

**Purpose**: Business logic dan komunikasi dengan backend/Firebase.

**Isi:**
- `auth_service.dart` - Authentication API
- `kamar_service.dart` - Kamar CRUD API
- `keluhan_service.dart` - Keluhan Firebase operations
- `chat_service.dart` - Chat Firebase operations

**Kapan digunakan:**
- Saat butuh data dari API
- Saat butuh kirim data ke API
- Saat butuh operasi Firebase

**Contoh:**
```dart
final kamarList = await KamarService.getAllKamar();
await KeluhanService.createKeluhan(...);
```

### 4. Controllers (`controllers/`)

**Purpose**: State management menggunakan Provider.

**Isi:**
- `auth_controller.dart` - Auth state
- `kamar_controller.dart` - Kamar state
- `penghuni_controller.dart` - Penghuni state
- `pembayaran_controller.dart` - Pembayaran state
- `keluhan_controller.dart` - Keluhan state
- `chat_controller.dart` - Chat state

**Kapan digunakan:**
- Saat butuh manage state
- Saat butuh notify UI untuk update
- Saat butuh share state antar widgets

**Contoh:**
```dart
final controller = context.read<KamarController>();
await controller.getAllKamar();

// Di UI
Consumer<KamarController>(
  builder: (context, controller, _) {
    return Text(controller.kamarList.length.toString());
  },
)
```

### 5. Views (`views/`)

**Purpose**: UI screens dan presentasi data.

**Isi:**
- `splash/` - Splash screen
- `auth/` - Login & register screens
- `home/` - Home dashboard
- `kamar/` - Kamar list & detail
- `keluhan/` - Keluhan list & create
- `chat/` - Chat list & room

**Kapan digunakan:**
- Saat membuat screen baru
- Saat butuh tampilkan data ke user
- Saat butuh terima input dari user

**Contoh:**
```dart
class KamarListView extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kamar')),
      body: Consumer<KamarController>(
        builder: (context, controller, _) {
          return ListView.builder(...);
        },
      ),
    );
  }
}
```

### 6. Widgets (`widgets/`)

**Purpose**: Reusable UI components.

**Isi:**
- `custom_button.dart` - Button dengan loading state
- `custom_text_field.dart` - Text field dengan validation
- `kamar_card.dart` - Card untuk display kamar
- `menu_card.dart` - Card untuk menu items

**Kapan digunakan:**
- Saat butuh komponen yang reusable
- Saat butuh konsistensi UI
- Saat butuh simplify code

**Contoh:**
```dart
CustomButton(
  text: 'Login',
  onPressed: () => handleLogin(),
  isLoading: controller.isLoading,
)
```

### 7. Routes (`routes/`)

**Purpose**: App routing dan navigation.

**Isi:**
- `app_routes.dart` - Route definitions dan navigation

**Kapan digunakan:**
- Saat butuh navigate ke screen lain
- Saat butuh pass arguments
- Saat butuh named routes

**Contoh:**
```dart
Navigator.pushNamed(
  context,
  AppRoutes.kamarDetail,
  arguments: kamarId,
);
```

### 8. Main (`main.dart`)

**Purpose**: Entry point aplikasi.

**Isi:**
- Firebase initialization
- Provider setup
- MaterialApp configuration
- Initial route

## 🔄 Data Flow

```
User Action (View)
    ↓
Controller Method
    ↓
Service Method
    ↓
HTTP/Firebase Call
    ↓
Model Transformation
    ↓
Controller State Update
    ↓
View Rebuild
```

## 📝 Coding Guidelines

### 1. Naming Conventions

```dart
// Files: snake_case
user_model.dart
auth_controller.dart

// Classes: PascalCase
class UserModel { }
class AuthController { }

// Variables: camelCase
String userName;
int userAge;

// Constants: SCREAMING_SNAKE_CASE
const String API_BASE_URL = '...';

// Private: _leadingUnderscore
String _privateVar;
void _privateMethod() { }
```

### 2. File Organization

```dart
// 1. Imports
import 'package:flutter/material.dart';
import '../models/user_model.dart';

// 2. Class
class MyWidget extends StatelessWidget {
  // 3. Constants
  static const String title = 'Title';
  
  // 4. Fields
  final String name;
  
  // 5. Constructor
  const MyWidget({Key? key, required this.name}) : super(key: key);
  
  // 6. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 7. Public methods
  void publicMethod() { }
  
  // 8. Private methods
  void _privateMethod() { }
}
```

### 3. Error Handling

```dart
Future<void> loadData() async {
  try {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    _data = await MyService.getData();
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
  }
}
```

### 4. Comments

```dart
/// Documentation comment untuk public API
/// Gunakan triple slash
class UserModel {
  /// User's unique identifier
  final String id;
}

// Regular comment untuk internal notes
// Jelaskan "why", bukan "what"
void complexFunction() {
  // Calculate discount based on user tier
  final discount = _calculateDiscount();
}
```

## 🎯 Best Practices

### DO ✅

```dart
// ✅ Use const constructors
const Text('Hello');

// ✅ Use final for immutable variables
final String name = 'John';

// ✅ Use meaningful names
final List<KamarModel> availableRooms = [];

// ✅ Handle errors properly
try {
  await service.getData();
} catch (e) {
  print('Error: $e');
}

// ✅ Use async/await
Future<void> loadData() async {
  final data = await service.getData();
}
```

### DON'T ❌

```dart
// ❌ Don't use var when type is unclear
var x = getData(); // What type is x?

// ❌ Don't ignore errors
try {
  await service.getData();
} catch (e) {
  // Empty catch
}

// ❌ Don't call API from View
class MyView extends StatelessWidget {
  Future<void> loadData() async {
    final response = await http.get('...');
  }
}

// ❌ Don't use magic numbers
if (status == 1) { } // What is 1?

// ✅ Use constants instead
if (status == AppConstants.statusActive) { }
```

## 🔍 Finding Files

### Need to...

**Add new API endpoint?**
→ `services/` folder

**Add new screen?**
→ `views/` folder

**Add new model?**
→ `models/` folder

**Add new state?**
→ `controllers/` folder

**Add reusable widget?**
→ `widgets/` folder

**Change theme?**
→ `core/theme/app_theme.dart`

**Add constants?**
→ `core/constants/app_constants.dart`

**Add helper function?**
→ `core/utils/helpers.dart`

**Add validator?**
→ `core/utils/validators.dart`

## 🧪 Testing

### Unit Tests

Test models, services, controllers:

```dart
test('UserModel fromJson should parse correctly', () {
  final json = {'id': '1', 'name': 'John'};
  final user = UserModel.fromJson(json);
  expect(user.id, '1');
  expect(user.name, 'John');
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('CustomButton shows loading', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        text: 'Login',
        onPressed: () {},
        isLoading: true,
      ),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Firebase for Flutter](https://firebase.flutter.dev/)

## 🆘 Need Help?

- Check main [README.md](../README.md)
- Check [ARCHITECTURE.md](../ARCHITECTURE.md)
- Check [FOLDER_STRUCTURE.md](../FOLDER_STRUCTURE.md)
- Open issue on GitHub
- Email: dev@kosterpadu.com

---

**Happy Coding! 💻**
