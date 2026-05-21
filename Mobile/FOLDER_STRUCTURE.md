# Folder Structure - Kos Terpadu

## 📂 Complete Project Structure

```
kos_terpadu/
│
├── lib/                                    # Source code utama
│   │
│   ├── core/                              # Core utilities & configurations
│   │   ├── config/
│   │   │   └── app_config.dart           # API URLs, Firebase config
│   │   ├── constants/
│   │   │   └── app_constants.dart        # App constants
│   │   ├── services/
│   │   │   ├── http_service.dart         # HTTP client wrapper
│   │   │   ├── firebase_service.dart     # Firebase operations
│   │   │   └── storage_service.dart      # Local storage
│   │   ├── theme/
│   │   │   └── app_theme.dart            # App theme & styling
│   │   └── utils/
│   │       ├── helpers.dart              # Helper functions
│   │       └── validators.dart           # Form validators
│   │
│   ├── models/                            # Data models
│   │   ├── user_model.dart               # User data model
│   │   ├── kamar_model.dart              # Kamar data model
│   │   ├── penghuni_model.dart           # Penghuni data model
│   │   ├── pembayaran_model.dart         # Pembayaran data model
│   │   ├── keluhan_model.dart            # Keluhan data model
│   │   └── chat_model.dart               # Chat data models
│   │
│   ├── services/                          # Service layer (API calls)
│   │   ├── auth_service.dart             # Authentication API
│   │   ├── kamar_service.dart            # Kamar API
│   │   ├── keluhan_service.dart          # Keluhan Firebase
│   │   └── chat_service.dart             # Chat Firebase
│   │
│   ├── controllers/                       # State management (Provider)
│   │   ├── auth_controller.dart          # Auth state
│   │   ├── kamar_controller.dart         # Kamar state
│   │   ├── penghuni_controller.dart      # Penghuni state
│   │   ├── pembayaran_controller.dart    # Pembayaran state
│   │   ├── keluhan_controller.dart       # Keluhan state
│   │   └── chat_controller.dart          # Chat state
│   │
│   ├── views/                             # UI screens
│   │   ├── splash/
│   │   │   └── splash_view.dart          # Splash screen
│   │   ├── auth/
│   │   │   ├── login_view.dart           # Login screen
│   │   │   └── register_view.dart        # Register screen
│   │   ├── home/
│   │   │   └── home_view.dart            # Home dashboard
│   │   ├── kamar/
│   │   │   ├── kamar_list_view.dart      # Kamar list
│   │   │   └── kamar_detail_view.dart    # Kamar detail
│   │   ├── keluhan/
│   │   │   ├── keluhan_list_view.dart    # Keluhan list
│   │   │   └── create_keluhan_view.dart  # Create keluhan
│   │   └── chat/
│   │       ├── chat_list_view.dart       # Chat list
│   │       └── chat_room_view.dart       # Chat room
│   │
│   ├── widgets/                           # Reusable widgets
│   │   ├── custom_button.dart            # Custom button
│   │   ├── custom_text_field.dart        # Custom text field
│   │   ├── kamar_card.dart               # Kamar card
│   │   └── menu_card.dart                # Menu card
│   │
│   ├── routes/
│   │   └── app_routes.dart               # App routing
│   │
│   └── main.dart                          # Entry point
│
├── android/                               # Android specific files
│   └── app/
│       ├── build.gradle                  # Android build config
│       └── google-services.json          # Firebase config (Android)
│
├── ios/                                   # iOS specific files
│   └── Runner/
│       └── GoogleService-Info.plist      # Firebase config (iOS)
│
├── test/                                  # Unit & widget tests
│   └── (test files)
│
├── integration_test/                      # Integration tests
│   └── (integration test files)
│
├── assets/                                # Static assets
│   ├── images/                           # Images
│   └── fonts/                            # Custom fonts
│
├── docs/                                  # Additional documentation
│   └── (documentation files)
│
├── .gitignore                            # Git ignore rules
├── analysis_options.yaml                 # Dart analyzer config
├── pubspec.yaml                          # Dependencies
├── README.md                             # Main documentation
├── ARCHITECTURE.md                       # Architecture guide
├── API_DOCUMENTATION.md                  # API documentation
├── SETUP_GUIDE.md                        # Setup instructions
├── ERD_DIAGRAM.md                        # Database schema
├── PROJECT_SUMMARY.md                    # Project overview
├── QUICK_START.md                        # Quick start guide
├── CONTRIBUTING.md                       # Contribution guide
├── CHANGELOG.md                          # Version history
├── FOLDER_STRUCTURE.md                   # This file
└── LICENSE                               # MIT License
```

