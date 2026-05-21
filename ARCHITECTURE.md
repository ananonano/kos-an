# 🏗️ KosTerpadu - System Architecture

## 📐 Architecture Overview

KosTerpadu menggunakan **Microservices-inspired Architecture** dengan separation of concerns yang jelas antara presentation layer, business logic, dan data layer.

---

## 🎯 Architecture Principles

1. **Separation of Concerns** - Setiap layer punya tanggung jawab yang jelas
2. **Scalability** - Bisa scale horizontal (Cloud Run auto-scaling)
3. **Maintainability** - Modular code, easy to update
4. **Security** - JWT auth, role-based access, input validation
5. **Performance** - Database indexing, connection pooling, caching
6. **Cloud-Native** - Designed for Google Cloud Platform

---

## 🏛️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────┐         ┌──────────────────────┐         │
│  │   Web Dashboard      │         │   Mobile App         │         │
│  │   (Next.js)          │         │   (Flutter)          │         │
│  │                      │         │                      │         │
│  │  - Admin Interface   │         │  - Tenant Interface  │         │
│  │  - CRUD Operations   │         │  - View & Upload     │         │
│  │  - Reports           │         │  - Realtime Updates  │         │
│  │  - Analytics         │         │  - Notifications     │         │
│  │                      │         │                      │         │
│  │  Deploy: App Engine  │         │  Deploy: APK         │         │
│  └──────────┬───────────┘         └──────────┬───────────┘         │
│             │                                │                     │
└─────────────┼────────────────────────────────┼─────────────────────┘
              │                                │
              │         HTTPS/REST API         │
              │         Authorization: Bearer  │
              └────────────┬───────────────────┘
                           │
┌──────────────────────────┼───────────────────────────────────────────┐
│                    API GATEWAY LAYER                                │
├──────────────────────────┼───────────────────────────────────────────┤
│                          ▼                                           │
│              ┌────────────────────────┐                              │
│              │   Express.js Backend   │                              │
│              │   (TypeScript)         │                              │
│              │                        │                              │
│              │  ┌──────────────────┐  │                              │
│              │  │  Middleware      │  │                              │
│              │  │  - CORS          │  │                              │
│              │  │  - Helmet        │  │                              │
│              │  │  - Rate Limit    │  │                              │
│              │  │  - JWT Auth      │  │                              │
│              │  │  - Validation    │  │                              │
│              │  │  - Error Handler │  │                              │
│              │  └──────────────────┘  │                              │
│              │                        │                              │
│              │  ┌──────────────────┐  │                              │
│              │  │  Routes          │  │                              │
│              │  │  - /auth         │  │                              │
│              │  │  - /rooms        │  │                              │
│              │  │  - /tenants      │  │                              │
│              │  │  - /bills        │  │                              │
│              │  │  - /payments     │  │                              │
│              │  │  - /maintenance  │  │                              │
│              │  │  - /announcements│  │                              │
│              │  │  - /dashboard    │  │                              │
│              │  └──────────────────┘  │                              │
│              │                        │                              │
│              │  ┌──────────────────┐  │                              │
│              │  │  Controllers     │  │                              │
│              │  │  - Request       │  │                              │
│              │  │  - Validation    │  │                              │
│              │  │  - Response      │  │                              │
│              │  └──────────────────┘  │                              │
│              │                        │                              │
│              │  ┌──────────────────┐  │                              │
│              │  │  Models          │  │                              │
│              │  │  - Database Ops  │  │                              │
│              │  │  - Business Logic│  │                              │
│              │  │  - Queries       │  │                              │
│              │  └──────────────────┘  │                              │
│              │                        │                              │
│              │  Deploy: Cloud Run     │                              │
│              │  Auto-scaling: 0-100   │                              │
│              └────────────┬───────────┘                              │
│                           │                                          │
└───────────────────────────┼──────────────────────────────────────────┘
                            │
                ┌───────────┴───────────┐
                │                       │
