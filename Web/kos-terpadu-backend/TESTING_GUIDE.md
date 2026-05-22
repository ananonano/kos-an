# Backend API Testing Guide

Panduan lengkap untuk testing backend API menggunakan Postman atau Thunder Client.

## Prerequisites

- Backend server running di `http://localhost:5000`
- Database sudah di-migrate dan di-seed
- Postman atau Thunder Client installed

---

## Setup

### 1. Start Backend Server

```bash
cd Web/kos-terpadu-backend
npm run dev
```

Expected output:
```
KosTerpadu Backend API running on port 5000
```

### 2. Test Health Check

**Request:**
```
GET http://localhost:5000/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "KosTerpadu API is running",
  "version": "1.0.0",
  "database": "connected",
  "timestamp": "2024-..."
}
```

---

## Testing Flow

### STEP 1: Authentication

#### 1.1 Register New User (Optional)

**Request:**
```
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "nama": "Test User",
  "no_telepon": "081234567890",
  "role": "tenant"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Register berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 6,
    "email": "test@example.com",
    "nama": "Test User",
    "role": "tenant"
  }
}
```

#### 1.2 Login as Admin

**Request:**
```
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "admin@kosterpadu.com",
  "password": "admin123"
}
```

**Expected Response:**
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

**⚠️ IMPORTANT:** Copy the token! You'll need it for subsequent requests.

#### 1.3 Get Current User

**Request:**
```
GET http://localhost:5000/api/auth/me
Authorization: Bearer <your_token_here>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "admin@kosterpadu.com",
    "nama": "Admin Kos Terpadu",
    "role": "admin"
  }
}
```

---

### STEP 2: Room Management

#### 2.1 Get All Rooms

**Request:**
```
GET http://localhost:5000/api/rooms?page=1&limit=10
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nomor_kamar": "A101",
      "tipe": "Standard",
      "harga": 1500000,
      "status": "terisi",
      "deskripsi": "Kamar nyaman dengan AC",
      "fasilitas": ["AC", "Kasur", "Lemari"],
      "foto": []
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 8,
    "totalPages": 1
  }
}
```

#### 2.2 Get Room by ID

**Request:**
```
GET http://localhost:5000/api/rooms/1
```

#### 2.3 Create New Room (Admin Only)

**Request:**
```
POST http://localhost:5000/api/rooms
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nomor_kamar": "C301",
  "tipe": "Deluxe",
  "harga": 2500000,
  "deskripsi": "Kamar mewah dengan balkon",
  "fasilitas": ["AC", "TV", "Kulkas", "Balkon"],
  "foto": []
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Kamar berhasil ditambahkan",
  "data": {
    "id": 9,
    "nomor_kamar": "C301",
    "tipe": "Deluxe",
    "harga": 2500000,
    "status": "kosong"
  }
}
```

#### 2.4 Update Room

**Request:**
```
PUT http://localhost:5000/api/rooms/9
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "harga": 2700000,
  "status": "terisi"
}
```

#### 2.5 Get Room Statistics

**Request:**
```
GET http://localhost:5000/api/rooms/statistics
Authorization: Bearer <admin_token>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "total": 9,
    "kosong": 2,
    "terisi": 6,
    "maintenance": 1,
    "occupancy_rate": 66.67
  }
}
```

---

### STEP 3: Tenant Management

#### 3.1 Get All Tenants

**Request:**
```
GET http://localhost:5000/api/tenants?page=1&limit=10
Authorization: Bearer <admin_token>
```

#### 3.2 Create New Tenant

**Request:**
```
POST http://localhost:5000/api/tenants
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "nama": "John Doe",
  "email": "john@example.com",
  "no_telepon": "081234567890",
  "kamar_id": 2,
  "tanggal_masuk": "2024-01-15"
}
```

#### 3.3 Get Tenant Statistics

**Request:**
```
GET http://localhost:5000/api/tenants/statistics
Authorization: Bearer <admin_token>
```

---

### STEP 4: Bill Management

#### 4.1 Get All Bills

**Request:**
```
GET http://localhost:5000/api/bills?page=1&limit=10
Authorization: Bearer <admin_token>
```

**With Filters:**
```
GET http://localhost:5000/api/bills?status=belum_lunas&bulan=Januari&tahun=2024
Authorization: Bearer <admin_token>
```

#### 4.2 Create New Bill

**Request:**
```
POST http://localhost:5000/api/bills
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "tenant_id": 1,
  "contract_id": 1,
  "bulan": "Februari",
  "tahun": 2024,
  "jumlah": 1500000,
  "jatuh_tempo": "2024-02-10",
  "denda": 0,
  "catatan": "Tagihan bulan Februari"
}
```

#### 4.3 Generate Monthly Bills

**Request:**
```
POST http://localhost:5000/api/bills/generate-monthly
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "bulan": "Maret",
  "tahun": 2024
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "5 tagihan berhasil dibuat",
  "data": [...]
}
```

#### 4.4 Get Bill Statistics

