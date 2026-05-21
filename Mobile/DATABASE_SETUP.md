# Database Setup Guide

## Option 1: PostgreSQL Installation (Recommended)

### Step 1: Download PostgreSQL
1. Buka browser dan kunjungi: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
2. Download versi terbaru untuk Windows (misalnya PostgreSQL 16)
3. Jalankan installer yang sudah didownload

### Step 2: Install PostgreSQL
1. Klik "Next" pada welcome screen
2. Installation Directory: Biarkan default (`C:\Program Files\PostgreSQL\16`)
3. Select Components: Centang semua (PostgreSQL Server, pgAdmin 4, Stack Builder, Command Line Tools)
4. Data Directory: Biarkan default
5. **Password**: Masukkan password untuk user `postgres` (INGAT PASSWORD INI!)
   - Contoh: `admin123` atau password yang mudah diingat
6. Port: Biarkan default `5432`
7. Locale: Default locale
8. Klik "Next" dan tunggu instalasi selesai

### Step 3: Set Environment Variable (PATH)
Setelah instalasi selesai, tambahkan PostgreSQL ke PATH:

1. Buka "Environment Variables":
   - Tekan `Win + R`
   - Ketik `sysdm.cpl` dan Enter
   - Klik tab "Advanced"
   - Klik "Environment Variables"

2. Di bagian "System variables", cari variable `Path`:
   - Klik "Path"
   - Klik "Edit"
   - Klik "New"
   - Tambahkan: `C:\Program Files\PostgreSQL\16\bin`
   - Klik "OK" semua dialog

3. **RESTART Command Prompt** atau buka Command Prompt baru

### Step 4: Verify Installation
Buka Command Prompt baru dan jalankan:
```cmd
psql --version
```

Jika berhasil, akan muncul versi PostgreSQL.

### Step 5: Create Database
```cmd
psql -U postgres
```
Masukkan password yang kamu set saat instalasi.

Kemudian jalankan SQL berikut:
```sql
CREATE DATABASE kos_terpadu;
\c kos_terpadu
```

---

## Option 2: SQLite (Lebih Simple, Tidak Perlu Install)

Jika kamu mau yang lebih simple dan tidak perlu install PostgreSQL, kita bisa pakai SQLite.

### Kelebihan SQLite:
- ✅ Tidak perlu install apapun
- ✅ Database berupa file `.db` saja
- ✅ Cocok untuk development dan testing
- ✅ Setup lebih cepat

### Kekurangan SQLite:
- ❌ Kurang cocok untuk production dengan banyak user concurrent
- ❌ Fitur lebih terbatas dibanding PostgreSQL

---

## Pilihan Kamu

**Pilih salah satu:**

1. **PostgreSQL** - Jika kamu mau setup production-ready dan belajar database enterprise
2. **SQLite** - Jika kamu mau cepat dan simple untuk development

Setelah kamu pilih, aku akan buatkan:
- Backend Express.js dengan database yang kamu pilih
- Database schema
- API endpoints lengkap
- Setup instructions

**Mana yang kamu pilih? PostgreSQL atau SQLite?**