┌───────────────▼─────────┐  ┌──────────▼──────────────────────────────┐
│    DATA LAYER           │  │    REALTIME & STORAGE LAYER             │
│    (PostgreSQL)         │  │    (Firebase)                           │
├─────────────────────────┤  ├─────────────────────────────────────────┤
│                         │  │                                         │
│  Cloud SQL Instance     │  │  ┌─────────────────────────────────┐   │
│                         │  │  │  Firestore (NoSQL)              │   │
│  ┌───────────────────┐  │  │  │                                 │   │
│  │  Tables:          │  │  │  │  Collections:                   │   │
│  │  - users          │  │  │  │  - chats                        │   │
│  │  - rooms          │  │  │  │  - messages (subcollection)     │   │
│  │  - tenants        │  │  │  │  - notifications                │   │
│  │  - contracts      │  │  │  │  - maintenance_status           │   │
│  │  - bills          │  │  │  │  - activity_logs                │   │
│  │  - payments       │  │  │  │                                 │   │
│  │  - maintenance    │  │  │  │  Realtime Sync                  │   │
│  │  - announcements  │  │  │  │  Offline Support                │   │
│  │                   │  │  │  └─────────────────────────────────┘   │
│  │  Indexes          │  │  │                                         │
│  │  Connection Pool  │  │  │  ┌─────────────────────────────────┐   │
│  │  Transactions     │  │  │  │  Storage (Files)                │   │
│  │                   │  │  │  │                                 │   │
│  └───────────────────┘  │  │  │  Buckets:                       │   │
│                         │  │  │  - maintenance-photos/          │   │
│  Deploy: Cloud SQL      │  │  │  - payment-proofs/              │   │
│  Region: asia-southeast2│  │  │  - user-avatars/                │   │
│  Backup: Daily          │  │  │                                 │   │
│                         │  │  │  CDN-backed URLs                │   │
│                         │  │  │  Automatic Scaling              │   │
│                         │  │  └─────────────────────────────────┘   │
│                         │  │                                         │
└─────────────────────────┘  └─────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagrams

### 1. Authentication Flow

```
┌─────────┐                                    ┌─────────┐
│ Client  │                                    │ Backend │
└────┬────┘                                    └────┬────┘
     │                                              │
     │  POST /auth/login                            │
     │  { email, password }                         │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                         ┌────▼────┐
     │                                         │ Validate│
     │                                         │ Input   │
     │                                         └────┬────┘
     │                                              │
     │                                         ┌────▼────┐
     │                                         │ Query   │
     │                                         │ User    │
     │                                         └────┬────┘
     │                                              │
     │                                         ┌────▼────┐
     │                                         │ Verify  │
     │                                         │ Password│
     │                                         └────┬────┘
     │                                              │
     │                                         ┌────▼────┐
     │                                         │Generate │
     │                                         │JWT Token│
     │                                         └────┬────┘
     │                                              │
     │  { success: true, token, user }              │
     │<─────────────────────────────────────────────┤
     │                                              │
     │  Store token in localStorage/SharedPrefs     │
     │                                              │
     │  Subsequent requests:                        │
     │  Authorization: Bearer <token>               │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                         ┌────▼────┐
     │                                         │ Verify  │
     │                                         │ Token   │
     │                                         └────┬────┘
     │                                              │
     │  { success: true, data }                     │
     │<─────────────────────────────────────────────┤
     │                                              │
```

### 2. Payment Verification Flow

