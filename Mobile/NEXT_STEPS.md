# 🎯 Next Steps - Kos Terpadu Mobile App

## ✅ Yang Sudah Selesai

### 1. Flutter App Structure
- ✅ Complete MVC + Service Layer architecture
- ✅ Provider state management setup
- ✅ All UI screens (Splash, Auth, Home, Kamar, Penghuni, Pembayaran, Keluhan, Chat)
- ✅ Custom widgets (Button, TextField, Cards)
- ✅ Routing setup
- ✅ Theme configuration

### 2. Models Updated
- ✅ UserModel - match dengan tabel `users` (name, phone, avatar)
- ✅ KamarModel - match dengan tabel `rooms` (room_number, price, images array)
- ✅ PenghuniModel - match dengan tabel `tenants` (simplified)
- ✅ BillModel - NEW, sesuai tabel `bills`
- ✅ PembayaranModel - updated sesuai tabel `payments`
- ✅ MaintenanceModel - NEW, sesuai tabel `maintenance_reports`
- ✅ MaintenanceProgress - NEW, sesuai tabel `maintenance_progress`
- ✅ AnnouncementModel - NEW, sesuai tabel `announcements`
- ✅ NotificationModel - NEW, sesuai tabel `notifications`

### 3. Firebase Setup
- ✅ Firebase project created
- ✅ Android app registered (com.kosterpadu.kos_terpadu)
- ✅ Firebase Authentication enabled (Email/Password)
- ✅ Cloud Firestore enabled (asia-southeast2)
- ✅ google-services.json configured
- ⏸️ Firebase Storage skipped (billing requirement)

### 4. Documentation
- ✅ README.md - Project overview
- ✅ ARCHITECTURE.md - Architecture explanation
- ✅ SETUP_GUIDE.md - Setup instructions
- ✅ API_DOCUMENTATION.md - API specs
- ✅ ERD_DIAGRAM.md - Database schema
- ✅ BACKEND_INTEGRATION.md - Integration guide
- ✅ INTEGRATION_CHECKLIST.md - Progress checklist
- ✅ KOORDINASI_BACKEND.md - Coordination guide

## 🎯 Yang Harus Dilakukan Sekarang

### Step 1: Koordinasi dengan Backend Developer ⭐ PRIORITAS

**Action:** Kirim pertanyaan ke temen lu yang buat backend

**Template pertanyaan** (ada di `KOORDINASI_BACKEND.md`):

```
Halo! Mobile app udah siap untuk integrasi. Butuh info berikut:

1. Backend URL: Backend running di mana? (localhost:3000, IP, atau domain)
2. API Docs: Ada Postman collection atau API documentation?
3. Authentication: Login endpoint & format? JWT token?
4. Test Account: Admin & tenant credentials?
5. Response Format: Success & error format?
6. File Upload: Endpoint & format?
7. Endpoints Ready: Endpoint mana aja yang udah bisa dipake?
```

