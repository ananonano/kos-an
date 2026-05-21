# KosTerpadu Backend API

Backend REST API untuk sistem manajemen kos terpadu.

## Tech Stack
- Node.js + TypeScript
- Express.js
- PostgreSQL
- Firebase Firestore + Storage
- JWT Authentication

## Quick Start

### 1. Install
```bash
npm install
```

### 2. Setup .env
```bash
cp .env.example .env
# Isi DB_PASSWORD, JWT_SECRET, dan Firebase credentials
```

### 3. Buat database PostgreSQL
```sql
CREATE DATABASE kos_terpadu;
```

### 4. Migrate + Seed
```bash
npm run db:migrate
npm run db:seed
```

### 5. Jalankan
```bash
npm run dev
# Server: http://localhost:5000
```

## Credentials Default
- Admin: admin@kosterpadu.com / admin123
- Tenant: budi@email.com / tenant123

## Endpoints

| Method | Endpoint | Auth | Keterangan |
|--------|----------|------|------------|
| POST | /api/auth/login | - | Login |
| GET | /api/dashboard/stats | Admin | Statistik |
| GET | /api/rooms | - | List kamar |
| POST | /api/rooms | Admin | Tambah kamar |
| GET | /api/tenants | Admin | List penghuni |
| POST | /api/tenants | Admin | Tambah penghuni |
| GET | /api/bills | Admin | List tagihan |
| POST | /api/bills/generate | Admin | Generate tagihan |
| GET | /api/payments | Admin | List pembayaran |
| PUT | /api/payments/:id/verify | Admin | Verifikasi |
| PUT | /api/payments/:id/reject | Admin | Tolak |
| GET | /api/maintenance | Admin | List keluhan |
| PUT | /api/maintenance/:id | Admin | Update status |
| GET | /api/announcements | - | List pengumuman |
| POST | /api/announcements | Admin | Buat pengumuman |

## Firebase Collections
- `realtime_chat` - Chat penyewa-admin
- `realtime_notifications` - Notifikasi realtime
- `maintenance_status` - Status perbaikan realtime
- `activity_logs` - Log aktivitas