```
┌─────────┐         ┌─────────┐         ┌──────────┐         ┌─────────┐
│ Tenant  │         │ Backend │         │PostgreSQL│         │Firebase │
│ (Mobile)│         │   API   │         │          │         │         │
└────┬────┘         └────┬────┘         └────┬─────┘         └────┬────┘
     │                   │                   │                    │
     │ 1. Upload Proof   │                   │                    │
     ├──────────────────>│                   │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Upload  │              │                    │
     │              │ to Cloud│              │                    │
     │              │ Storage │              │                    │
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Create  │              │                    │
     │              │ Payment │              │                    │
     │              │ Record  ├──────────────>│                    │
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Send    │              │                    │
     │              │ Notif   ├──────────────┼───────────────────>│
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │  { success }      │                   │                    │
     │<──────────────────┤                   │                    │
     │                   │                   │                    │
     │                                                             │
     │                                                             │
┌────▼────┐         ┌────┴────┐         ┌────┴─────┐         ┌────▼────┐
│ Admin   │         │ Backend │         │PostgreSQL│         │Firebase │
│  (Web)  │         │   API   │         │          │         │         │
└────┬────┘         └────┬────┘         └────┬─────┘         └────┬────┘
     │                   │                   │                    │
     │ 2. Get Pending    │                   │                    │
     ├──────────────────>│                   │                    │
     │                   ├──────────────────>│                    │
     │                   │                   │                    │
     │  { payments }     │                   │                    │
     │<──────────────────┤                   │                    │
     │                   │                   │                    │
     │ 3. Verify Payment │                   │                    │
     ├──────────────────>│                   │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Update  │              │                    │
     │              │ Payment │              │                    │
     │              │ Status  ├──────────────>│                    │
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Update  │              │                    │
     │              │ Bill    │              │                    │
     │              │ Status  ├──────────────>│                    │
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │              ┌────▼────┐              │                    │
     │              │ Send    │              │                    │
     │              │ Notif   ├──────────────┼───────────────────>│
     │              └────┬────┘              │                    │
     │                   │                   │                    │
     │  { success }      │                   │                    │
     │<──────────────────┤                   │                    │
     │                   │                   │                    │
```

### 3. Realtime Chat Flow

```
┌─────────┐                              ┌─────────┐
│ Tenant  │                              │Firebase │
│ (Mobile)│                              │Firestore│
└────┬────┘                              └────┬────┘
     │                                        │
     │  1. Listen to chat room                │
     │  stream: /chats/{roomId}/messages      │
     ├───────────────────────────────────────>│
     │                                        │
     │  2. Realtime updates                   │
     │<───────────────────────────────────────┤
     │                                        │
     │  3. Send message                       │
     │  { senderId, message, timestamp }      │
     ├───────────────────────────────────────>│
     │                                        │
     │  4. Message saved                      │
     │<───────────────────────────────────────┤
     │                                        │
     │                                        │
┌────▼────┐                              ┌────┴────┐
│ Admin   │                              │Firebase │
│  (Web)  │                              │Firestore│
└────┬────┘                              └────┬────┘
     │                                        │
     │  5. Receive realtime update            │
     │<───────────────────────────────────────┤
     │                                        │
     │  6. Reply message                      │
     │  { senderId, message, timestamp }      │
     ├───────────────────────────────────────>│
     │                                        │
     │  7. Message saved                      │
     │<───────────────────────────────────────┤
     │                                        │
     │                                        │
┌────▼────┐                              ┌────┴────┐
│ Tenant  │                              │Firebase │
│ (Mobile)│                              │Firestore│
└────┬────┘                              └────┬────┘
     │                                        │
     │  8. Receive realtime update            │
     │<───────────────────────────────────────┤
     │                                        │
```

---

## 🗄️ Database Architecture

### PostgreSQL Schema (Relational Data)