## 📊 File Count Summary

### Source Code (lib/)
- **Core**: 9 files
  - Config: 1
  - Constants: 1
  - Services: 3
  - Theme: 1
  - Utils: 2

- **Models**: 6 files
  - user_model.dart
  - kamar_model.dart
  - penghuni_model.dart
  - pembayaran_model.dart
  - keluhan_model.dart
  - chat_model.dart

- **Services**: 4 files
  - auth_service.dart
  - kamar_service.dart
  - keluhan_service.dart
  - chat_service.dart

- **Controllers**: 6 files
  - auth_controller.dart
  - kamar_controller.dart
  - penghuni_controller.dart
  - pembayaran_controller.dart
  - keluhan_controller.dart
  - chat_controller.dart

- **Views**: 10 files
  - Splash: 1
  - Auth: 2
  - Home: 1
  - Kamar: 2
  - Keluhan: 2
  - Chat: 2

- **Widgets**: 4 files
  - custom_button.dart
  - custom_text_field.dart
  - kamar_card.dart
  - menu_card.dart

- **Routes**: 1 file
  - app_routes.dart

- **Main**: 1 file
  - main.dart

**Total Source Files: ~40 files**

### Documentation
- README.md
- ARCHITECTURE.md
- API_DOCUMENTATION.md
- SETUP_GUIDE.md
- ERD_DIAGRAM.md
- PROJECT_SUMMARY.md
- QUICK_START.md
- CONTRIBUTING.md
- CHANGELOG.md
- FOLDER_STRUCTURE.md

**Total Documentation: 10 files**

### Configuration
- pubspec.yaml
- analysis_options.yaml
- .gitignore
- LICENSE

**Total Configuration: 4 files**

## 🎯 File Purposes

### Core Layer
| File | Purpose |
|------|---------|
| app_config.dart | API URLs, Firebase config, app settings |
| app_constants.dart | Constants (roles, status, storage keys) |
| http_service.dart | HTTP client wrapper for REST API |
| firebase_service.dart | Firebase operations (Firestore, Storage) |
| storage_service.dart | Local storage (SharedPreferences) |
| app_theme.dart | App theme, colors, text styles |
| helpers.dart | Helper functions (format, parse, etc) |
| validators.dart | Form validation functions |

### Models
| File | Purpose |
|------|---------|
| user_model.dart | User data structure |
| kamar_model.dart | Kamar data structure |
| penghuni_model.dart | Penghuni data structure |
| pembayaran_model.dart | Pembayaran data structure |
| keluhan_model.dart | Keluhan data structure (Firebase) |
| chat_model.dart | Chat & message data structures |

### Services
| File | Purpose |
|------|---------|
| auth_service.dart | Authentication API calls |
| kamar_service.dart | Kamar CRUD API calls |
| keluhan_service.dart | Keluhan Firebase operations |
| chat_service.dart | Chat Firebase operations |

### Controllers
| File | Purpose |
|------|---------|
| auth_controller.dart | Authentication state management |
| kamar_controller.dart | Kamar state management |
| penghuni_controller.dart | Penghuni state management |
| pembayaran_controller.dart | Pembayaran state management |
| keluhan_controller.dart | Keluhan state management |
| chat_controller.dart | Chat state management |

