# 📋 Integration Checklist - Flutter Mobile & Backend

## Status: 🟡 Ready for Integration

## ✅ Yang Sudah Selesai (Mobile Side)

### Models
- [x] UserModel - sesuai tabel `users`
- [x] KamarModel (RoomModel) - sesuai tabel `rooms`
- [x] PenghuniModel (TenantModel) - sesuai tabel `tenants`
- [x] BillModel - sesuai tabel `bills`
- [x] PembayaranModel (PaymentModel) - sesuai tabel `payments`
- [x] MaintenanceModel - sesuai tabel `maintenance_reports`
- [x] MaintenanceProgress - sesuai tabel `maintenance_progress`
- [x] AnnouncementModel - sesuai tabel `announcements`
- [x] NotificationModel - sesuai tabel `notifications`

### UI Components
- [x] Splash Screen
- [x] Login Screen
- [x] Register Screen
- [x] Home Screen (Admin & Tenant)
- [x] Kamar List & Detail
- [x] Penghuni List & Detail
- [x] Pembayaran List & Upload
- [x] Keluhan List & Create
- [x] Chat Screen (Firebase Firestore)
- [x] Custom Widgets (Button, TextField, Cards)

### Architecture
- [x] MVC + Service Layer pattern
- [x] Provider for state management
- [x] HTTP Service wrapper
- [x] Firebase integration (Auth, Firestore)
- [x] Routing setup

## ⏳ Yang Perlu Dikonfirmasi dengan Backend

### 1. Backend URL & Environment
```
❓ Backend running di mana?
   [ ] localhost:3000
   [ ] IP Address: _________________
   [ ] Domain: _____________________

❓ Apakah backend sudah running dan bisa diakses?
   [ ] Yes
   [ ] No - masih development
```

### 2. Authentication
```
❓ Authentication method?
   [ ] JWT Token
   [ ] Session Cookie
   [ ] Other: _____________________

❓ Token dikirim via?
   [ ] Authorization: Bearer <token>
   [ ] Cookie
   [ ] Custom header: _____________

❓ Endpoint authentication:
   [ ] POST /api/auth/login
   [ ] POST /api/auth/register
   [ ] GET /api/auth/me
   [ ] POST /api/auth/logout
```

### 3. API Response Format
```
❓ Format response sukses:
   [ ] { "success": true, "data": {...} }
   [ ] { "data": {...} }
   [ ] Langsung return data {...}
   [ ] Other: _____________________

❓ Format response error:
   [ ] { "success": false, "error": "message" }
   [ ] { "error": "message" }
   [ ] { "message": "error" }
   [ ] Other: _____________________

❓ HTTP Status codes yang dipakai:
   [ ] 200 - Success
   [ ] 201 - Created
   [ ] 400 - Bad Request
   [ ] 401 - Unauthorized
   [ ] 403 - Forbidden
   [ ] 404 - Not Found
   [ ] 500 - Server Error
```

### 4. Endpoints Status
```
Cek endpoint mana yang sudah ready:

Authentication:
[ ] POST /api/auth/register
[ ] POST /api/auth/login
[ ] POST /api/auth/logout
[ ] GET /api/auth/me

Users:
[ ] GET /api/users
[ ] GET /api/users/:id
[ ] PUT /api/users/:id

Rooms:
[ ] GET /api/rooms
[ ] GET /api/rooms/:id
[ ] POST /api/rooms
[ ] PUT /api/rooms/:id
[ ] DELETE /api/rooms/:id

Tenants:
[ ] GET /api/tenants
[ ] GET /api/tenants/:id
[ ] POST /api/tenants
[ ] PUT /api/tenants/:id
[ ] GET /api/tenants/user/:userId

Bills:
[ ] GET /api/bills
[ ] GET /api/bills/:id
[ ] POST /api/bills
[ ] GET /api/bills/tenant/:tenantId

Payments:
[ ] GET /api/payments
[ ] GET /api/payments/:id
[ ] POST /api/payments
[ ] PUT /api/payments/:id (verify/reject)

Maintenance:
[ ] GET /api/maintenance
[ ] GET /api/maintenance/:id
[ ] POST /api/maintenance
[ ] PUT /api/maintenance/:id
[ ] POST /api/maintenance/:id/progress

Announcements:
[ ] GET /api/announcements
[ ] POST /api/announcements

Notifications:
[ ] GET /api/notifications
[ ] PUT /api/notifications/:id/read
```

