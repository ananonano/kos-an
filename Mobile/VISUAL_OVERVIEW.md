# 📊 Visual Overview - Kos Terpadu

Visualisasi lengkap arsitektur dan alur aplikasi Kos Terpadu.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER MOBILE APP                         │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                        VIEWS                             │  │
│  │  (UI Layer - Screens, Widgets, Components)               │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│                       ▼                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    CONTROLLERS                           │  │
│  │  (State Management - Provider)                           │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│                       ▼                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     SERVICES                             │  │
│  │  (Business Logic - API Calls, Firebase Operations)       │  │
│  └────────────────────┬─────────────────────────────────────┘  │
│                       │                                         │
│                       ▼                                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                      MODELS                              │  │
│  │  (Data Layer - Data Structures)                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└────────────────────┬────────────────────┬───────────────────────┘
                     │                    │
                     ▼                    ▼
        ┌────────────────────┐  ┌────────────────────┐
        │   EXPRESS.JS API   │  │     FIREBASE       │
        │   (REST API)       │  │   (Realtime DB)    │
        └─────────┬──────────┘  └─────────┬──────────┘
                  │                       │
                  ▼                       ▼
        ┌────────────────────┐  ┌────────────────────┐
        │   POSTGRESQL       │  │  CLOUD FIRESTORE   │
        │  (Relational DB)   │  │  FIREBASE STORAGE  │
        └────────────────────┘  └────────────────────┘
```

## 🔄 Data Flow Diagram

### REST API Flow (PostgreSQL)

```
┌──────────┐
│   USER   │
└────┬─────┘
     │ 1. Action (tap button)
     ▼
┌──────────────┐
│     VIEW     │
└────┬─────────┘
     │ 2. Call controller method
     ▼
┌──────────────┐
│  CONTROLLER  │
└────┬─────────┘
     │ 3. Call service method
     ▼
┌──────────────┐
│   SERVICE    │
└────┬─────────┘
     │ 4. HTTP Request (with JWT)
     ▼
┌──────────────┐
│ HTTP SERVICE │
└────┬─────────┘
     │ 5. REST API Call
     ▼
┌──────────────┐
│ EXPRESS API  │
└────┬─────────┘
     │ 6. SQL Query
     ▼
┌──────────────┐
│  POSTGRESQL  │
└────┬─────────┘
     │ 7. Data
     ▼
┌──────────────┐
│ EXPRESS API  │
└────┬─────────┘
     │ 8. JSON Response
     ▼
┌──────────────┐
│ HTTP SERVICE │
└────┬─────────┘
     │ 9. Parse to Model
     ▼
┌──────────────┐
│   SERVICE    │
└────┬─────────┘
     │ 10. Return Model
     ▼
┌──────────────┐
│  CONTROLLER  │
└────┬─────────┘
     │ 11. Update State & notifyListeners()
     ▼
┌──────────────┐
│     VIEW     │
└────┬─────────┘
     │ 12. Rebuild UI
     ▼
┌──────────┐
│   USER   │
└──────────┘
```

### Firebase Realtime Flow

```
┌──────────┐
│   USER   │
└────┬─────┘
     │ 1. Action (send message)
     ▼
┌──────────────┐
│     VIEW     │
└────┬─────────┘
     │ 2. Call controller method
     ▼
┌──────────────┐
│  CONTROLLER  │
└────┬─────────┘
     │ 3. Call service method
     ▼
┌──────────────┐
│   SERVICE    │
└────┬─────────┘
     │ 4. Firebase write
     ▼
┌──────────────┐
│FIREBASE SVC  │
└────┬─────────┘
     │ 5. Add document
     ▼
┌──────────────┐
│  FIRESTORE   │
└────┬─────────┘
     │ 6. Realtime update
     ▼
┌──────────────┐
│FIREBASE SVC  │
└────┬─────────┘
     │ 7. Stream snapshot
     ▼
┌──────────────┐
│   SERVICE    │
└────┬─────────┘
     │ 8. Parse to Model
     ▼
┌──────────────┐
│  CONTROLLER  │
└────┬─────────┘
     │ 9. Stream to View
     ▼
┌──────────────┐
│     VIEW     │
│ StreamBuilder│
└────┬─────────┘
     │ 10. Auto rebuild on new data
     ▼