**Yang perlu didapat:**
- ✅ Backend URL (contoh: http://192.168.1.100:3000/api)
- ✅ Test credentials (admin & tenant)
- ✅ API documentation atau Postman collection
- ✅ Authentication method confirmation
- ✅ Response format confirmation

### Step 2: Update App Configuration

Setelah dapat info dari backend:

**File:** `lib/core/config/app_config.dart`

```dart
// Ganti ini:
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api', // ← GANTI INI
);
```

**Dengan URL yang dikasih backend developer:**
```dart
defaultValue: 'http://192.168.1.100:3000/api', // Contoh
```

### Step 3: Test Backend Connection

**Buat file test:** `lib/test_backend.dart`

```dart
import 'package:http/http.dart' as http;
import 'core/config/app_config.dart';

void main() async {
  print('Testing backend connection...');
  print('URL: ${AppConfig.baseUrl}');
  
  try {
    // Test 1: Health check (jika ada)
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/health'),
    );
    print('Health check: ${response.statusCode}');
    print('Response: ${response.body}');
    
    // Test 2: Login
    final loginResponse = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: '{"email":"admin@test.com","password":"admin123"}',
    );
    print('Login: ${loginResponse.statusCode}');
    print('Response: ${loginResponse.body}');
    
  } catch (e) {
    print('Error: $e');
  }
}
```

**Run test:**
```bash
dart lib/test_backend.dart
```

### Step 4: Update Services

Setelah test connection berhasil, update services:

**Files to update:**
1. `lib/services/auth_service.dart` - Update login/register logic
2. `lib/services/kamar_service.dart` - Update endpoint ke `/rooms`
3. Create new services:
   - `lib/services/bill_service.dart`
   - `lib/services/payment_service.dart`
   - `lib/services/maintenance_service.dart`
   - `lib/services/announcement_service.dart`

### Step 5: Test Features One by One

**Testing order:**
1. ✅ Authentication (login, register, logout)
2. ✅ Get rooms list
3. ✅ Get room detail
4. ✅ Get tenants (admin)
5. ✅ Get bills (tenant)
6. ✅ Upload payment proof
7. ✅ Create maintenance report
8. ✅ Get announcements
9. ✅ Get notifications

### Step 6: Handle Errors & Edge Cases

- ✅ Network timeout
- ✅ Invalid credentials
- ✅ Token expiration
- ✅ Server errors (500)
- ✅ Validation errors (400)
- ✅ Not found (404)

### Step 7: Polish & Deploy

- ✅ Fix UI bugs
- ✅ Add loading states
- ✅ Add error messages
- ✅ Test on real device
- ✅ Build APK
- ✅ Deploy

## 📁 File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          ← UPDATE INI dengan backend URL
│   ├── constants/
│   ├── services/
│   │   └── http_service.dart
│   ├── theme/
│   └── utils/
├── models/
│   ├── user_model.dart              ✅ Updated
│   ├── kamar_model.dart             ✅ Updated
│   ├── penghuni_model.dart          ✅ Updated
│   ├── bill_model.dart              ✅ NEW
│   ├── pembayaran_model.dart        ✅ Updated
│   ├── maintenance_model.dart       ✅ NEW
│   ├── announcement_model.dart      ✅ NEW
│   └── notification_model.dart      ✅ NEW
├── services/
│   ├── auth_service.dart            ⏳ Need update
│   ├── kamar_service.dart           ⏳ Need update
│   └── ...                          ⏳ Need to create
├── controllers/
├── views/
├── widgets/
├── routes/
└── main.dart
```

## 🔧 Quick Commands

### Run app:
```bash
flutter run
```

### Run with custom API URL:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

### Build APK:
```bash
flutter build apk --release
```

### Check for errors:
```bash
flutter analyze
```

## 📚 Documentation Files

Baca dokumentasi ini untuk referensi:

1. **KOORDINASI_BACKEND.md** ⭐ BACA INI DULU
   - Template pertanyaan untuk backend
   - Checklist koordinasi
   - Troubleshooting tips

2. **BACKEND_INTEGRATION.md**
   - Detail database schema
   - Expected API endpoints
   - Integration guide

3. **INTEGRATION_CHECKLIST.md**
   - Progress tracking
   - Testing checklist
   - Known issues

4. **SETUP_GUIDE.md**
   - Setup instructions
   - Firebase configuration
   - Running the app

## ⚠️ Important Notes

1. **Backend URL**: Pastikan backend running dan accessible dari device/emulator
2. **CORS**: Jika test di web, backend harus enable CORS
3. **Network**: Jika test di real device, pastikan device & backend di network yang sama
4. **Firebase**: Chat & keluhan realtime pakai Firestore (sudah setup)
5. **Storage**: Firebase Storage belum enable (skip dulu, bisa pakai backend untuk upload)

## 🎯 Priority Order

### High Priority (Harus sekarang):
1. ⭐ Koordinasi dengan backend developer
2. ⭐ Dapat backend URL & test credentials
3. ⭐ Update app_config.dart
4. ⭐ Test connection

### Medium Priority (Setelah connection OK):
1. Update auth_service.dart
2. Test login flow
3. Update kamar_service.dart
4. Test get rooms

### Low Priority (Polish):
1. Error handling
2. Loading states
3. UI improvements
4. Testing edge cases

## 💡 Tips

1. **Test dengan Postman dulu** - Sebelum implement di Flutter, test API dengan Postman
2. **Print/Log everything** - Saat development, print request & response untuk debug
3. **Start simple** - Test login dulu, baru fitur lain
4. **Communicate often** - Sering koordinasi dengan backend developer
5. **Document issues** - Catat semua bugs & issues yang ditemukan

## 📞 Need Help?

Jika ada masalah:
1. Check dokumentasi di folder project
2. Test API dengan Postman
3. Check backend logs
4. Koordinasi dengan backend developer
5. Google error messages
6. Check Flutter/Dart documentation

## ✅ Success Criteria

App dianggap berhasil jika:
- ✅ Login berhasil dengan credentials dari backend
- ✅ Bisa get & display data rooms
- ✅ Bisa get & display data bills (tenant)
- ✅ Bisa upload payment proof
- ✅ Bisa create maintenance report
- ✅ Chat realtime works (Firebase)
- ✅ No critical bugs

---

## 🚀 Let's Go!

**Next action:** Kirim pertanyaan ke backend developer pakai template di `KOORDINASI_BACKEND.md`

**Good luck!** 💪
