# 🤝 Koordinasi Mobile & Backend - Kos Terpadu

## 📱 Status Mobile App

✅ **Flutter app sudah siap untuk integrasi!**

### Yang Sudah Dibuat:
1. ✅ Semua models sesuai database schema backend
2. ✅ UI screens untuk semua fitur
3. ✅ Architecture MVC + Service Layer
4. ✅ State management dengan Provider
5. ✅ Firebase setup (Auth & Firestore untuk chat)
6. ✅ HTTP service wrapper untuk API calls

## 🗄️ Database Schema Match

Mobile models sudah 100% match dengan backend database:

| Backend Table | Flutter Model | Status |
|--------------|---------------|--------|
| users | UserModel | ✅ Match |
| rooms | KamarModel | ✅ Match |
| tenants | PenghuniModel | ✅ Match |
| bills | BillModel | ✅ Match |
| payments | PembayaranModel | ✅ Match |
| maintenance_reports | MaintenanceModel | ✅ Match |
| maintenance_progress | MaintenanceProgress | ✅ Match |
| announcements | AnnouncementModel | ✅ Match |
| notifications | NotificationModel | ✅ Match |

## 🔗 Yang Perlu dari Backend Developer

### 1. Backend URL
```
Tolong kasih tau backend running di mana:
- localhost:3000?
- IP address berapa?
- Atau sudah deploy ke server?

Contoh:
- http://localhost:3000/api
- http://192.168.1.100:3000/api
- https://api.kosterpadu.com
```

### 2. API Documentation
```
Bisa share:
- Postman collection?
- Swagger/OpenAPI docs?
- Atau list endpoints manual?

Yang penting tau:
- Endpoint apa aja yang udah ready
- Request body format
- Response format
- Authentication method
```

### 3. Authentication
```
Pakai JWT token kan?

Tolong konfirmasi:
1. Login endpoint: POST /api/auth/login
   Request: { "email": "...", "password": "..." }
   Response: { "token": "...", "user": {...} } ?

2. Token dikirim via header:
   Authorization: Bearer <token> ?

3. Ada endpoint untuk verify token?
   GET /api/auth/me ?
```

### 4. Test Credentials
```
Bisa kasih test account untuk testing?

Admin:
- Email: admin@test.com
- Password: admin123

Tenant:
- Email: tenant@test.com
- Password: tenant123
```

### 5. File Upload
```
Untuk upload gambar (bukti bayar, foto keluhan):

1. Endpoint: POST /api/upload ?
2. Format: multipart/form-data ?
3. Response: { "url": "..." } ?
4. Max size: berapa MB?
```

## 📋 Checklist Koordinasi

### Dari Backend Developer:
- [ ] Backend URL & port
- [ ] API documentation atau Postman collection
- [ ] Test credentials (admin & tenant)
- [ ] Konfirmasi authentication method
- [ ] Konfirmasi response format
- [ ] Endpoint file upload
- [ ] List endpoints yang sudah ready

### Dari Mobile Developer (Kamu):
- [x] Models sudah disesuaikan
- [x] Dokumentasi integrasi sudah dibuat
- [ ] Update API base URL setelah dapat dari backend
- [ ] Test koneksi ke backend
- [ ] Implement API calls di services
- [ ] Test end-to-end flow

## 🚀 Langkah Integrasi

### Step 1: Setup Connection
1. Backend developer kasih URL
2. Update `lib/core/config/app_config.dart`:
   ```dart
   static const String apiBaseUrl = 'http://BACKEND_URL:PORT/api';
   ```
3. Test koneksi dengan simple GET request

### Step 2: Authentication
1. Implement login flow
2. Store JWT token
3. Test protected endpoints dengan token

### Step 3: Core Features
1. Test CRUD rooms
2. Test CRUD tenants
3. Test bills & payments
4. Test maintenance reports

### Step 4: Testing
1. Test semua fitur
2. Handle error cases
3. Fix bugs
4. Polish UI/UX

## 📞 Komunikasi

**Cara paling efektif:**
1. Share Postman collection atau API docs
2. Test bareng via screen share
3. Buat group chat untuk quick questions
4. Document semua changes

## 🐛 Troubleshooting

### Jika koneksi gagal:
```
1. Cek backend running atau tidak
2. Cek URL & port sudah benar
3. Cek CORS settings (jika test di web)
4. Cek firewall/network
5. Test dengan Postman dulu
```

### Jika response error:
```
1. Cek format request body
2. Cek headers (Content-Type, Authorization)
3. Cek response format dari backend
4. Print/log request & response untuk debug
```

## 📚 Dokumentasi

Sudah dibuat dokumentasi lengkap:
- ✅ `BACKEND_INTEGRATION.md` - Guide integrasi detail
- ✅ `INTEGRATION_CHECKLIST.md` - Checklist progress
- ✅ `API_DOCUMENTATION.md` - Expected API format
- ✅ `ARCHITECTURE.md` - Arsitektur aplikasi
- ✅ `SETUP_GUIDE.md` - Setup guide

## 💬 Template Pertanyaan untuk Backend

**Copy paste ini ke backend developer:**

---

Halo! Mobile app udah siap untuk integrasi. Butuh info berikut:

1. **Backend URL**: Backend running di mana? (localhost:3000, IP, atau domain)

2. **API Docs**: Ada Postman collection atau API documentation?

3. **Authentication**: 
   - Login endpoint & format?
   - JWT token di header Authorization: Bearer <token>?
   - Endpoint untuk verify token?

4. **Test Account**:
   - Admin: email & password?
   - Tenant: email & password?

5. **Response Format**: 
   - Success: `{ "data": {...} }` atau format lain?
   - Error: `{ "error": "message" }` atau format lain?

6. **File Upload**:
   - Endpoint untuk upload gambar?
   - Format multipart/form-data?
   - Max file size?

7. **Endpoints Ready**: Endpoint mana aja yang udah bisa dipake?

Thanks! 🙏

---

## ✅ Next Steps

1. **Kirim template pertanyaan di atas ke backend developer**
2. **Tunggu response & info yang dibutuhkan**
3. **Update app config dengan backend URL**
4. **Mulai testing integrasi**
5. **Report bugs & issues**
6. **Iterate sampai semua work**

---

**Good luck with the integration!** 🚀