### 5. File Upload
```
❓ Endpoint untuk upload gambar?
   [ ] POST /api/upload
   [ ] Included dalam POST request (multipart)
   [ ] Other: _____________________

❓ Format upload:
   [ ] multipart/form-data
   [ ] base64 string
   [ ] Other: _____________________

❓ Response setelah upload:
   [ ] { "url": "http://..." }
   [ ] { "path": "/uploads/..." }
   [ ] { "filename": "..." }
   [ ] Other: _____________________

❓ Max file size: _________ MB

❓ Allowed file types:
   [ ] jpg, jpeg, png
   [ ] pdf
   [ ] Other: _____________________
```

### 6. Pagination
```
❓ Apakah API support pagination?
   [ ] Yes
   [ ] No

❓ Format pagination:
   [ ] Query params: ?page=1&limit=20
   [ ] Query params: ?offset=0&limit=20
   [ ] Other: _____________________

❓ Response pagination:
   [ ] { "data": [...], "total": 100, "page": 1 }
   [ ] { "data": [...], "meta": { "total": 100 } }
   [ ] Other: _____________________
```

### 7. CORS & Security
```
❓ Apakah CORS sudah di-setup untuk Flutter web?
   [ ] Yes
   [ ] No - mobile only
   [ ] Not sure

❓ Allowed origins:
   [ ] * (all)
   [ ] Specific domains: ___________
```

## 🔧 Action Items

### Mobile Developer (Kamu)
- [x] Update models sesuai backend schema
- [x] Buat dokumentasi integrasi
- [ ] Update `app_config.dart` dengan backend URL yang benar
- [ ] Update services sesuai API endpoints
- [ ] Test koneksi ke backend
- [ ] Handle authentication flow
- [ ] Test semua fitur end-to-end

### Backend Developer (Temen)
- [ ] Share backend URL & port
- [ ] Share API documentation atau Postman collection
- [ ] Konfirmasi authentication method
- [ ] Konfirmasi response format
- [ ] Konfirmasi endpoints yang sudah ready
- [ ] Setup CORS jika perlu
- [ ] Provide test credentials

## 📝 Testing Plan

### Phase 1: Basic Connection
- [ ] Test health check endpoint
- [ ] Test login endpoint
- [ ] Test get user data

### Phase 2: Core Features
- [ ] Test get rooms list
- [ ] Test get room detail
- [ ] Test create tenant (admin)
- [ ] Test get bills (tenant)

### Phase 3: Advanced Features
- [ ] Test payment upload
- [ ] Test maintenance report
- [ ] Test notifications
- [ ] Test announcements

### Phase 4: Edge Cases
- [ ] Test error handling
- [ ] Test token expiration
- [ ] Test network timeout
- [ ] Test invalid data

## 🐛 Known Issues

```
List any issues found during integration:

1. 
2. 
3. 
```

## 📞 Communication

**Backend Developer Contact:**
- Name: _____________________
- Contact: __________________

**Last Sync:** _____________________

**Next Meeting:** _____________________

## 📚 Resources

- [Backend Integration Guide](./BACKEND_INTEGRATION.md)
- [API Documentation](./API_DOCUMENTATION.md)
- [Setup Guide](./SETUP_GUIDE.md)
- [Architecture](./ARCHITECTURE.md)

---

**Update this checklist as you progress!** ✅