┌──────────┐
│   USER   │
└──────────┘
```

## 🗂️ Folder Structure Visual

```
kos_terpadu/
│
├── 📱 lib/                          # Source Code
│   ├── ⚙️ core/                     # Core Utilities
│   │   ├── config/                 # Configuration
│   │   ├── constants/              # Constants
│   │   ├── services/               # Core Services
│   │   ├── theme/                  # Theme
│   │   └── utils/                  # Utilities
│   │
│   ├── 📦 models/                   # Data Models
│   │   ├── user_model.dart
│   │   ├── kamar_model.dart
│   │   ├── penghuni_model.dart
│   │   ├── pembayaran_model.dart
│   │   ├── keluhan_model.dart
│   │   └── chat_model.dart
│   │
│   ├── 🔌 services/                 # Service Layer
│   │   ├── auth_service.dart
│   │   ├── kamar_service.dart
│   │   ├── keluhan_service.dart
│   │   └── chat_service.dart
│   │
│   ├── 🎮 controllers/              # State Management
│   │   ├── auth_controller.dart
│   │   ├── kamar_controller.dart
│   │   ├── penghuni_controller.dart
│   │   ├── pembayaran_controller.dart
│   │   ├── keluhan_controller.dart
│   │   └── chat_controller.dart
│   │
│   ├── 📺 views/                    # UI Screens
│   │   ├── splash/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── kamar/
│   │   ├── keluhan/
│   │   └── chat/
│   │
│   ├── 🧩 widgets/                  # Reusable Widgets
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── kamar_card.dart
│   │   └── menu_card.dart
│   │
│   ├── 🗺️ routes/                   # Routing
│   │   └── app_routes.dart
│   │
│   └── 🚀 main.dart                 # Entry Point
│
├── 📚 Documentation/                # 12 Files
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── API_DOCUMENTATION.md
│   ├── SETUP_GUIDE.md
│   ├── ERD_DIAGRAM.md
│   ├── PROJECT_SUMMARY.md
│   ├── QUICK_START.md
│   ├── CONTRIBUTING.md
│   ├── CHANGELOG.md
│   ├── FOLDER_STRUCTURE.md
│   ├── DOCS_INDEX.md
│   └── VISUAL_OVERVIEW.md
│
└── ⚙️ Configuration/                # 4 Files
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── .gitignore
    └── LICENSE
```

## 🎯 Feature Map

```
┌─────────────────────────────────────────────────────────────┐
│                      KOS TERPADU APP                        │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
         ┌──────▼──────┐           ┌───────▼────────┐
         │    ADMIN    │           │   PENGHUNI     │
         └──────┬──────┘           └───────┬────────┘
                │                           │
    ┌───────────┼───────────┐      ┌───────┼────────┐
    │           │           │      │       │        │
    ▼           ▼           ▼      ▼       ▼        ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────┐ ┌────┐ ┌────┐
│ Kamar  │ │Penghuni│ │Keluhan │ │Kamar│ │Kelu│ │Chat│
│  CRUD  │ │  CRUD  │ │ Manage │ │View │ │han │ │    │
└────────┘ └────────┘ └────────┘ └────┘ └────┘ └────┘
┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐ ┌────┐
│Bayar   │ │  Chat  │ │Dashboard│ │  Bayar     │ │Notif│
│Verify  │ │        │ │         │ │  Upload    │ │     │
└────────┘ └────────┘ └────────┘ └────────────┘ └────┘
```

## 🔐 Authentication Flow

```
┌─────────────┐
│   START     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Splash Screen│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Check Token? │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
   ▼       ▼
┌─────┐ ┌─────┐
│ Yes │ │ No  │
└──┬──┘ └──┬──┘
   │       │
   │       ▼
   │  ┌─────────┐
   │  │  Login  │
   │  └────┬────┘
   │       │
   │       ├──────┐
   │       │      │
   │       ▼      ▼
   │  ┌────────┐ ┌────────┐
   │  │Success │ │Register│
   │  └────┬───┘ └────┬───┘
   │       │          │
   │       │          ▼
   │       │     ┌────────┐
   │       │     │Success │
   │       │     └────┬───┘
   │       │          │
   └───────┴──────────┘
           │
           ▼
    ┌─────────────┐
    │    HOME     │
    │  Dashboard  │
    └─────────────┘
```

## 📊 Database Relationship

```
┌──────────┐
│  USERS   │
└────┬─────┘
     │ 1:1
     ▼
┌──────────┐      ┌──────────┐
│ PENGHUNI │ N:1  │  KAMAR   │
└────┬─────┘ ───> └──────────┘
     │ 1:N
     ├──────────────┐
     │              │
     ▼              ▼
┌──────────┐   ┌──────────┐
│ TAGIHAN  │   │PEMBAYARAN│
└────┬─────┘   └──────────┘
     │ 1:N
     ▼
┌──────────┐
│PEMBAYARAN│
└──────────┘

Firebase (Logical References):
┌──────────┐
│ KELUHAN  │ ──> penghuni_id (users.id)
└──────────┘ ──> kamar_id (kamar.id)

┌──────────┐
│  CHATS   │ ──> penghuni_id (users.id)
└────┬─────┘ ──> admin_id (users.id)
     │ 1:N
     ▼
┌──────────┐
│ MESSAGES │ ──> sender_id (users.id)
└──────────┘
```

## 🎨 UI Flow

```
Splash
  │
  ├─→ Login ──→ Register
  │      │
  │      ▼
  └─→ Home Dashboard
         │
         ├─→ Kamar List ──→ Kamar Detail
         │
         ├─→ Keluhan List ──→ Create Keluhan
         │                 └→ Keluhan Detail
         │
         ├─→ Chat List ──→ Chat Room
         │
         ├─→ Pembayaran List ──→ Upload Bukti
         │
         └─→ Profile ──→ Edit Profile
                     └→ Logout
