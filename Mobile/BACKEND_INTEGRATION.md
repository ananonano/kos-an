# Backend Integration Guide

## 📋 Overview

Dokumen ini menjelaskan cara integrasi Flutter app dengan backend Express.js + PostgreSQL yang sudah dibuat oleh tim backend.

## 🗄️ Database Schema

Backend menggunakan PostgreSQL dengan struktur tabel berikut:

### Tables

1. **users** - Data user (admin & tenant)
   - id (UUID)
   - name (VARCHAR)
   - email (VARCHAR, UNIQUE)
   - password (VARCHAR, hashed)
   - phone (VARCHAR)
   - role (VARCHAR: 'admin' | 'tenant')
   - avatar (TEXT)
   - created_at, updated_at

2. **rooms** - Data kamar kos
   - id (UUID)
   - room_number (VARCHAR, UNIQUE)
   - price (DECIMAL)
   - status (VARCHAR: 'available' | 'occupied' | 'maintenance')
   - description (TEXT)
   - facilities (TEXT[])
   - images (TEXT[])
   - created_at, updated_at

3. **tenants** - Data penghuni (relasi user-room)
   - id (UUID)
   - user_id (UUID, FK to users)
   - room_id (UUID, FK to rooms)
   - start_date (DATE)
   - end_date (DATE, nullable)
   - status (VARCHAR: 'active' | 'inactive')
   - created_at, updated_at

4. **bills** - Tagihan bulanan
   - id (UUID)
   - tenant_id (UUID, FK to tenants)
   - month (INTEGER, 1-12)
   - year (INTEGER)
   - amount (DECIMAL)
   - due_date (DATE)
   - status (VARCHAR: 'pending' | 'paid' | 'overdue')
   - created_at
   - UNIQUE(tenant_id, month, year)

5. **payments** - Pembayaran
   - id (UUID)
   - bill_id (UUID, FK to bills)
   - amount (DECIMAL)
   - proof_image (TEXT, URL/path)
   - status (VARCHAR: 'pending' | 'verified' | 'rejected')
   - payment_date (TIMESTAMP)
   - rejection_reason (TEXT, nullable)
   - created_at

6. **maintenance_reports** - Laporan kerusakan/keluhan
   - id (UUID)
   - tenant_id (UUID, FK to tenants)
   - title (VARCHAR)
   - description (TEXT)
   - status (VARCHAR: 'pending' | 'in_progress' | 'completed')
   - created_at, updated_at

7. **maintenance_progress** - Progress/update keluhan
   - id (UUID)
   - report_id (UUID, FK to maintenance_reports)
   - description (TEXT)
   - image (TEXT, URL/path)
   - created_at

8. **announcements** - Pengumuman
   - id (UUID)
   - title (VARCHAR)
   - content (TEXT)
   - created_at, updated_at

9. **notifications** - Notifikasi
   - id (UUID)
   - user_id (UUID, FK to users)
   - title (VARCHAR)
   - message (TEXT)
   - type (VARCHAR)
   - is_read (BOOLEAN)
   - created_at

## 🔗 API Endpoints (Expected)

### Authentication
```
POST   /api/auth/register       - Register user baru
POST   /api/auth/login          - Login
POST   /api/auth/logout         - Logout
GET    /api/auth/me             - Get current user
```

### Users
```
GET    /api/users               - Get all users (admin only)
GET    /api/users/:id           - Get user by ID
PUT    /api/users/:id           - Update user
DELETE /api/users/:id           - Delete user (admin only)
```

### Rooms
```
GET    /api/rooms               - Get all rooms
GET    /api/rooms/:id           - Get room by ID
POST   /api/rooms               - Create room (admin only)
PUT    /api/rooms/:id           - Update room (admin only)
DELETE /api/rooms/:id           - Delete room (admin only)
```

### Tenants
```
GET    /api/tenants             - Get all tenants
GET    /api/tenants/:id         - Get tenant by ID
POST   /api/tenants             - Create tenant (admin only)
PUT    /api/tenants/:id         - Update tenant (admin only)
DELETE /api/tenants/:id         - Delete tenant (admin only)
GET    /api/tenants/user/:userId - Get tenant by user ID
```

### Bills
```
GET    /api/bills               - Get all bills
GET    /api/bills/:id           - Get bill by ID
POST   /api/bills               - Create bill (admin only)
PUT    /api/bills/:id           - Update bill (admin only)
DELETE /api/bills/:id           - Delete bill (admin only)
GET    /api/bills/tenant/:tenantId - Get bills by tenant
```

### Payments
```
GET    /api/payments            - Get all payments
GET    /api/payments/:id        - Get payment by ID
POST   /api/payments            - Create payment (upload bukti)
PUT    /api/payments/:id        - Update payment status (admin: verify/reject)
GET    /api/payments/bill/:billId - Get payments by bill
```

