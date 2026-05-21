# Entity Relationship Diagram (ERD)

## Database Schema - Kos Terpadu

### PostgreSQL Tables

```
┌─────────────────────────────────────────────────────────────────┐
│                            USERS                                │
├─────────────────────────────────────────────────────────────────┤
│ PK  id              SERIAL                                      │
│     email           VARCHAR(255) UNIQUE NOT NULL                │
│     password        VARCHAR(255) NOT NULL                       │
│     nama            VARCHAR(255) NOT NULL                       │
│     role            VARCHAR(50) NOT NULL                        │
│     no_telepon      VARCHAR(20)                                 │
│     foto            VARCHAR(255)                                │
│     created_at      TIMESTAMP                                   │
│     updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 1
                              │
                              │ N
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          PENGHUNI                               │
├─────────────────────────────────────────────────────────────────┤
│ PK  id              SERIAL                                      │
│ FK  user_id         INTEGER → users(id)                         │
│ FK  kamar_id        INTEGER → kamar(id)                         │
│     nama            VARCHAR(255) NOT NULL                       │
│     email           VARCHAR(255) NOT NULL                       │
│     no_telepon      VARCHAR(20) NOT NULL                        │
│     alamat_asal     TEXT                                        │
│     pekerjaan       VARCHAR(100)                                │
│     kontak_darurat  VARCHAR(20)                                 │
│     tanggal_masuk   DATE NOT NULL                               │
│     tanggal_keluar  DATE                                        │
│     status          VARCHAR(50) NOT NULL                        │
│     created_at      TIMESTAMP                                   │
│     updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ N
                              │
                              │ 1
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                           KAMAR                                 │
├─────────────────────────────────────────────────────────────────┤
│ PK  id              SERIAL                                      │
│     nomor_kamar     VARCHAR(50) UNIQUE NOT NULL                 │
│     tipe            VARCHAR(100) NOT NULL                       │
│     harga           DECIMAL(10,2) NOT NULL                      │
│     status          VARCHAR(50) NOT NULL                        │
│     deskripsi       TEXT                                        │
│     fasilitas       JSON                                        │
│     foto            VARCHAR(255)                                │
│     created_at      TIMESTAMP                                   │
│     updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                          TAGIHAN                                │
├─────────────────────────────────────────────────────────────────┤
│ PK  id              SERIAL                                      │
│ FK  penghuni_id     INTEGER → penghuni(id)                      │
│     bulan           VARCHAR(20) NOT NULL                        │
│     tahun           INTEGER NOT NULL                            │
│     jumlah          DECIMAL(10,2) NOT NULL                      │
│     status          VARCHAR(50) NOT NULL                        │
│     jatuh_tempo     DATE NOT NULL                               │
│     created_at      TIMESTAMP                                   │
│     updated_at      TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 1
                              │
                              │ N
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        PEMBAYARAN                               │
├─────────────────────────────────────────────────────────────────┤
│ PK  id                  SERIAL                                  │
│ FK  tagihan_id          INTEGER → tagihan(id)                   │
│ FK  penghuni_id         INTEGER → penghuni(id)                  │
│     jumlah              DECIMAL(10,2) NOT NULL                  │
│     tanggal_bayar       DATE NOT NULL                           │
│     metode_pembayaran   VARCHAR(100) NOT NULL                   │
│     bukti_pembayaran    VARCHAR(255)                            │
│     status              VARCHAR(50) NOT NULL                    │
│     keterangan          TEXT                                    │
│     created_at          TIMESTAMP                               │
│     updated_at          TIMESTAMP                               │
└─────────────────────────────────────────────────────────────────┘
```

### Firebase Firestore Collections