```

## 🔄 State Management Flow

```
┌──────────────────────────────────────────────────┐
│              PROVIDER PATTERN                    │
└──────────────────────────────────────────────────┘

┌──────────────┐
│ChangeNotifier│ (Controller)
└──────┬───────┘
       │
       ├─→ State Variables (_data, _isLoading, _error)
       │
       ├─→ Getters (data, isLoading, error)
       │
       ├─→ Methods (loadData(), updateData())
       │
       └─→ notifyListeners() ──┐
                                │
                                ▼
                        ┌───────────────┐
                        │   CONSUMER    │
                        │   (Widget)    │
                        └───────┬───────┘
                                │
                                ▼
                        ┌───────────────┐
                        │  UI REBUILD   │
                        └───────────────┘
```

## 📱 Screen Hierarchy

```
MaterialApp
  │
  ├─→ SplashView
  │
  ├─→ LoginView
  │
  ├─→ RegisterView
  │
  └─→ HomeView
        │
        ├─→ KamarListView
        │     └─→ KamarDetailView
        │
        ├─→ KeluhanListView
        │     └─→ CreateKeluhanView
        │
        ├─→ ChatListView
        │     └─→ ChatRoomView
        │
        └─→ PembayaranListView
              └─→ UploadBuktiView
```

## 🎯 Component Hierarchy

```
CustomButton
  ├─→ ElevatedButton
  │     ├─→ Text (when not loading)
  │     └─→ CircularProgressIndicator (when loading)
  │
CustomTextField
  ├─→ Column
  │     ├─→ Text (label)
  │     └─→ TextFormField
  │           ├─→ InputDecoration
  │           └─→ Validator
  │
KamarCard
  ├─→ Card
  │     └─→ InkWell
  │           └─→ Row
  │                 ├─→ Icon
  │                 ├─→ Column (info)
  │                 └─→ Badge (status)
  │
MenuCard
  └─→ Card
        └─→ InkWell
              └─→ Column
                    ├─→ Icon
                    ├─→ Text (title)
                    └─→ Text (subtitle)
```

## 🔌 API Integration

```
┌─────────────────────────────────────────────────┐
│              HTTP SERVICE WRAPPER               │
└─────────────────────────────────────────────────┘

Request Flow:
┌──────────┐
│ Service  │
└────┬─────┘
     │ Call HttpService.get/post/put/delete
     ▼
┌──────────┐
│HttpService│
└────┬─────┘
     │ 1. Get token from StorageService
     │ 2. Add Authorization header
     │ 3. Make HTTP request
     │ 4. Handle response
     │ 5. Parse JSON
     │ 6. Return data or throw error
     ▼
┌──────────┐
│ Service  │
└────┬─────┘
     │ Transform to Model
     ▼
┌──────────┐
│Controller│
└──────────┘
```

## 🔥 Firebase Integration

```
┌─────────────────────────────────────────────────┐
│           FIREBASE SERVICE WRAPPER              │
└─────────────────────────────────────────────────┘

Firestore Flow:
┌──────────┐
│ Service  │
└────┬─────┘
     │ Call FirebaseService.addDocument/updateDocument
     ▼
┌──────────┐
│Firebase  │
│ Service  │
└────┬─────┘
     │ 1. Get collection reference
     │ 2. Add timestamps
     │ 3. Perform operation
     │ 4. Return document ID
     ▼
┌──────────┐
│Firestore │
└────┬─────┘
     │ Realtime sync
     ▼
┌──────────┐
│ Service  │
└────┬─────┘
     │ Stream snapshots
     ▼
┌──────────┐
│Controller│
└────┬─────┘
     │ Expose stream
     ▼
┌──────────┐
│   View   │
│StreamBuilder
└──────────┘
```

## 📈 Performance Optimization

```
┌─────────────────────────────────────────────────┐
│          OPTIMIZATION STRATEGIES                │
└─────────────────────────────────────────────────┘

1. Lazy Loading
   ├─→ Load data only when needed
   └─→ Use initState() for initial load

2. Pagination
   ├─→ Load data in chunks
   └─→ Infinite scroll

3. Caching
   ├─→ Cache API responses
   └─→ Use local storage

4. Image Optimization
   ├─→ Compress images
   ├─→ Use cached_network_image
   └─→ Lazy load images

5. State Management
   ├─→ Use Provider efficiently
   ├─→ Minimize rebuilds
   └─→ Use const constructors

6. Firebase
   ├─→ Use indexes
   ├─→ Limit query results
   └─→ Use pagination
```

---

**Last Updated**: 2024  
**Version**: 1.0.0  
**Status**: Complete ✅
