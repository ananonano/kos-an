# 🚀 KosTerpadu - Quick Start Guide

Panduan cepat untuk memulai development project KosTerpadu untuk semua anggota tim.

---

## 📋 Prerequisites

### Semua Tim Harus Install:
- ✅ Git
- ✅ VS Code (atau IDE favorit)
- ✅ Node.js 18+ & npm
- ✅ PostgreSQL 14+
- ✅ Firebase Account

### Backend Developer:
- ✅ Postman / Thunder Client (API testing)
- ✅ pgAdmin / DBeaver (database management)
- ✅ Docker Desktop (optional, untuk deployment)

### Web Frontend Developer:
- ✅ Chrome / Firefox (latest)
- ✅ React DevTools extension

### Mobile Developer:
- ✅ Flutter SDK 3.0+
- ✅ Android Studio / VS Code + Flutter extension
- ✅ Android Emulator / Physical Device

---

## 🏁 Getting Started

### 1. Clone Repository

```bash
git clone <repository-url>
cd ProyekPrakTCC
```

### 2. Project Structure

```
ProyekPrakTCC/
├── Backend/              # Backend API (belum ada kode, ada di Web/kos-terpadu-backend)
├── Mobile/               # Flutter app (SUDAH LENGKAP)
├── Web/
│   ├── kos-terpadu-backend/    # Express.js API (SUDAH ADA STRUKTUR)
│   └── kos-terpadu-admin/      # Next.js admin (SUDAH ADA SETUP)
├── ARCHITECTURE.md       # System architecture
├── PROJECT_ROADMAP.md    # Development roadmap
└── QUICK_START.md        # This file
```

---

## 🔧 Setup Backend (Express.js)

### 1. Navigate to Backend

```bash
cd Web/kos-terpadu-backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Environment Variables

```bash
cp .env.example .env
```

Edit `.env`:

```env
# Server
PORT=5000
NODE_ENV=development

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kos_terpadu
DB_USER=postgres
DB_PASSWORD=your_password_here

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this
JWT_EXPIRES_IN=7d

# Firebase (get from Firebase Console)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your_project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com

# CORS
CORS_ORIGIN=http://localhost:3000
```

### 4. Create Database

```bash
# Windows (Command Prompt)
createdb -U postgres kos_terpadu

# Or using psql
psql -U postgres
CREATE DATABASE kos_terpadu;
\q
```

### 5. Run Migration

```bash
npm run db:migrate
```

Output:
```
🚀 Starting database migration...
📋 Creating users table...
✅ Users table created
📋 Creating rooms table...
✅ Rooms table created
...
✅ Migration completed successfully!
```

### 6. Seed Database (Optional)

```bash
npm run db:seed
```

Output:
```
🌱 Starting database seeding...
👤 Seeding users...
✅ 5 users seeded
🏠 Seeding rooms...
✅ 8 rooms seeded
...
🔑 Login Credentials:
   Admin: admin@kosterpadu.com / admin123
   Tenant: budi@email.com / tenant123
```

### 7. Run Development Server

```bash
npm run dev
```

Output:
```
KosTerpadu Backend API running on port 5000
```

### 8. Test API

Open browser: `http://localhost:5000/health`

Response:
```json
{
  "success": true,
  "message": "KosTerpadu API is running",
  "version": "1.0.0",
  "database": "connected",
  "timestamp": "2024-..."
}
```

### 9. Test Login

Using Postman/Thunder Client:

```
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "admin@kosterpadu.com",
  "password": "admin123"
}
```

Response:
```json
{
  "success": true,
  "message": "Login berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "admin@kosterpadu.com",
    "nama": "Admin Kos Terpadu",
    "role": "admin"
  }
}
```

---

## 🌐 Setup Web Frontend (Next.js)

### 1. Navigate to Web

```bash
cd Web/kos-terpadu-admin
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

### 4. Run Development Server

```bash
npm run dev
```

Output:
```
▲ Next.js 16.2.6
- Local:        http://localhost:3000
- Ready in 2.5s
```

### 5. Open Browser

Navigate to: `http://localhost:3000`

---

## 📱 Setup Mobile (Flutter)

### 1. Navigate to Mobile

```bash
cd Mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Firebase

1. Download `google-services.json` from Firebase Console
2. Place in `android/app/google-services.json`

For iOS (optional):
1. Download `GoogleService-Info.plist`
2. Place in `ios/Runner/GoogleService-Info.plist`

### 4. Configure API URL

Edit `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Development
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  // static const String apiBaseUrl = 'http://localhost:5000/api'; // iOS Simulator
  
  // Production
  // static const String apiBaseUrl = 'https://your-backend-url.com/api';
}
```

### 5. Run App

```bash
# Check connected devices
flutter devices

# Run on Android Emulator
flutter run

# Or run on specific device
flutter run -d <device-id>
```

### 6. Test Login

Use credentials:
- Email: `budi@email.com`
- Password: `tenant123`

---

## 🔥 Setup Firebase

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `kos-terpadu`
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Firestore

1. Go to "Firestore Database"
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose location: `asia-southeast1`

### 3. Enable Storage

1. Go to "Storage"
2. Click "Get started"
3. Start in **test mode**
4. Done

### 4. Get Firebase Config

#### For Web & Backend:

1. Go to Project Settings
2. Click "Service accounts"
3. Click "Generate new private key"
4. Save JSON file
5. Copy values to `.env`

#### For Mobile:

1. Go to Project Settings
2. Add Android app
3. Package name: `com.example.kos_terpadu`
4. Download `google-services.json`
5. Place in `android/app/`

### 5. Firestore Security Rules (Development)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for development
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ IMPORTANT:** Change to proper rules for production!

### 6. Storage Security Rules (Development)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ IMPORTANT:** Change to proper rules for production!

---

## 🧪 Testing

### Backend API Testing

1. **Using Postman:**
   - Import collection (if available)
   - Or manually test endpoints

2. **Test Endpoints:**

```bash
# Health Check
GET http://localhost:5000/health

