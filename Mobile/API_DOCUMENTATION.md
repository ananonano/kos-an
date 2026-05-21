# API Documentation - Kos Terpadu Backend

## Base URL
```
Production: https://api.kosterpadu.com/api/v1
Development: http://localhost:3000/api/v1
```

## Authentication

Semua endpoint (kecuali login & register) memerlukan JWT token di header:
```
Authorization: Bearer <token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message"
}
```

## Endpoints

### 1. Authentication

#### POST /auth/register
Register user baru (default role: penghuni)

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "nama": "John Doe",
  "no_telepon": "081234567890"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Register berhasil",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "nama": "John Doe",
    "role": "penghuni",
    "no_telepon": "081234567890",
    "foto": null,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /auth/login
Login user

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
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "nama": "John Doe",
    "role": "penghuni",
    "no_telepon": "081234567890",
    "foto": null,
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /auth/logout
Logout user (invalidate token)

**Response:**
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

#### PUT /auth/profile/:id
Update user profile

**Request Body:**
```json
{
  "nama": "John Doe Updated",
  "no_telepon": "081234567890",
  "foto": "https://storage.com/photo.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile berhasil diupdate",
  "user": { ... }
}
```

---

### 2. Kamar

#### GET /kamar
Get all kamar

**Query Parameters:**
- `status` (optional): 'kosong' | 'terisi'
- `page` (optional): number (default: 1)
- `limit` (optional): number (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "nomor_kamar": "A1",
      "tipe": "Standard",
      "harga": 1500000,
      "status": "kosong",
      "deskripsi": "Kamar nyaman dengan AC",
      "fasilitas": ["AC", "Kasur", "Lemari"],
      "foto": "https://storage.com/kamar1.jpg",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
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

#### GET /kamar/:id
Get kamar by ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "1",
    "nomor_kamar": "A1",
    "tipe": "Standard",
    "harga": 1500000,
    "status": "kosong",
    "deskripsi": "Kamar nyaman dengan AC",
    "fasilitas": ["AC", "Kasur", "Lemari"],
    "foto": "https://storage.com/kamar1.jpg",
    "created_at": "2024-01-01T00:00:00.000Z",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /kamar
Create kamar (Admin only)

**Request Body:**
```json
{
  "nomor_kamar": "A1",
  "tipe": "Standard",
  "harga": 1500000,
  "deskripsi": "Kamar nyaman dengan AC",
  "fasilitas": ["AC", "Kasur", "Lemari"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Kamar berhasil ditambahkan",
  "data": { ... }
}
```

#### PUT /kamar/:id
Update kamar (Admin only)

**Request Body:**
```json
{
  "nomor_kamar": "A1",
  "tipe": "Deluxe",
  "harga": 2000000,
  "status": "terisi",
  "deskripsi": "Kamar mewah dengan AC",
  "fasilitas": ["AC", "Kasur", "Lemari", "TV"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Kamar berhasil diupdate",
  "data": { ... }
}
```

#### DELETE /kamar/:id
Delete kamar (Admin only)

**Response:**
```json
{
  "success": true,
  "message": "Kamar berhasil dihapus"
}
```

---

### 3. Penghuni

#### GET /penghuni
Get all penghuni

**Query Parameters:**
- `status` (optional): 'aktif' | 'tidak_aktif'
- `kamar_id` (optional): filter by kamar
- `page` (optional): number
- `limit` (optional): number

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "user_id": "1",
      "kamar_id": "1",
      "nama": "John Doe",
      "email": "john@example.com",
      "no_telepon": "081234567890",
      "alamat_asal": "Jakarta",
      "pekerjaan": "Karyawan",
      "kontak_darurat": "081234567891",
      "tanggal_masuk": "2024-01-01",
      "tanggal_keluar": null,
      "status": "aktif",
      "nomor_kamar": "A1",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### GET /penghuni/:id
Get penghuni by ID

#### POST /penghuni
Create penghuni

**Request Body:**
```json
{
  "user_id": "1",
  "kamar_id": "1",
  "nama": "John Doe",
  "email": "john@example.com",
  "no_telepon": "081234567890",
  "alamat_asal": "Jakarta",
  "pekerjaan": "Karyawan",
  "kontak_darurat": "081234567891",
  "tanggal_masuk": "2024-01-01"
}
```

#### PUT /penghuni/:id
Update penghuni

#### DELETE /penghuni/:id
Delete penghuni

---

### 4. Pembayaran

#### GET /pembayaran
Get all pembayaran

**Query Parameters:**
- `penghuni_id` (optional): filter by penghuni
- `status` (optional): 'belum_lunas' | 'menunggu_verifikasi' | 'lunas' | 'ditolak'
- `page` (optional): number
- `limit` (optional): number

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "tagihan_id": "1",
      "penghuni_id": "1",
      "jumlah": 1500000,
      "tanggal_bayar": "2024-01-05",
      "metode_pembayaran": "Transfer Bank",
      "bukti_pembayaran": "https://storage.com/bukti1.jpg",
      "status": "menunggu_verifikasi",
      "keterangan": null,
      "nama_penghuni": "John Doe",
      "nomor_kamar": "A1",
      "created_at": "2024-01-05T00:00:00.000Z",
      "updated_at": "2024-01-05T00:00:00.000Z"
    }
  ]
}
```

#### GET /pembayaran/:id
Get pembayaran by ID

#### POST /pembayaran
Create pembayaran

**Request Body:**
```json
{
  "tagihan_id": "1",
  "penghuni_id": "1",
  "jumlah": 1500000,
  "tanggal_bayar": "2024-01-05",
  "metode_pembayaran": "Transfer Bank",
  "bukti_pembayaran": "https://storage.com/bukti1.jpg"
}
```

#### PUT /pembayaran/:id
Update pembayaran status (Admin only)

**Request Body:**
```json
{
  "status": "lunas",
  "keterangan": "Pembayaran telah diverifikasi"
}
```

#### POST /pembayaran/:id/upload
Upload bukti pembayaran (multipart/form-data)

**Form Data:**
- `file`: image file

**Response:**
```json
{
  "success": true,
  "message": "Bukti pembayaran berhasil diupload",
  "url": "https://storage.com/bukti1.jpg"
}
```

---

### 5. Tagihan

#### GET /tagihan
Get all tagihan

**Query Parameters:**
- `penghuni_id` (optional): filter by penghuni
- `status` (optional): 'belum_lunas' | 'lunas'
- `bulan` (optional): filter by month
- `tahun` (optional): filter by year

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "penghuni_id": "1",
      "bulan": "Januari",
      "tahun": 2024,
      "jumlah": 1500000,
      "status": "belum_lunas",
      "jatuh_tempo": "2024-01-10",
      "nama_penghuni": "John Doe",
      "nomor_kamar": "A1",
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### GET /tagihan/:id
Get tagihan by ID

#### POST /tagihan
Create tagihan (Admin only)

**Request Body:**
```json
{
  "penghuni_id": "1",
  "bulan": "Januari",
  "tahun": 2024,
  "jumlah": 1500000,
  "jatuh_tempo": "2024-01-10"
}
```

#### PUT /tagihan/:id
Update tagihan

---

## Error Codes

| Code | Description |
|------|-------------|
| 200  | Success |
| 201  | Created |
| 400  | Bad Request |
| 401  | Unauthorized |
| 403  | Forbidden |
| 404  | Not Found |
| 500  | Internal Server Error |

## Rate Limiting

- 100 requests per minute per IP
- 1000 requests per hour per user

## Pagination

Default pagination:
- `page`: 1
- `limit`: 20
- `max_limit`: 100

## File Upload

Supported formats:
- Images: JPG, PNG, JPEG
- Max size: 5MB

## Security

- All passwords are hashed using bcrypt
- JWT tokens expire after 7 days
- HTTPS only in production
- CORS enabled for allowed origins