**Request:**
```
GET http://localhost:5000/api/bills/statistics?bulan=Januari&tahun=2024
Authorization: Bearer <admin_token>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "total_tagihan": 5,
    "total_lunas": 3,
    "total_belum_lunas": 2,
    "total_terlambat": 0,
    "total_pendapatan": 4500000,
    "total_tunggakan": 3000000
  }
}
```

---

### STEP 5: Payment Management

#### 5.1 Submit Payment (Tenant)

**Request:**
```
POST http://localhost:5000/api/payments
Authorization: Bearer <tenant_token>
Content-Type: application/json

{
  "bill_id": 1,
  "tenant_id": 1,
  "jumlah": 1500000,
  "tanggal_bayar": "2024-01-05",
  "metode_pembayaran": "Transfer Bank BCA",
  "bukti_pembayaran": "https://storage.example.com/proof.jpg",
  "keterangan": "Transfer dari rekening 1234567890"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Pembayaran berhasil disubmit, menunggu verifikasi",
  "data": {
    "id": 6,
    "bill_id": 1,
    "tenant_id": 1,
    "jumlah": 1500000,
    "status": "menunggu_verifikasi"
  }
}
```

#### 5.2 Get Pending Payments (Admin)

**Request:**
```
GET http://localhost:5000/api/payments/pending
Authorization: Bearer <admin_token>
```

#### 5.3 Verify Payment (Admin)

**Request:**
```
POST http://localhost:5000/api/payments/6/verify
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "keterangan": "Pembayaran telah diverifikasi, bukti valid"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Pembayaran berhasil diverifikasi",
  "data": {
    "id": 6,
    "status": "lunas",
    "verified_by": 1,
    "verified_at": "2024-..."
  }
}
```

#### 5.4 Reject Payment (Admin)

**Request:**
```
POST http://localhost:5000/api/payments/7/reject
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "keterangan": "Bukti pembayaran tidak jelas, mohon upload ulang"
}
```

---

### STEP 6: Maintenance Management

#### 6.1 Create Maintenance Request (Tenant)

**Request:**
```
POST http://localhost:5000/api/maintenance
Authorization: Bearer <tenant_token>
Content-Type: application/json

{
  "tenant_id": 1,
  "kamar_id": 1,
  "judul": "AC Tidak Dingin",
  "deskripsi": "AC di kamar sudah 3 hari tidak dingin, mohon diperbaiki",
  "kategori": "Elektronik",
  "prioritas": "tinggi",
  "foto": [
    "https://storage.example.com/ac1.jpg",
    "https://storage.example.com/ac2.jpg"
  ]
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Laporan maintenance berhasil dibuat",
  "data": {
    "id": 11,
    "tenant_id": 1,
    "kamar_id": 1,
    "judul": "AC Tidak Dingin",
    "status": "baru",
    "prioritas": "tinggi"
  }
}
```

#### 6.2 Get All Maintenance Requests

**Request:**
```
GET http://localhost:5000/api/maintenance?status=baru&prioritas=tinggi
Authorization: Bearer <admin_token>
```

#### 6.3 Update Maintenance Status (Admin)

**Request:**
```
PUT http://localhost:5000/api/maintenance/11/status
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "status": "diproses",
  "komentar_admin": "Teknisi sudah dihubungi, akan datang besok pagi",
  "biaya": 150000
}
```

#### 6.4 Get Urgent Maintenance

**Request:**
```
GET http://localhost:5000/api/maintenance/urgent
Authorization: Bearer <admin_token>
```

---

### STEP 7: Announcement Management

#### 7.1 Create Announcement (Admin)

**Request:**
```
POST http://localhost:5000/api/announcements
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "judul": "Pemadaman Listrik Terjadwal",
  "konten": "Akan ada pemadaman listrik besok tanggal 20 Januari dari jam 09:00 - 12:00 untuk maintenance. Mohon persiapkan diri.",
  "kategori": "Informasi",
  "prioritas": "penting",
  "target": "semua"
}
```

#### 7.2 Get Active Announcements by Target

**Request:**
```
GET http://localhost:5000/api/announcements/active/tenant
Authorization: Bearer <tenant_token>
```

#### 7.3 Deactivate Announcement

**Request:**
```
POST http://localhost:5000/api/announcements/1/deactivate
Authorization: Bearer <admin_token>
```

---

### STEP 8: Dashboard

#### 8.1 Get Admin Dashboard Overview

**Request:**
```
GET http://localhost:5000/api/dashboard/admin
Authorization: Bearer <admin_token>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "rooms": {
      "total": 8,
      "kosong": 2,
      "terisi": 5,
      "maintenance": 1,
      "occupancy_rate": 62.5
    },
    "tenants": {
      "total": 5,
      "aktif": 5,
      "nonaktif": 0
    },
    "bills": {
      "total_tagihan": 5,
      "total_lunas": 3,
      "total_belum_lunas": 2,
      "total_terlambat": 0,
      "total_pendapatan": 4500000,
      "total_tunggakan": 3000000
    },
    "payments": {
      "total_payments": 5,
      "total_verified": 3,
      "total_pending": 2,
      "total_rejected": 0,
      "total_amount": 4500000
    },
    "maintenance": {
      "total": 10,
      "baru": 3,
      "diproses": 5,
      "selesai": 2,
      "ditolak": 0,
      "urgent": 1,
      "tinggi": 2,
      "sedang": 5,
      "rendah": 2
    }
  }
}
```