# Login
POST http://localhost:5000/api/auth/login
Body: { "email": "admin@kosterpadu.com", "password": "admin123" }

# Get Rooms (no auth required)
GET http://localhost:5000/api/rooms

# Get Dashboard Stats (requires auth)
GET http://localhost:5000/api/dashboard/stats
Headers: Authorization: Bearer <your-token>
```

### Web Frontend Testing

1. Open `http://localhost:3000`
2. Test login page
3. Test navigation
4. Test CRUD operations

### Mobile Testing

1. Run app on emulator
2. Test login
3. Test navigation
4. Test features

---

## 🐛 Troubleshooting

### Backend Issues

**Problem:** Database connection error

```bash
# Check PostgreSQL is running
pg_isready

# Check if database exists
psql -U postgres -l | grep kos_terpadu

# Recreate database
dropdb -U postgres kos_terpadu
createdb -U postgres kos_terpadu
npm run db:migrate
```

**Problem:** Port 5000 already in use

```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:5000 | xargs kill -9
```

**Problem:** Migration failed

```bash
# Check error message
# Usually it's because:
# 1. Database doesn't exist
# 2. Wrong credentials in .env
# 3. PostgreSQL not running

# Solution: Check .env and recreate database
```

### Web Frontend Issues

**Problem:** API connection error

```
# Check if backend is running
curl http://localhost:5000/health

# Check NEXT_PUBLIC_API_URL in .env.local
# Make sure it's http://localhost:5000/api
```

**Problem:** Module not found

```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Mobile Issues

**Problem:** Flutter pub get fails

```bash
# Clear cache
flutter clean
flutter pub get
```

**Problem:** Android build fails

```bash
# Check Android SDK is installed
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Problem:** API connection fails

```
# For Android Emulator, use 10.0.2.2 instead of localhost
# For iOS Simulator, use localhost
# For Physical Device, use your computer's IP address
```

### Firebase Issues

**Problem:** Firebase not initialized

```
# Check google-services.json is in correct location
# Check Firebase config in .env
# Check Firebase project is created
```

**Problem:** Firestore permission denied

```
# Check Firestore rules
# For development, use test mode
# For production, implement proper rules
```

---

## 📚 Next Steps

### Backend Developer:
1. ✅ Complete auth controller
2. ✅ Complete room controller
3. ✅ Complete tenant controller
4. ✅ Add input validation
5. ✅ Test all endpoints

### Web Frontend Developer:
1. ✅ Build login page
2. ✅ Build dashboard
3. ✅ Build room management
4. ✅ Build tenant management
5. ✅ Integrate with backend API

### Mobile Developer:
1. ✅ Test existing features
2. ✅ Fix bugs if any
3. ✅ Implement payment upload
4. ✅ Implement maintenance request
5. ✅ Test realtime features

### DevOps:
1. ✅ Setup Cloud SQL
2. ✅ Setup Firebase
3. ✅ Deploy backend to Cloud Run
4. ✅ Deploy web to App Engine
5. ✅ Setup CI/CD

---

## 📞 Support

### Documentation:
- `ARCHITECTURE.md` - System architecture
- `PROJECT_ROADMAP.md` - Development roadmap
- `Backend/README.md` - Backend documentation
- `Mobile/README.md` - Mobile documentation

### Resources:
- Express.js: https://expressjs.com/
- Next.js: https://nextjs.org/
- Flutter: https://flutter.dev/
- Firebase: https://firebase.google.com/
- Google Cloud: https://cloud.google.com/

### Team Communication:
- Daily standup (optional)
- Weekly sync (recommended)
- WhatsApp/Telegram for quick questions
- GitHub for code collaboration

---

## ✅ Checklist

### Backend Setup:
- [ ] Node.js installed
- [ ] PostgreSQL installed
- [ ] Dependencies installed (`npm install`)
- [ ] `.env` configured
- [ ] Database created
- [ ] Migration run successfully
- [ ] Seed data loaded
- [ ] Server running on port 5000
- [ ] Health check returns success
- [ ] Login endpoint working

### Web Frontend Setup:
- [ ] Node.js installed
- [ ] Dependencies installed (`npm install`)
- [ ] `.env.local` configured
- [ ] Server running on port 3000
- [ ] Can access login page
- [ ] Can connect to backend API

### Mobile Setup:
- [ ] Flutter SDK installed
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase configured
- [ ] `google-services.json` added
- [ ] API URL configured
- [ ] App runs on emulator
- [ ] Can login successfully

### Firebase Setup:
- [ ] Firebase project created
- [ ] Firestore enabled
- [ ] Storage enabled
- [ ] Service account key downloaded
- [ ] Security rules configured (test mode)
- [ ] Mobile app registered

---

**Ready to code? Let's build! 🚀**

**Questions?** Check documentation or ask your team lead.
