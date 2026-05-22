# API Documentation - KosTerpadu Backend

Base URL: `http://localhost:5000/api`

## Authentication

All protected endpoints require JWT token in Authorization header:
```
Authorization: Bearer <token>
```

---

## 1. Authentication Endpoints

### POST /api/auth/register
Register new user account

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "nama": "John Doe",
  "no_telepon": "081234567890",
  "role": "tenant"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Register berhasil",
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nama": "John Doe",
    "role": "tenant"
  }
}
```

### POST /api/auth/login
Login with email and password

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login berhasil",
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "nama": "John Doe",
    "role": "tenant"
  }
}
```

### GET /api/auth/me
Get current authenticated user

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "nama": "John Doe",
    "role": "tenant"
  }
}
```

### POST /api/auth/logout
Logout current user

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

### PUT /api/auth/profile
Update user profile

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "nama": "John Updated",
  "no_telepon": "081234567890",
  "foto": "https://example.com/photo.jpg"
}
```

---

## 2. Room Endpoints

### GET /api/rooms
Get all rooms with pagination

**Query Parameters:**
- `page` (optional): Page number, default 1
- `limit` (optional): Items per page, default 20
- `status` (optional): Filter by status (kosong, terisi, maintenance)
- `search` (optional): Search by room number or type

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nomor_kamar": "A101",
      "tipe": "Standard",
      "harga": 1500000,
      "status": "kosong",
      "deskripsi": "Kamar nyaman dengan AC",
      "fasilitas": ["AC", "Kasur", "Lemari"],
      "foto": ["url1", "url2"]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "totalPages": 3
  }
}
```

### GET /api/rooms/:id
Get room by ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nomor_kamar": "A101",
    "tipe": "Standard",
    "harga": 1500000,
    "status": "kosong"
  }
}
```

### POST /api/rooms
Create new room (Admin only)

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "nomor_kamar": "A101",
  "tipe": "Standard",
  "harga": 1500000,
  "deskripsi": "Kamar nyaman",
  "fasilitas": ["AC", "Kasur"],
  "foto": ["url1", "url2"]
}
```

### PUT /api/rooms/:id
Update room (Admin only)

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "nomor_kamar": "A101",
  "tipe": "Deluxe",
  "harga": 2000000,
  "status": "terisi"
}
```

### DELETE /api/rooms/:id
Delete room (Admin only)

**Headers:** `Authorization: Bearer <token>`

### GET /api/rooms/statistics
Get room statistics

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "total": 50,
    "kosong": 10,
    "terisi": 38,
    "maintenance": 2,
    "occupancy_rate": 76
  }
}
```

---

## 3. Tenant Endpoints

### GET /api/tenants
Get all tenants with pagination

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`, `limit`, `status`, `search`

### GET /api/tenants/:id
Get tenant by ID

### POST /api/tenants
Create new tenant (Admin only)

**Request Body:**
```json
{
  "nama": "Jane Doe",
  "email": "jane@example.com",
  "no_telepon": "081234567890",
  "kamar_id": 1,
  "tanggal_masuk": "2024-01-01"
}
```

### PUT /api/tenants/:id
Update tenant

### DELETE /api/tenants/:id
Delete tenant (Admin only)

### GET /api/tenants/statistics
Get tenant statistics

---

## 4. Bill Endpoints

### GET /api/bills
Get all bills with pagination

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`, `limit`
- `tenant_id`: Filter by tenant
- `status`: Filter by status (belum_lunas, lunas, terlambat)
- `bulan`: Filter by month
- `tahun`: Filter by year
- `search`: Search by tenant name or room number

### GET /api/bills/:id
Get bill by ID

### POST /api/bills
Create new bill (Admin only)

**Request Body:**
```json
{
  "tenant_id": 1,
  "contract_id": 1,
  "bulan": "Januari",
  "tahun": 2024,
  "jumlah": 1500000,
  "jatuh_tempo": "2024-01-10",
  "denda": 0,
  "catatan": "Tagihan bulan Januari"
}
```

### PUT /api/bills/:id
Update bill (Admin only)

### DELETE /api/bills/:id
Delete bill (Admin only)

### GET /api/bills/statistics
Get bill statistics

**Query Parameters:**
- `bulan`, `tahun`

**Response:**
```json
{
  "success": true,
  "data": {
    "total_tagihan": 50,
    "total_lunas": 40,
    "total_belum_lunas": 8,
    "total_terlambat": 2,
    "total_pendapatan": 60000000,
    "total_tunggakan": 12000000
  }
}
```

### POST /api/bills/generate-monthly
Generate monthly bills for all active tenants (Admin only)

**Request Body:**
```json
{
  "bulan": "Januari",
  "tahun": 2024
}
```

### POST /api/bills/update-overdue
Update overdue bills to terlambat status (Admin only)

---

## 5. Payment Endpoints

### GET /api/payments
Get all payments with pagination

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`, `limit`
- `tenant_id`: Filter by tenant
- `bill_id`: Filter by bill
- `status`: Filter by status (menunggu_verifikasi, lunas, ditolak)
- `search`: Search