#### 8.2 Get Tenant Dashboard Overview

**Request:**
```
GET http://localhost:5000/api/dashboard/tenant/1
Authorization: Bearer <tenant_token>
```

#### 8.3 Get Financial Summary

**Request:**
```
GET http://localhost:5000/api/dashboard/financial?bulan=Januari&tahun=2024
Authorization: Bearer <admin_token>
```

#### 8.4 Get Pending Tasks

**Request:**
```
GET http://localhost:5000/api/dashboard/pending-tasks
Authorization: Bearer <admin_token>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "pending_payments": [
      {
        "id": 7,
        "tenant_name": "Budi Santoso",
        "nomor_kamar": "A101",
        "jumlah": 1500000,
        "tanggal_bayar": "2024-01-05"
      }
    ],
    "urgent_maintenance": [
      {
        "id": 11,
        "tenant_name": "Budi Santoso",
        "nomor_kamar": "A101",
        "judul": "AC Tidak Dingin",
        "prioritas": "tinggi"
      }
    ],
    "total_pending": 2
  }
}
```

---

## Testing Checklist

### Authentication ✅
- [ ] Register new user
- [ ] Login as admin
- [ ] Login as tenant
- [ ] Get current user
- [ ] Update profile
- [ ] Logout

### Rooms ✅
- [ ] Get all rooms
- [ ] Get room by ID
- [ ] Create room (admin)
- [ ] Update room (admin)
- [ ] Delete room (admin)
- [ ] Get room statistics

### Tenants ✅
- [ ] Get all tenants
- [ ] Get tenant by ID
- [ ] Create tenant
- [ ] Update tenant
- [ ] Delete tenant
- [ ] Get tenant statistics

### Bills ✅
- [ ] Get all bills
- [ ] Get bill by ID
- [ ] Create bill
- [ ] Update bill
- [ ] Delete bill
- [ ] Generate monthly bills
- [ ] Update overdue bills
- [ ] Get bill statistics

### Payments ✅
- [ ] Get all payments
- [ ] Get payment by ID
- [ ] Submit payment (tenant)
- [ ] Update payment
- [ ] Delete payment
- [ ] Verify payment (admin)
- [ ] Reject payment (admin)
- [ ] Get pending payments
- [ ] Get payment statistics

### Maintenance ✅
- [ ] Get all maintenance
- [ ] Get maintenance by ID
- [ ] Create maintenance request
- [ ] Update maintenance
- [ ] Update maintenance status
- [ ] Delete maintenance
- [ ] Get urgent maintenance
- [ ] Get maintenance statistics
- [ ] Get maintenance by category

### Announcements ✅
- [ ] Get all announcements
- [ ] Get announcement by ID
- [ ] Get active announcements by target
- [ ] Create announcement (admin)
- [ ] Update announcement (admin)
- [ ] Delete announcement (admin)
- [ ] Activate announcement
- [ ] Deactivate announcement
- [ ] Get announcement statistics

### Dashboard ✅
- [ ] Get admin overview
- [ ] Get tenant overview
- [ ] Get financial summary
- [ ] Get recent activities
- [ ] Get pending tasks

---

## Common Issues & Solutions

### Issue: 401 Unauthorized

**Cause:** Token tidak valid atau expired

**Solution:**
1. Login ulang untuk get new token
2. Copy token yang baru
3. Update Authorization header

### Issue: 403 Forbidden

**Cause:** User tidak punya permission (e.g., tenant trying to access admin endpoint)

**Solution:**
1. Check endpoint requirements (admin only?)
2. Login dengan user yang sesuai

### Issue: 404 Not Found

**Cause:** Resource tidak ditemukan

**Solution:**
1. Check ID yang digunakan
2. Verify resource exists di database

### Issue: 400 Bad Request

**Cause:** Input validation failed

**Solution:**
1. Check request body format
2. Verify required fields are provided
3. Check data types

### Issue: 500 Internal Server Error

**Cause:** Server error

**Solution:**
1. Check server logs
2. Check database connection
3. Check for bugs in code

---

## Tips

1. **Save Tokens:** Save admin and tenant tokens in Postman environment variables
2. **Use Collections:** Organize requests in Postman collections
3. **Test Sequentially:** Follow the testing flow in order
4. **Check Logs:** Monitor server logs for errors
5. **Use Variables:** Use Postman variables for base URL and tokens

---

## Postman Environment Setup

Create environment with these variables:

```json
{
  "base_url": "http://localhost:5000/api",
  "admin_token": "",
  "tenant_token": "",
  "test_room_id": "",
  "test_tenant_id": "",
  "test_bill_id": "",
  "test_payment_id": ""
}
```

Usage in requests:
```
GET {{base_url}}/rooms
Authorization: Bearer {{admin_token}}
```

---

**Happy Testing! 🚀**