```
┌─────────────────────────────────────────────────────────────────┐
│                      POSTGRESQL SCHEMA                          │
└─────────────────────────────────────────────────────────────────┘

┌──────────┐         ┌──────────┐         ┌──────────┐
│  users   │         │  rooms   │         │ tenants  │
├──────────┤         ├──────────┤         ├──────────┤
│ id (PK)  │         │ id (PK)  │    ┌────│ id (PK)  │
│ email    │         │ nomor    │    │    │ user_id  │───┐
│ password │         │ tipe     │    │    │ kamar_id │───┼───┐
│ nama     │         │ harga    │◄───┘    │ nama     │   │   │
│ role     │         │ status   │         │ email    │   │   │
│ no_telp  │         │ deskripsi│         │ status   │   │   │
│ foto     │         │ fasilitas│         └──────────┘   │   │
└────┬─────┘         └──────────┘                        │   │
     │                                                    │   │
     │                                                    │   │
     │               ┌──────────────┐                    │   │
     │               │  contracts   │                    │   │
     │               ├──────────────┤                    │   │
     │               │ id (PK)      │                    │   │
     │          ┌────│ tenant_id    │◄───────────────────┘   │
     │          │    │ kamar_id     │◄───────────────────────┘
     │          │    │ tanggal_mulai│
     │          │    │ harga_per_bln│
     │          │    │ deposit      │
     │          │    │ status       │
     │          │    └──────┬───────┘
     │          │           │
     │          │           │
     │    ┌─────▼──────┐    │    ┌──────────────┐
     │    │   bills    │    │    │  payments    │
     │    ├────────────┤    │    ├──────────────┤
     │    │ id (PK)    │    │    │ id (PK)      │
     │    │ tenant_id  │◄───┘    │ bill_id      │───┐
     │    │ contract_id│◄────────│ tenant_id    │   │
     │    │ bulan      │         │ jumlah       │   │
     │    │ tahun      │         │ tanggal_bayar│   │
     │    │ jumlah     │◄────────│ bukti        │   │
     │    │ status     │         │ status       │   │
     │    │ jatuh_tempo│         │ verified_by  │───┼───┐
     │    └────────────┘         └──────────────┘   │   │
     │                                               │   │
     │                                               │   │
     │    ┌──────────────┐         ┌──────────────┐ │   │
     │    │ maintenance  │         │announcements │ │   │
     │    ├──────────────┤         ├──────────────┤ │   │
     │    │ id (PK)      │         │ id (PK)      │ │   │
     │    │ tenant_id    │         │ judul        │ │   │
     │    │ kamar_id     │         │ konten       │ │   │
     │    │ judul        │         │ kategori     │ │   │
     │    │ deskripsi    │         │ prioritas    │ │   │
     │    │ kategori     │         │ target       │ │   │
     │    │ prioritas    │         │ created_by   │◄┘   │
     │    │ status       │         │ is_active    │     │
     │    │ foto         │         └──────────────┘     │
     │    │ komentar     │                              │
     │    └──────────────┘                              │
     │                                                   │
     └───────────────────────────────────────────────────┘

Relationships:
- users 1:N tenants (one user can be one tenant)
- rooms 1:1 tenants (one room has one active tenant)
- tenants 1:N contracts (tenant can have multiple contracts over time)
- contracts 1:N bills (one contract generates monthly bills)
- bills 1:N payments (one bill can have multiple payment attempts)
- tenants 1:N maintenance (tenant can create multiple requests)
- users 1:N announcements (admin creates announcements)
```

### Firebase Firestore Schema (Realtime Data)

```
┌─────────────────────────────────────────────────────────────────┐
│                    FIRESTORE COLLECTIONS                        │
└─────────────────────────────────────────────────────────────────┘

chats/
├── {chatRoomId}/
│   ├── tenant_id: string
│   ├── admin_id: string
│   ├── tenant_name: string
│   ├── admin_name: string
│   ├── last_message: string
│   ├── last_message_time: timestamp
│   ├── unread_count_tenant: number
│   ├── unread_count_admin: number
│   ├── created_at: timestamp
│   ├── updated_at: timestamp
│   │
│   └── messages/ (subcollection)
│       ├── {messageId}/
│       │   ├── sender_id: string
│       │   ├── sender_name: string
│       │   ├── sender_role: string
│       │   ├── message: string
│       │   ├── image_url: string
│       │   ├── is_read: boolean
│       │   └── created_at: timestamp

notifications/
├── {notificationId}/
│   ├── user_id: string
│   ├── title: string
│   ├── body: string
│   ├── type: string (payment|maintenance|chat|announcement)
│   ├── data: object
│   ├── is_read: boolean
│   └── created_at: timestamp

maintenance_status/
├── {statusId}/
│   ├── maintenance_id: string
│   ├── status: string
│   ├── updated_by: string
│   ├── updated_by_name: string
│   ├── komentar: string
│   └── timestamp: timestamp

activity_logs/
├── {logId}/
│   ├── user_id: string
│   ├── user_name: string
│   ├── user_role: string
│   ├── action: string
│   ├── entity_type: string
│   ├── entity_id: string
│   ├── description: string
│   ├── ip_address: string
│   └── created_at: timestamp
```

---

## 🔐 Security Architecture

### 1. Authentication & Authorization

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                              │
└─────────────────────────────────────────────────────────────────┘

Layer 1: Network Security
├── HTTPS Only (TLS 1.2+)
├── CORS Configuration
└── Rate Limiting (100 req/15min)