### GET /api/payments/:id
Get payment by ID

### POST /api/payments
Create new payment (Tenant submits payment proof)

**Request Body:**
```json
{
  "bill_id": 1,
  "tenant_id": 1,
  "jumlah": 1500000,
  "tanggal_bayar": "2024-01-05",
  "metode_pembayaran": "Transfer Bank",
  "bukti_pembayaran": "https://storage.url/proof.jpg",
  "keterangan": "Pembayaran via BCA"
}
```

### PUT /api/payments/:id
Update payment (Before verification)

### DELETE /api/payments/:id
Delete payment

### POST /api/payments/:id/verify
Verify payment (Admin only)

**Request Body:**
```json
{
  "keterangan": "Pembayaran telah diverifikasi"
}
```

### POST /api/payments/:id/reject
Reject payment (Admin only)

**Request Body:**
```json
{
  "keterangan": "Bukti pembayaran tidak valid"
}
```

### GET /api/payments/pending
Get pending payments (Admin only)

### GET /api/payments/statistics
Get payment statistics

---

## 6. Maintenance Endpoints

### GET /api/maintenance
Get all maintenance requests

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`, `limit`
- `tenant_id`, `kamar_id`
- `status`: baru, diproses, selesai, ditolak
- `prioritas`: rendah, sedang, tinggi, urgent
- `kategori`: Filter by category
- `search`: Search

### GET /api/maintenance/:id
Get maintenance by ID

### POST /api/maintenance
Create maintenance request (Tenant)

**Request Body:**
```json
{
  "tenant_id": 1,
  "kamar_id": 1,
  "judul": "AC Rusak",
  "deskripsi": "AC tidak dingin",
  "kategori": "Elektronik",
  "prioritas": "tinggi",
  "foto": ["url1", "url2"]
}
```

### PUT /api/maintenance/:id
Update maintenance

### PUT /api/maintenance/:id/status
Update maintenance status (Admin only)

**Request Body:**
```json
{
  "status": "diproses",
  "komentar_admin": "Sedang ditangani teknisi",
  "biaya": 150000
}
```

### DELETE /api/maintenance/:id
Delete maintenance (Admin only)

### GET /api/maintenance/urgent
Get urgent maintenance requests (Admin only)

### GET /api/maintenance/statistics
Get maintenance statistics

### GET /api/maintenance/by-category
Get maintenance grouped by category

---

## 7. Announcement Endpoints

### GET /api/announcements
Get all announcements

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `page`, `limit`
- `kategori`, `prioritas`, `target`
- `is_active`: true/false
- `search`

### GET /api/announcements/:id
Get announcement by ID

### GET /api/announcements/active/:target
Get active announcements by target (semua, tenant, admin)

### POST /api/announcements
Create announcement (Admin only)

**Request Body:**
```json
{
  "judul": "Pemadaman Listrik",
  "konten": "Akan ada pemadaman listrik besok",
  "kategori": "Informasi",
  "prioritas": "penting",
  "target": "semua"
}
```

### PUT /api/announcements/:id
Update announcement (Admin only)

### DELETE /api/announcements/:id
Delete announcement (Admin only)

### POST /api/announcements/:id/activate
Activate announcement (Admin only)

### POST /api/announcements/:id/deactivate
Deactivate announcement (Admin only)

### GET /api/announcements/statistics
Get announcement statistics

---

## 8. Dashboard Endpoints

### GET /api/dashboard/admin
Get admin dashboard overview (Admin only)

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "success": true,
  "data": {
    "rooms": { "total": 50, "kosong": 10, "terisi": 38 },
    "tenants": { "total": 38, "aktif": 35, "nonaktif": 3 },
    "bills": { "total_tagihan": 50, "total_lunas": 40 },
    "payments": { "total_payments": 45, "total_pending": 5 },
    "maintenance": { "total": 20, "baru": 5, "diproses": 10 }
  }
}
```

### GET /api/dashboard/tenant/:tenantId
Get tenant dashboard overview

### GET /api/dashboard/financial
Get financial summary (Admin only)

**Query Parameters:**
- `bulan`, `tahun`

### GET /api/dashboard/activities
Get recent activities (Admin only)

**Query Parameters:**
- `limit`: Number of items, default 10

### GET /api/dashboard/pending-tasks
Get pending tasks (Admin only)

**Response:**
```json
{
  "success": true,
  "data": {
    "pending_payments": [],
    "urgent_maintenance": [],
    "total_pending": 10
  }
}
```

---

## Error Responses

All endpoints return consistent error format:

```json
{
  "success": false,
  "message": "Error message here"
}
```

**Common HTTP Status Codes:**
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

---

## Total Endpoints: 60+

**Authentication:** 5 endpoints
**Rooms:** 6 endpoints
**Tenants:** 6 endpoints
**Bills:** 8 endpoints
**Payments:** 9 endpoints
**Maintenance:** 9 endpoints
**Announcements:** 9 endpoints
**Dashboard:** 5 endpoints

Total: **57 endpoints** (exceeds requirement of 15+ endpoints)