```
┌─────────────────────────────────────────────────────────────────┐
│                          KELUHAN                                │
│                    (Firestore Collection)                       │
├─────────────────────────────────────────────────────────────────┤
│     id              STRING (document ID)                        │
│     penghuni_id     STRING                                      │
│     kamar_id        STRING                                      │
│     judul           STRING                                      │
│     deskripsi       STRING                                      │
│     foto            ARRAY<STRING>                               │
│     status          STRING                                      │
│     komentar        STRING                                      │
│     nama_penghuni   STRING                                      │
│     nomor_kamar     STRING                                      │
│     createdAt       TIMESTAMP                                   │
│     updatedAt       TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                           CHATS                                 │
│                    (Firestore Collection)                       │
├─────────────────────────────────────────────────────────────────┤
│     id                  STRING (document ID)                    │
│     penghuni_id         STRING                                  │
│     admin_id            STRING                                  │
│     last_message        STRING                                  │
│     last_message_time   TIMESTAMP                               │
│     unread_count        NUMBER                                  │
│     penghuni_name       STRING                                  │
│     admin_name          STRING                                  │
│     createdAt           TIMESTAMP                               │
│     updatedAt           TIMESTAMP                               │
│                                                                 │
│     ┌─────────────────────────────────────────────────────┐   │
│     │            MESSAGES (Subcollection)                 │   │
│     ├─────────────────────────────────────────────────────┤   │
│     │ id              STRING (document ID)                │   │
│     │ chat_room_id    STRING                              │   │
│     │ sender_id       STRING                              │   │
│     │ message         STRING                              │   │
│     │ image_url       STRING                              │   │
│     │ sender_name     STRING                              │   │
│     │ sender_role     STRING                              │   │
│     │ createdAt       TIMESTAMP                           │   │
│     └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────┐
│                      NOTIFICATIONS                              │
│                    (Firestore Collection)                       │
├─────────────────────────────────────────────────────────────────┤
│     id              STRING (document ID)                        │
│     user_id         STRING                                      │
│     title           STRING                                      │
│     body            STRING                                      │
│     type            STRING                                      │
│     data            MAP                                         │
│     is_read         BOOLEAN                                     │
│     createdAt       TIMESTAMP                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Relationships

### PostgreSQL Relationships

1. **users → penghuni** (One-to-Many)
   - Satu user bisa menjadi satu penghuni
   - Cascade delete: jika user dihapus, penghuni juga dihapus

2. **kamar → penghuni** (One-to-Many)
   - Satu kamar bisa ditempati banyak penghuni (historis)
   - Set null: jika kamar dihapus, penghuni tetap ada tapi kamar_id = null

3. **penghuni → tagihan** (One-to-Many)
   - Satu penghuni bisa punya banyak tagihan
   - Cascade delete: jika penghuni dihapus, tagihan juga dihapus

4. **tagihan → pembayaran** (One-to-Many)
   - Satu tagihan bisa punya banyak pembayaran (cicilan)
   - Cascade delete: jika tagihan dihapus, pembayaran juga dihapus

5. **penghuni → pembayaran** (One-to-Many)
   - Satu penghuni bisa punya banyak pembayaran
   - Cascade delete: jika penghuni dihapus, pembayaran juga dihapus

### Firebase Relationships (Logical)

1. **keluhan**
   - `penghuni_id` → references users.id (PostgreSQL)
   - `kamar_id` → references kamar.id (PostgreSQL)
   - Denormalized: `nama_penghuni`, `nomor_kamar` untuk performa

2. **chats**
   - `penghuni_id` → references users.id (PostgreSQL)
   - `admin_id` → references users.id (PostgreSQL)
   - Denormalized: `penghuni_name`, `admin_name` untuk performa

3. **messages** (subcollection of chats)
   - `sender_id` → references users.id (PostgreSQL)
   - Denormalized: `sender_name`, `sender_role` untuk performa

4. **notifications**
   - `user_id` → references users.id (PostgreSQL)

## Data Flow

### PostgreSQL (Transactional Data)
```
Users ──┐
        ├──> Penghuni ──┐
Kamar ──┘               ├──> Tagihan ──> Pembayaran
                        │
                        └──> (reference to Firebase)
```

### Firebase (Realtime Data)
```
Keluhan (realtime updates)
    ↓
    References: penghuni_id, kamar_id (from PostgreSQL)

Chats (realtime messaging)
    ├──> Messages (subcollection)
    ↓
    References: penghuni_id, admin_id (from PostgreSQL)

Notifications (realtime alerts)
    ↓
    References: user_id (from PostgreSQL)
```

## Indexes

### PostgreSQL Indexes

```sql
-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- Penghuni
CREATE INDEX idx_penghuni_user_id ON penghuni(user_id);
CREATE INDEX idx_penghuni_kamar_id ON penghuni(kamar_id);
CREATE INDEX idx_penghuni_status ON penghuni(status);

-- Kamar
CREATE INDEX idx_kamar_status ON kamar(status);
CREATE INDEX idx_kamar_nomor ON kamar(nomor_kamar);

-- Tagihan
CREATE INDEX idx_tagihan_penghuni_id ON tagihan(penghuni_id);
CREATE INDEX idx_tagihan_status ON tagihan(status);
CREATE INDEX idx_tagihan_bulan_tahun ON tagihan(bulan, tahun);

-- Pembayaran
CREATE INDEX idx_pembayaran_tagihan_id ON pembayaran(tagihan_id);
CREATE INDEX idx_pembayaran_penghuni_id ON pembayaran(penghuni_id);
CREATE INDEX idx_pembayaran_status ON pembayaran(status);
```

### Firebase Indexes

Firestore automatically indexes single fields. Composite indexes needed for:

```javascript
// Keluhan
- penghuni_id + status
- penghuni_id + createdAt (desc)
- status + createdAt (desc)

// Chats
- penghuni_id + updatedAt (desc)
- admin_id + updatedAt (desc)

// Messages
- chat_room_id + createdAt (asc)

// Notifications
- user_id + is_read + createdAt (desc)
```

## Data Consistency

### Denormalization Strategy

Firebase Firestore menggunakan denormalization untuk performa:

**Keluhan:**
- Menyimpan `nama_penghuni` dan `nomor_kamar`
- Tidak perlu join dengan PostgreSQL untuk display
- Update jika nama/nomor berubah (trade-off)

**Chats:**
- Menyimpan `penghuni_name` dan `admin_name`
- Tidak perlu join untuk display chat list
- Update jika nama berubah

**Messages:**
- Menyimpan `sender_name` dan `sender_role`
- Tidak perlu join untuk display messages
- Update jika nama berubah

### Sync Strategy

Ketika data di PostgreSQL berubah:
1. Update PostgreSQL first
2. Update Firebase denormalized data
3. Handle errors gracefully

## Storage

### Firebase Storage Structure

```
storage/
├── keluhan_images/
│   ├── {timestamp}_{filename}.jpg
│   └── {timestamp}_{filename}.png
├── bukti_pembayaran/
│   ├── {timestamp}_{filename}.jpg
│   └── {timestamp}_{filename}.pdf
└── profile_images/
    └── {user_id}_{timestamp}.jpg
```

## Security

### PostgreSQL
- Row-level security (RLS)
- User permissions
- Encrypted passwords (bcrypt)
- JWT authentication

### Firebase
- Firestore security rules
- Storage security rules
- Authentication required
- File size limits
