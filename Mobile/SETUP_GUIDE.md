# Setup Guide - Kos Terpadu

Panduan lengkap untuk setup dan menjalankan aplikasi Kos Terpadu.

## 📋 Prerequisites

Sebelum memulai, pastikan Anda sudah menginstall:

1. **Flutter SDK** (>=3.0.0)
   - Download: https://flutter.dev/docs/get-started/install
   - Verify: `flutter doctor`

2. **Dart SDK** (included with Flutter)
   - Verify: `dart --version`

3. **Android Studio** atau **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code: https://code.visualstudio.com/

4. **Git**
   - Download: https://git-scm.com/downloads

5. **Firebase Account**
   - Sign up: https://console.firebase.google.com/

6. **PostgreSQL Database** (untuk backend)
   - Download: https://www.postgresql.org/download/

7. **Node.js & npm** (untuk backend Express.js)
   - Download: https://nodejs.org/

## 🚀 Step-by-Step Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd kos_terpadu
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### A. Create Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Masukkan nama project: "Kos Terpadu"
4. Enable Google Analytics (optional)
5. Click "Create project"

#### B. Add Android App

1. Di Firebase Console, click "Add app" → Android
2. Masukkan package name: `com.example.kos_terpadu`
   - Cek di `android/app/build.gradle` → `applicationId`
3. Download `google-services.json`
4. Copy file ke `android/app/google-services.json`

#### C. Add iOS App (Optional)

1. Di Firebase Console, click "Add app" → iOS
2. Masukkan bundle ID: `com.example.kosTerpadu`
   - Cek di `ios/Runner.xcodeproj/project.pbxproj`
3. Download `GoogleService-Info.plist`
4. Copy file ke `ios/Runner/GoogleService-Info.plist`

#### D. Enable Firebase Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "Test mode" (untuk development)
   - Choose location (asia-southeast2 untuk Indonesia)

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Start in "Test mode"

#### E. Firestore Security Rules (Development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Keluhan collection
    match /keluhan/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }
    
    // Chats collection
    match /chats/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      
      // Messages subcollection
      match /messages/{message} {
        allow read: if request.auth != null;
        allow create: if request.auth != null;
      }
    }
    
    // Notifications collection
    match /notifications/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

#### F. Storage Security Rules (Development)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### 4. Backend Setup (Express.js + PostgreSQL)

#### A. Create PostgreSQL Database

```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE kos_terpadu;

# Create user
CREATE USER kos_admin WITH PASSWORD 'your_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE kos_terpadu TO kos_admin;
```

#### B. Create Tables

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  nama VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  no_telepon VARCHAR(20),
  foto VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kamar table
CREATE TABLE kamar (
  id SERIAL PRIMARY KEY,
  nomor_kamar VARCHAR(50) UNIQUE NOT NULL,
  tipe VARCHAR(100) NOT NULL,
  harga DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL,
  deskripsi TEXT,
  fasilitas JSON,
  foto VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Penghuni table
CREATE TABLE penghuni (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  kamar_id INTEGER REFERENCES kamar(id) ON DELETE SET NULL,
  nama VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  no_telepon VARCHAR(20) NOT NULL,
  alamat_asal TEXT,
  pekerjaan VARCHAR(100),
  kontak_darurat VARCHAR(20),
  tanggal_masuk DATE NOT NULL,
  tanggal_keluar DATE,
  status VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tagihan table
CREATE TABLE tagihan (
  id SERIAL PRIMARY KEY,
  penghuni_id INTEGER REFERENCES penghuni(id) ON DELETE CASCADE,
  bulan VARCHAR(20) NOT NULL,
  tahun INTEGER NOT NULL,
  jumlah DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) NOT NULL,
  jatuh_tempo DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pembayaran table
CREATE TABLE pembayaran (
  id SERIAL PRIMARY KEY,
  tagihan_id INTEGER REFERENCES tagihan(id) ON DELETE CASCADE,
  penghuni_id INTEGER REFERENCES penghuni(id) ON DELETE CASCADE,
  jumlah DECIMAL(10, 2) NOT NULL,
  tanggal_bayar DATE NOT NULL,
  metode_pembayaran VARCHAR(100) NOT NULL,
  bukti_pembayaran VARCHAR(255),
  status VARCHAR(50) NOT NULL,
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_penghuni_user_id ON penghuni(user_id);
CREATE INDEX idx_penghuni_kamar_id ON penghuni(kamar_id);
CREATE INDEX idx_tagihan_penghuni_id ON tagihan(penghuni_id);
CREATE INDEX idx_pembayaran_penghuni_id ON pembayaran(penghuni_id);
```

#### C. Setup Express.js Backend

Create `backend/.env`:
```env
PORT=3000
DATABASE_URL=postgresql://kos_admin:your_password@localhost:5432/kos_terpadu
JWT_SECRET=your_jwt_secret_key_here
NODE_ENV=development
```

Install dependencies:
```bash
cd backend
npm install express pg bcrypt jsonwebtoken cors dotenv
npm install --save-dev nodemon
```

### 5. Configure Flutter App

#### A. Update API Base URL

Edit `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api', // Android emulator
  // defaultValue: 'http://localhost:3000/api', // iOS simulator
);
```

#### B. Run with Environment Variable

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api

# Production
flutter run --dart-define=API_BASE_URL=https://api.kosterpadu.com/api
```

### 6. Run Application

#### A. Start Backend Server

```bash
cd backend
npm run dev
```

Backend should run on `http://localhost:3000`

#### B. Start Flutter App

```bash
# Check devices
flutter devices

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Chrome (web)
flutter run -d chrome
```

### 7. Test Application

#### A. Create Admin User (via backend)

```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@kosterpadu.com",
    "password": "admin123",
    "nama": "Admin Kos",
    "no_telepon": "081234567890"
  }'

# Update role to admin in database
psql -U postgres -d kos_terpadu
UPDATE users SET role = 'admin' WHERE email = 'admin@kosterpadu.com';
```

#### B. Login to App

1. Open app
2. Login dengan:
   - Email: `admin@kosterpadu.com`
   - Password: `admin123`

#### C. Create Test Data

1. Create kamar
2. Create penghuni
3. Create keluhan
4. Test chat

## 🔧 Troubleshooting

### Flutter Doctor Issues

```bash
flutter doctor -v
```

Fix common issues:
- Android licenses: `flutter doctor --android-licenses`
- iOS setup: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

### Firebase Connection Issues

1. Check `google-services.json` location
2. Verify package name matches
3. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### API Connection Issues

1. Check backend is running
2. Check API URL in config
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For iOS simulator, use `localhost`
5. Check CORS settings in backend

### Database Connection Issues

1. Check PostgreSQL is running:
```bash
pg_isready
```

2. Check connection string in `.env`
3. Check user permissions

## 📱 Build for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

## 🔐 Security Checklist

Before deploying to production:

- [ ] Change Firebase rules to production mode
- [ ] Use HTTPS for API
- [ ] Change JWT secret
- [ ] Enable rate limiting
- [ ] Add input validation
- [ ] Enable error logging
- [ ] Add crash reporting
- [ ] Test authentication flow
- [ ] Test authorization
- [ ] Secure sensitive data

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Express.js Documentation](https://expressjs.com/)

## 💬 Support

Jika mengalami masalah, silakan:
1. Check dokumentasi
2. Search di Stack Overflow
3. Create issue di repository
4. Contact support team