Layer 2: Authentication
├── JWT Tokens (7 days expiry)
├── Bcrypt Password Hashing (10 rounds)
├── Token Verification Middleware
└── Refresh Token (optional)

Layer 3: Authorization
├── Role-Based Access Control (RBAC)
│   ├── Admin: Full access
│   └── Tenant: Limited access (own data only)
├── Resource Ownership Check
└── Permission Middleware

Layer 4: Input Validation
├── express-validator
├── Type Checking (TypeScript)
├── SQL Injection Prevention (Parameterized Queries)
└── XSS Prevention (Input Sanitization)

Layer 5: Data Protection
├── Password Never Stored Plain
├── Sensitive Data Encrypted
├── Database Connection Encrypted
└── File Upload Validation
```

### 2. API Security Flow

```
Request → HTTPS → CORS → Rate Limit → JWT Verify → Role Check → Input Validate → Execute → Response
```

---

## 📊 Performance Optimization

### 1. Database Optimization

```
- Indexes on Foreign Keys
- Connection Pooling (max 20 connections)
- Query Optimization (JOINs instead of N+1)
- Pagination (limit 20 per page)
- Caching (optional: Redis)
```

### 2. API Optimization

```
- Gzip Compression
- Response Caching Headers
- Lazy Loading
- Pagination
- Field Selection (only return needed fields)
```

### 3. Cloud Run Optimization

```
- Auto-scaling (0-100 instances)
- Cold Start Optimization
- Memory: 512MB - 2GB
- CPU: 1-2 vCPU
- Concurrency: 80 requests per instance
```

---

## 🚀 Deployment Architecture

### Development Environment

```
Local Machine
├── Backend: localhost:5000
├── Web: localhost:3000
├── Mobile: Android Emulator
├── PostgreSQL: localhost:5432
└── Firebase: Development Project
```

### Production Environment

```
Google Cloud Platform
├── Backend: Cloud Run (asia-southeast2)
│   ├── Auto-scaling: 0-100 instances
│   ├── Memory: 1GB
│   └── CPU: 1 vCPU
│
├── Web: App Engine (asia-southeast2)
│   ├── Auto-scaling
│   └── Standard Environment
│
├── Database: Cloud SQL (PostgreSQL 14)
│   ├── High Availability
│   ├── Automatic Backups (daily)
│   └── Private IP
│
├── Storage: Cloud Storage
│   ├── Bucket: kos-terpadu-files
│   └── CDN-backed
│
└── Firebase
    ├── Firestore (realtime)
    ├── Storage (files)
    └── Authentication (optional)
```

---

## 📈 Scalability Strategy

### Horizontal Scaling

```
Cloud Run Auto-scaling
├── Min Instances: 0 (cost optimization)
├── Max Instances: 100
├── Scale Up: When CPU > 60% or Memory > 70%
└── Scale Down: When idle for 15 minutes
```

### Database Scaling

```
Cloud SQL
├── Read Replicas (if needed)
├── Connection Pooling
├── Query Optimization
└── Vertical Scaling (increase CPU/RAM)
```

### Caching Strategy (Future)

```
Redis/Memcached
├── Session Cache
├── Query Result Cache
├── API Response Cache
└── TTL: 5-60 minutes
```

---

## 🔄 CI/CD Pipeline

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Code   │────>│  Build  │────>│  Test   │────>│ Deploy  │
│  Push   │     │ (Docker)│     │ (Jest)  │     │(Cloud   │
│ (GitHub)│     │         │     │         │     │ Run)    │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
                                                      │
                                                      ▼
                                              ┌───────────────┐
                                              │  Production   │
                                              │  Environment  │
                                              └───────────────┘
```

---

## 📝 Monitoring & Logging

### Monitoring

```
Google Cloud Monitoring
├── API Response Time
├── Error Rate
├── Request Count
├── Database Connections
└── Memory/CPU Usage
```

### Logging

```
Cloud Logging
├── Application Logs
├── Access Logs
├── Error Logs
└── Audit Logs
```

---

**Architecture Version:** 1.0  
**Last Updated:** 2024  
**Status:** Production Ready 🚀
