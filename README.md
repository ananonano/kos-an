# 🏠 KosTerpadu - Sistem Manajemen Kos Terpadu

> **Proyek Praktikum TCC (Cloud Computing Technology)**  
> Sistem manajemen kos berbasis cloud dengan arsitektur modern

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue.svg)](https://www.postgresql.org/)

---

## 📋 Daftar Isi

- [Tentang Proyek](#-tentang-proyek)
- [Fitur Utama](#-fitur-utama)
- [Tech Stack](#-tech-stack)
- [Arsitektur](#-arsitektur)
- [Quick Start](#-quick-start)
- [Struktur Project](#-struktur-project)
- [Tim](#-tim)
- [Dokumentasi](#-dokumentasi)
- [License](#-license)

---

## 🎯 Tentang Proyek

**KosTerpadu** adalah aplikasi manajemen kos modern yang menyelesaikan 2 masalah utama:

1. **Sengketa Pembayaran** - Sistem pembayaran digital dengan bukti transfer dan verifikasi otomatis
2. **Lambatnya Respon Keluhan** - Sistem keluhan realtime dengan tracking status perbaikan

### Solusi:

- **Web Dashboard** untuk Pemilik Kos (Admin)
- **Mobile App** untuk Penyewa (Tenant)
- **1 Backend API** untuk kedua client

---

## ✨ Fitur Utama

### 🔐 Authentication & Authorization
- Login/Register dengan JWT
- Role-based access control (Admin/Tenant)
- Profile management

### 🏠 Manajemen Kamar
- CRUD kamar (Admin)
- Status kamar (kosong/terisi)
- Detail kamar (harga, fasilitas, foto)

### 👥 Manajemen Penyewa
- CRUD penyewa (Admin)
- Assign penyewa ke kamar
- Tracking kontrak sewa

### 💰 Pembayaran
- Generate tagihan bulanan otomatis
- Upload bukti pembayaran (Tenant)
- Verifikasi pembayaran (Admin)
- Riwayat pembayaran

### 🔧 Keluhan & Maintenance
- Buat keluhan dengan foto (Tenant)
- Update status keluhan (Admin)
- Priority levels (rendah/sedang/tinggi/urgent)
- Tracking realtime

### 💬 Chat Realtime
- Chat 1-on-1 admin & tenant
- Realtime messaging (Firebase)
- Message history

### 📢 Pengumuman
- Buat pengumuman (Admin)
- Target audience (semua/tenant/admin)
- Priority levels

### 📊 Dashboard & Reports
- Statistics overview
- Revenue reports
- Occupancy rate
- Payment analytics

---

## 🛠️ Tech Stack

### Frontend
- **Web:** Next.js 16 + TypeScript + Tailwind CSS
- **Mobile:** Flutter 3.0+ + Provider

### Backend
- **API:** Express.js + TypeScript
- **Auth:** JWT (JSON Web Tokens)

### Database
- **SQL:** PostgreSQL (Cloud SQL)
- **NoSQL:** Firebase Firestore
- **Storage:** Firebase Storage / Cloud Storage

### Deployment
- **Backend:** Cloud Run (Docker)
- **Web:** App Engine
- **Database:** Cloud SQL
- **Mobile:** APK Distribution

### DevOps
- **CI/CD:** Cloud Build
- **Monitoring:** Cloud Monitoring
- **Logging:** Cloud Logging

---

## 🏗️ Arsitektur

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                         │
├─────────────────────────────────────────────────────────┤
│  Web (Next.js)              Mobile (Flutter)            │
│  - Pemilik Kos              - Penyewa                   │
│  - Deploy: App Engine       - Build: APK                │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
               └──────────┬───────────────┘
                          │ HTTPS/REST API
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   API GATEWAY LAYER                     │
├─────────────────────────────────────────────────────────┤
│  Backend Express.js (TypeScript)                        │
│  - JWT Authentication                                   │
│  - Role-based Authorization                             │
│  - Deploy: Cloud Run (Docker)                           │
└──────────────┬──────────────────────────┬───────────────┘
               │                          │
       ┌───────┴────────┐        ┌────────┴─────────┐
       │                │        │                  │
       ▼                ▼        ▼                  ▼
┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐
│  PostgreSQL │  │   Firebase   │  │   Cloud Storage      │
│  (Cloud SQL)│  │  Firestore   │  │  (GCS Bucket)        │
└─────────────┘  └──────────────┘  └──────────────────────┘
```

Lihat [ARCHITECTURE.md](./ARCHITECTURE.md) untuk detail lengkap.

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Flutter 3.0+ (untuk mobile)
- Firebase Account

### 1. Clone Repository

```bash
git clone https://github.com/username/kos-terpadu.git
cd kos-terpadu
```

### 2. Setup Backend

```bash
cd Web/kos-terpadu-backend
npm install
cp .env.example .env
# Edit .env dengan credentials

# Create database
createdb kos_terpadu

# Run migration
npm run db:migrate

# Seed data (optional)
npm run db:seed

# Start server
npm run dev
```

Backend running on `http://localhost:5000`

### 3. Setup Web Frontend

```bash
cd Web/kos-terpadu-admin
npm install

# Create .env.local
echo "NEXT_PUBLIC_API_URL=http://localhost:5000/api" > .env.local

npm run dev
```

Web running on `http://localhost:3000`

### 4. Setup Mobile

```bash
cd Mobile
flutter pub get

# Edit lib/core/config/app_config.dart
# Set apiBaseUrl = 'http://10.0.2.2:5000/api'

flutter run
```

Lihat [QUICK_START.md](./QUICK_START.md) untuk panduan lengkap.

---

## 📁 Struktur Project

```
kos-terpadu/
├── Backend/                    # Backend documentation
│   └── README.md
│
├── Web/
│   ├── kos-terpadu-backend/   # Express.js API
│   │   ├── src/
│   │   │   ├── config/        # Database & Firebase config
│   │   │   ├── models/        # Database models (8 models)
│   │   │   ├── controllers/   # Request handlers
│   │   │   ├── middleware/    # Auth, error, upload
│   │   │   ├── routes/        # API routes
│   │   │   ├── types/         # TypeScript types
│   │   │   └── index.ts       # Entry point
│   │   ├── .env.example
│   │   └── package.json
│   │
│   └── kos-terpadu-admin/     # Next.js Admin Dashboard
│       ├── app/               # Next.js 16 app directory
│       ├── components/        # React components
│       ├── lib/               # Utilities
│       └── package.json
│
├── Mobile/                     # Flutter Mobile App
│   ├── lib/
│   │   ├── core/              # Config, constants, theme
│   │   ├── models/            # Data models
│   │   ├── services/          # API services
│   │   ├── controllers/       # State management
│   │   ├── views/             # UI screens
│   │   ├── widgets/           # Reusable widgets
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── docs/                       # Additional documentation
│
├── ARCHITECTURE.md             # System architecture
├── PROJECT_ROADMAP.md          # Development roadmap
├── PROJECT_SUMMARY.md          # Project overview
├── QUICK_START.md              # Setup guide
├── .gitignore
└── README.md                   # This file
```

---

## 👥 Tim

### Pembagian Tugas:

- **Backend Developer** - Express.js API + Database
- **Web Frontend Developer** - Next.js Admin Dashboard
- **Mobile Developer** - Flutter Mobile App
- **DevOps** - Cloud deployment & CI/CD

Lihat [PROJECT_ROADMAP.md](./PROJECT_ROADMAP.md) untuk detail tugas.

---

## 📚 Dokumentasi

### 🚀 Getting Started:
- [QUICK-START.md](./QUICK-START.md) - ⚡ Fast setup & testing guide
- [README.md](./README.md) - 📖 Project overview (file ini)
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 🏗️ System architecture
- [PROJECT_ROADMAP.md](./PROJECT_ROADMAP.md) - 🗺️ Development plan
- [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) - 📊 Project summary

### ☁️ Deployment & CI/CD:
- [CICD-SETUP.md](./CICD-SETUP.md) - 🔄 GitHub Actions auto-deploy guide
- [.github/workflows/](./github/workflows/) - 🤖 Deployment workflows

### 💾 Database & Migration:
- [DATA-MIGRATION.md](./DATA-MIGRATION.md) - 📦 PostgreSQL data migration guide
- [SCRIPTS-README.md](./SCRIPTS-README.md) - 🛠️ Migration scripts documentation
- [NETWORK-ISSUE-SOLUTION.md](./NETWORK-ISSUE-SOLUTION.md) - 🔌 Network connectivity solutions

### 📁 Component Documentation:
- [Backend/README.md](./Backend/README.md) - 🔧 Backend API documentation
- [Web/README.md](./Web/README.md) - 🌐 Web dashboard documentation
- [Mobile/README.md](./Mobile/README.md) - 📱 Mobile app documentation

---

## 📊 Progress

### Overall: 85% ✅ DEPLOYED TO PRODUCTION

- ✅ Backend API (100%) - LIVE on Cloud Run
- ✅ Database (100%) - PostgreSQL Cloud SQL + Migrations + Dummy Data
- ✅ Web Frontend (100%) - LIVE on Cloud Run
- ✅ CI/CD Pipeline (100%) - GitHub Actions configured
- ⏳ Mobile App (80%) - Need to update backend URL & build APK
- ⏳ Real Data Migration (0%) - Optional, scripts ready

### 🌐 Production URLs:
- **Backend:** https://kosan-backend-670153358279.asia-southeast2.run.app
- **Web:** https://kosan-web-670153358279.asia-southeast2.run.app
- **Database:** Cloud SQL PostgreSQL (34.50.122.143:5432)

### 🔑 Test Credentials (Dummy Data):
- **Admin:** admin@kosterpadu.com / admin123
- **Tenant:** budi@email.com / tenant123

Lihat [QUICK-START.md](./QUICK-START.md) untuk testing & [PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md) untuk detail progress.

---

## 🔐 Default Credentials

**Production (Cloud SQL - Dummy Data):**

| Role | Email | Password | Access |
|------|-------|----------|--------|
| **Admin** | admin@kosterpadu.com | admin123 | Web Dashboard |
| **Tenant** | budi@email.com | tenant123 | Mobile App |

**Additional Tenant Accounts:**
- ani@email.com / tenant123
- citra@email.com / tenant123
- doni@email.com / tenant123

**Note:** Credentials akan berubah setelah real data migration.

---

## 🚢 Deployment

### ✅ Production (LIVE)

| Service | Platform | URL | Status |
|---------|----------|-----|--------|
| **Backend API** | Cloud Run | https://kosan-backend-670153358279.asia-southeast2.run.app | ✅ LIVE |
| **Web Dashboard** | Cloud Run | https://kosan-web-670153358279.asia-southeast2.run.app | ✅ LIVE |
| **Database** | Cloud SQL | PostgreSQL (34.50.122.143:5432) | ✅ READY |
| **CI/CD** | GitHub Actions | Auto-deploy on push | ✅ ACTIVE |

### 🔄 CI/CD Pipeline

**Automatic deployment on:**
- Push to `main` branch with `Backend/**` changes → Deploy Backend
- Push to `main` branch with `Web/**` changes → Deploy Web

**Monitor deployments:**
- GitHub Actions: Repository → Actions tab
- GCP Console: https://console.cloud.google.com/run?project=g-43-491016

### 📱 Mobile Deployment

```bash
cd Mobile
# Update backend URL to production
# Edit lib/config/api_config.dart

flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 📖 Deployment Guides:
- [CICD-SETUP.md](./CICD-SETUP.md) - Complete CI/CD configuration
- [DATA-MIGRATION.md](./DATA-MIGRATION.md) - Database migration guide
- [QUICK-START.md](./QUICK-START.md) - Testing deployed services

---

## 🧪 Testing

### Backend
```bash
cd Web/kos-terpadu-backend
npm test
```

### Web
```bash
cd Web/kos-terpadu-admin
npm test
```

### Mobile
```bash
cd Mobile
flutter test
```

---

## 📝 API Documentation

API documentation available at:
- Development: `http://localhost:5000/api-docs` (coming soon)
- Postman Collection: [Link to collection]

Base URL: `http://localhost:5000/api`

### Main Endpoints:
- `POST /auth/login` - Login
- `GET /rooms` - Get all rooms
- `GET /tenants` - Get all tenants
- `GET /bills` - Get all bills
- `POST /payments` - Create payment
- `GET /maintenance` - Get maintenance requests

Total: **40+ endpoints**

---

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Dosen Pembimbing:** [Nama Dosen]
- **Universitas:** [Nama Universitas]
- **Mata Kuliah:** Praktikum TCC (Cloud Computing Technology)
- **Semester:** 6

---

## 📞 Contact

**Project Lead:** [Your Name]
- Email: [your.email@example.com]
- GitHub: [@yourusername](https://github.com/yourusername)

**Project Link:** [https://github.com/username/kos-terpadu](https://github.com/username/kos-terpadu)

---

## 🎓 Academic Context

Proyek ini dibuat untuk memenuhi tugas Praktikum TCC dengan fokus pada:
- ✅ Cloud-native architecture
- ✅ Microservices principles
- ✅ Docker containerization
- ✅ Google Cloud Platform deployment
- ✅ RESTful API design
- ✅ Database design (SQL & NoSQL)

---

**Built with ❤️ for TCC Practicum Project**

---

## 📸 Screenshots

Coming soon...

---

## 🗺️ Roadmap

- [x] Backend foundation
- [x] Database schema
- [x] Mobile app structure
- [ ] Complete API endpoints
- [ ] Web dashboard
- [ ] Firebase integration
- [ ] Cloud deployment
- [ ] CI/CD pipeline
- [ ] Production release

Lihat [PROJECT_ROADMAP.md](./PROJECT_ROADMAP.md) untuk detail.

---

**Last Updated:** 2024  
**Version:** 1.0.0  
**Status:** 🟡 In Development