### Maintenance Reports
```
GET    /api/maintenance         - Get all reports
GET    /api/maintenance/:id     - Get report by ID
POST   /api/maintenance         - Create report (tenant)
PUT    /api/maintenance/:id     - Update report status (admin)
DELETE /api/maintenance/:id     - Delete report
POST   /api/maintenance/:id/progress - Add progress update (admin)
```

### Announcements
```
GET    /api/announcements       - Get all announcements
GET    /api/announcements/:id   - Get announcement by ID
POST   /api/announcements       - Create announcement (admin only)
PUT    /api/announcements/:id   - Update announcement (admin only)
DELETE /api/announcements/:id   - Delete announcement (admin only)
```

### Notifications
```
GET    /api/notifications       - Get user notifications
PUT    /api/notifications/:id/read - Mark as read
DELETE /api/notifications/:id   - Delete notification
```

## 📱 Flutter Models

Semua models sudah disesuaikan dengan backend schema:

- ✅ `UserModel` - Mapping ke tabel `users`
- ✅ `KamarModel` - Mapping ke tabel `rooms`
- ✅ `PenghuniModel` - Mapping ke tabel `tenants`
- ✅ `BillModel` - Mapping ke tabel `bills`
- ✅ `PembayaranModel` - Mapping ke tabel `payments`
- ✅ `MaintenanceModel` - Mapping ke tabel `maintenance_reports`
- ✅ `MaintenanceProgress` - Mapping ke tabel `maintenance_progress`
- ✅ `AnnouncementModel` - Mapping ke tabel `announcements`
- ✅ `NotificationModel` - Mapping ke tabel `notifications`

## 🔧 Setup Integration

### 1. Update API Base URL

Edit file `lib/core/config/app_config.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api', // Ganti dengan URL backend
);
```

Atau jalankan dengan environment variable:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000/api
```

### 2. Tanya Backend Developer

Konfirmasi dengan tim backend tentang:

1. **Base URL** - Apa URL backend? (localhost:3000, IP address, domain)
2. **Authentication** - Pakai JWT? Token di header atau cookie?
3. **Response Format** - Format response API:
   ```json
   {
     "success": true,
     "data": {...},
     "message": "Success"
   }
   ```
   atau langsung return data?

4. **Error Format** - Format error response:
   ```json
   {
     "success": false,
     "error": "Error message"
   }
   ```

5. **File Upload** - Endpoint untuk upload gambar? Multipart form-data?
6. **Pagination** - Format pagination? Query params? (page, limit, offset)

### 3. Update Services

Setelah dapat info dari backend, update services di `lib/services/`:

- `auth_service.dart` - Sesuaikan dengan auth flow backend
- `kamar_service.dart` - Update endpoint ke `/rooms`
- Buat service baru untuk bills, payments, maintenance, dll

### 4. Test Connection

Buat simple test untuk cek koneksi:

```dart
// Test di main.dart atau buat file test tersendiri
void testBackendConnection() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/health'), // Health check endpoint
    );
    print('Backend Status: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('Error connecting to backend: $e');
  }
}
```

## 🔐 Authentication Flow

### Expected Flow:

1. **Login**
   ```
   POST /api/auth/login
   Body: { "email": "user@test.com", "password": "password123" }
   Response: { "token": "jwt_token", "user": {...} }
   ```

2. **Store Token**
   - Simpan token di SharedPreferences atau Secure Storage
   - Include token di setiap request: `Authorization: Bearer <token>`

3. **Auto Login**
   - Check token saat app start
   - Jika ada token, call `/api/auth/me` untuk verify & get user data

4. **Logout**
   - Clear token dari storage
   - Optional: Call `/api/auth/logout` jika backend track sessions

## 📝 Next Steps

1. ✅ Models sudah disesuaikan dengan backend schema
2. ⏳ Tunggu konfirmasi dari backend developer tentang:
   - Base URL
   - Authentication method
   - Response format
   - Endpoints yang sudah ready
3. ⏳ Update services sesuai dengan API backend
4. ⏳ Test integration
5. ⏳ Handle edge cases & error handling

## 🤝 Koordinasi dengan Backend

**Yang perlu ditanyakan ke backend developer:**

1. Apakah backend sudah running? Di port berapa?
2. Apakah semua endpoints sudah ready atau masih WIP?
3. Bisa share Postman collection atau API documentation?
4. Format authentication? JWT di header?
5. Untuk upload file (bukti bayar, foto keluhan), pakai endpoint apa?
6. Apakah ada CORS issue? (jika test di web)

## 📞 Contact

Koordinasi dengan backend developer untuk memastikan integrasi berjalan lancar!