### Views
| File | Purpose |
|------|---------|
| splash_view.dart | Splash screen & auth check |
| login_view.dart | Login form |
| register_view.dart | Registration form |
| home_view.dart | Home dashboard with menu |
| kamar_list_view.dart | List of kamar |
| kamar_detail_view.dart | Kamar details |
| keluhan_list_view.dart | List of keluhan (realtime) |
| create_keluhan_view.dart | Create keluhan form |
| chat_list_view.dart | List of chat rooms |
| chat_room_view.dart | Chat messages (realtime) |

### Widgets
| File | Purpose |
|------|---------|
| custom_button.dart | Reusable button with loading |
| custom_text_field.dart | Reusable text field with validation |
| kamar_card.dart | Card for displaying kamar |
| menu_card.dart | Card for home menu items |

## 🔍 Navigation Flow

```
Splash Screen
    ↓
    ├─→ Login (if not authenticated)
    │       ↓
    │   Register
    │       ↓
    └─→ Home Dashboard (if authenticated)
            ↓
            ├─→ Kamar List → Kamar Detail
            ├─→ Keluhan List → Create Keluhan
            └─→ Chat List → Chat Room
```

## 📦 Dependencies Organization

### State Management
- Provider (controllers/)

### Networking
- HTTP package (services/)
- Firebase SDK (services/)

### Storage
- SharedPreferences (core/services/)
- Firebase Storage (core/services/)

### UI
- Material Design (views/, widgets/)
- Custom theme (core/theme/)

## 🎨 Design Patterns Used

1. **MVC Pattern**
   - Model: models/
   - View: views/
   - Controller: controllers/

2. **Service Layer Pattern**
   - services/

3. **Repository Pattern**
   - Implemented in services/

4. **Singleton Pattern**
   - Used in core/services/

5. **Factory Pattern**
   - Used in models/ (fromJson)

6. **Observer Pattern**
   - Provider (ChangeNotifier)

## 🔐 Security Files

- .gitignore - Excludes sensitive files
- google-services.json - Firebase config (gitignored)
- .env files - Environment variables (gitignored)

## 📝 Documentation Files

Each documentation file serves a specific purpose:

| File | Purpose |
|------|---------|
| README.md | Main entry point, overview |
| ARCHITECTURE.md | Detailed architecture explanation |
| API_DOCUMENTATION.md | Backend API reference |
| SETUP_GUIDE.md | Step-by-step setup |
| ERD_DIAGRAM.md | Database schema |
| PROJECT_SUMMARY.md | High-level overview |
| QUICK_START.md | 5-minute quick start |
| CONTRIBUTING.md | Contribution guidelines |
| CHANGELOG.md | Version history |
| FOLDER_STRUCTURE.md | This file |

## 🚀 Build Outputs

```
build/
├── app/
│   ├── outputs/
│   │   ├── flutter-apk/
│   │   │   └── app-release.apk      # Android APK
│   │   └── bundle/
│   │       └── release/
│   │           └── app-release.aab  # Android App Bundle
│   └── intermediates/
└── ios/
    └── iphoneos/
        └── Runner.app                # iOS app
```

## 📊 Code Statistics

- **Total Lines of Code**: ~5,000+ lines
- **Dart Files**: ~40 files
- **Documentation**: ~10 files
- **Configuration**: ~4 files
- **Total Files**: ~54 files

## 🎯 Key Directories

### Most Important
1. `lib/` - All source code
2. `lib/core/` - Core functionality
3. `lib/services/` - Business logic
4. `lib/controllers/` - State management
5. `lib/views/` - UI screens

### Configuration
1. `pubspec.yaml` - Dependencies
2. `analysis_options.yaml` - Linting
3. `.gitignore` - Git rules

### Documentation
1. `README.md` - Start here
2. `SETUP_GUIDE.md` - Setup instructions
3. `ARCHITECTURE.md` - Architecture details

---

**Last Updated**: 2024  
**Version**: 1.0.0  
**Total Files**: ~54 files  
**Total Lines**: ~5,000+ lines
