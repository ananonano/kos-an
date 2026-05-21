# 🏠 KosTerpadu Backend API

Backend REST API untuk sistem manajemen kos terpadu menggunakan Express.js + TypeScript + PostgreSQL + Firebase.

## 📋 Table of Contents

- [Tech Stack](#tech-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Database Setup](#database-setup)
- [API Endpoints](#api-endpoints)
- [Deployment](#deployment)
- [Team Collaboration](#team-collaboration)

---

## 🛠️ Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** PostgreSQL (Cloud SQL)
- **Realtime DB:** Firebase Firestore
- **Storage:** Firebase Storage / Cloud Storage
- **Authentication:** JWT (JSON Web Tokens)
- **Validation:** express-validator
- **Security:** helmet, cors, bcryptjs
- **File Upload:** multer

---

## ✨ Features

### Core Features
- ✅ JWT Authentication & Authorization
- ✅ Role-based Access Control (Admin/Tenant)
- ✅ RESTful API Design
- ✅ Input Validation
- ✅ Error Handling
- ✅ Rate Limiting
- ✅ CORS Configuration
- ✅ File Upload (Images)

### Business Features
- ✅ User Management (Admin & Tenant)
- ✅ Room Management (CRUD)
- ✅ Tenant Management (CRUD)
- ✅ Contract Management
- ✅ Bill Generation & Management
- ✅ Payment Processing & Verification
- ✅ Maintenance Request Management
- ✅ Announcement System
- ✅ Dashboard Statistics

---

## 📂 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts          # PostgreSQL connection
│   │   ├── firebase.ts          # Firebase Admin SDK
│   │   ├── migrate.ts           # Database migration script
│   │   └── seed.ts              # Database seeding script
│   │
│   ├── models/                  # Database models
│   │   ├── user.model.ts
│   │   ├── room.model.ts
│   │   ├── tenant.model.ts
│   │   ├── contract.model.ts
│   │   ├── bill.model.ts
│   │   ├── payment.model.ts
│   │   ├── maintenance.model.ts
│   │   ├── announcement.model.ts
│   │   └── index.ts
│   │
│   ├── controllers/             # Request handlers
│   │   ├── auth.controller.ts
│   │   ├── room.controller.ts
│   │   ├── tenant.controller.ts
│   │   ├── bill.controller.ts
│   │   ├── payment.controller.ts
│   │   ├── maintenance.controller.ts
│   │   ├── announcement.controller.ts
│   │   └── dashboard.controller.ts
│   │
│   ├── middleware/              # Express middleware
│   │   ├── auth.middleware.ts   # JWT verification
│   │   ├── error.middleware.ts  # Error handling
│   │   └── upload.middleware.ts # File upload
│   │
│   ├── routes/                  # API routes
│   │   ├── auth.routes.ts
│   │   ├── room.routes.ts
│   │   ├── tenant.routes.ts
│   │   ├── bill.routes.ts
│   │   ├── payment.routes.ts
│   │   ├── maintenance.routes.ts
│   │   ├── announcement.routes.ts
│   │   ├── dashboard.routes.ts
│   │   └── index.ts
│   │
│   ├── types/                   # TypeScript types
│   │   └── index.ts
│   │
│   └── index.ts                 # App entry point
│
├── .env.example                 # Environment variables template
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

---

## 🚀 Setup & Installation

### Prerequisites
- Node.js 18+ & npm
- PostgreSQL 14+
- Firebase Project (for Firestore & Storage)

### 1. Clone & Install

```bash
cd backend
npm install
```

### 2. Environment Variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env`:

```env
# Server
PORT=5000
NODE_ENV=development

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kos_terpadu
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d

# Firebase Admin SDK
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY_ID=your_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your_project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com

# CORS
CORS_ORIGIN=http://localhost:3000
```

### 3. Database Setup

Create PostgreSQL database:

```bash
createdb kos_terpadu
```

Or using psql:

```sql
CREATE DATABASE kos_terpadu;
```

### 4. Run Migration

```bash
npm run db:migrate
```

This will create all tables:
- users
- rooms
- tenants
- contracts
- bills
- payments
- maintenance
- announcements

### 5. Seed Database (Optional)

```bash
npm run db:seed
```

This will create dummy data for testing.

**Default Credentials:**
- Admin: `admin@kosterpadu.com` / `admin123`
- Tenant: `budi@email.com` / `tenant123`

### 6. Run Development Server

```bash
npm run dev
```

Server will run on `http://localhost:5000`

---

## 🗄️ Database Setup

### PostgreSQL Schema

**8 Main Tables:**

1. **users** - User accounts (admin & tenant)
2. **rooms** - Room information
3. **tenants** - Tenant details
4. **contracts** - Rental contracts
5. **bills** - Monthly bills
6. **payments** - Payment records
7. **maintenance** - Maintenance requests
8. **announcements** - System announcements

### Firebase Firestore Collections

**5 Collections for Realtime Data:**

1. **chats** - Chat rooms
2. **messages** - Chat messages (subcollection)
3. **notifications** - User notifications
4. **maintenance_status** - Realtime maintenance updates
5. **activity_logs** - Activity tracking

### Firebase Storage

**File Storage:**
- `/maintenance/{id}/` - Maintenance photos
- `/payments/{id}/` - Payment proofs
- `/users/{id}/` - Profile pictures

---

## 📡 API Endpoints

### Base URL
```
Development: http://localhost:5000/api
Production: https://your-backend-url.com/api
```

### Authentication

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/register` | Register new user | - |
| POST | `/auth/login` | Login user | - |
| POST | `/auth/logout` | Logout user | ✅ |
| GET | `/auth/me` | Get current user | ✅ |
| PUT | `/auth/profile/:id` | Update profile | ✅ |

### Rooms

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/rooms` | Get all rooms | - | - |
| GET | `/rooms/:id` | Get room by ID | - | - |
| POST | `/rooms` | Create room | ✅ | Admin |
| PUT | `/rooms/:id` | Update room | ✅ | Admin |
| DELETE | `/rooms/:id` | Delete room | ✅ | Admin |

### Tenants

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/tenants` | Get all tenants | ✅ | Admin |
| GET | `/tenants/:id` | Get tenant by ID | ✅ | Admin/Owner |
| POST | `/tenants` | Create tenant | ✅ | Admin |
| PUT | `/tenants/:id` | Update tenant | ✅ | Admin |
| DELETE | `/tenants/:id` | Delete tenant | ✅ | Admin |

### Bills

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/bills` | Get all bills | ✅ | Admin/Owner |
| GET | `/bills/:id` | Get bill by ID | ✅ | Admin/Owner |
| POST | `/bills` | Create bill | ✅ | Admin |
| POST | `/bills/generate` | Generate monthly bills | ✅ | Admin |
| PUT | `/bills/:id` | Update bill | ✅ | Admin |
| DELETE | `/bills/:id` | Delete bill | ✅ | Admin |

### Payments

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/payments` | Get all payments | ✅ | Admin/Owner |
| GET | `/payments/:id` | Get payment by ID | ✅ | Admin/Owner |
| POST | `/payments` | Create payment | ✅ | Tenant |
| PUT | `/payments/:id/verify` | Verify payment | ✅ | Admin |
| PUT | `/payments/:id/reject` | Reject payment | ✅ | Admin |
| POST | `/payments/:id/upload` | Upload proof | ✅ | Tenant |

### Maintenance

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/maintenance` | Get all requests | ✅ | Admin/Owner |
| GET | `/maintenance/:id` | Get request by ID | ✅ | Admin/Owner |
| POST | `/maintenance` | Create request | ✅ | Tenant |
| PUT | `/maintenance/:id` | Update status | ✅ | Admin |
| DELETE | `/maintenance/:id` | Delete request | ✅ | Admin |

### Announcements

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/announcements` | Get all announcements | ✅ | All |
| GET | `/announcements/:id` | Get announcement by ID | ✅ | All |
| POST | `/announcements` | Create announcement | ✅ | Admin |
| PUT | `/announcements/:id` | Update announcement | ✅ | Admin |
| DELETE | `/announcements/:id` | Delete announcement | ✅ | Admin |

### Dashboard

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/dashboard/stats` | Get statistics | ✅ | Admin |
| GET | `/dashboard/revenue` | Get revenue data | ✅ | Admin |
| GET | `/dashboard/occupancy` | Get occupancy rate | ✅ | Admin |

**Total: 40+ Endpoints** ✅

---

## 🚢 Deployment

### Deploy to Cloud Run (Docker)

1. **Create Dockerfile:**

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 5000

CMD ["npm", "start"]
```

2. **Build & Deploy:**

```bash
# Build Docker image
gcloud builds submit --tag gcr.io/PROJECT_ID/kos-backend

# Deploy to Cloud Run
gcloud run deploy kos-backend \
  --image gcr.io/PROJECT_ID/kos-backend \
  --platform managed \
  --region asia-southeast2 \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production"
```

3. **Connect to Cloud SQL:**

Add Cloud SQL connection in Cloud Run:

```bash
--add-cloudsql-instances=PROJECT_ID:REGION:INSTANCE_NAME
```

Update `.env`:

```env
DB_HOST=/cloudsql/PROJECT_ID:REGION:INSTANCE_NAME
```

---

## 👥 Team Collaboration

### For Backend Developer

**Your Tasks:**
1. ✅ Complete all controllers (use models yang udah ada)
2. ✅ Add input validation (express-validator)
3. ✅ Test all endpoints (Postman/Thunder Client)
4. ✅ Write API documentation
5. ✅ Setup Firebase Admin SDK
6. ✅ Deploy to Cloud Run

**Priority Order:**
1. Auth endpoints (login, register)
2. Room & Tenant CRUD
3. Bill & Payment flow
4. Maintenance requests
5. Dashboard statistics

### For Web Frontend Developer

**What You Need:**
- Base URL: `http://localhost:5000/api`
- Auth: JWT token in `Authorization: Bearer <token>` header
- All endpoints documented above
- Response format: `{ success: boolean, message: string, data: any }`

**Start With:**
1. Login page
2. Dashboard (statistics)
3. Room management
4. Tenant management
5. Payment verification

### For Mobile Developer

**What You Need:**
- Same API as Web (shared backend)
- Firebase SDK for realtime features
- Image upload for maintenance photos
- Push notifications (optional)

**Start With:**
1. Login/Register
2. Room list
3. Bill list
4. Payment upload
5. Maintenance request

### For DevOps

**Your Tasks:**
1. Setup Cloud SQL (PostgreSQL)
2. Setup Firebase project
3. Deploy backend to Cloud Run
4. Deploy web to App Engine
5. Setup CI/CD (Cloud Build)
6. Configure domain & SSL

---

## 📝 Notes

### Security
- All passwords hashed with bcrypt
- JWT tokens expire in 7 days
- Rate limiting: 100 req/15min
- CORS configured for allowed origins
- Input validation on all endpoints

### Performance
- Database indexes on foreign keys
- Connection pooling (max 20)
- Pagination on list endpoints
- Efficient queries with JOINs

### Best Practices
- TypeScript for type safety
- Modular architecture (MVC)
- Error handling middleware
- Consistent response format
- Environment variables for config

---

## 🆘 Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
pg_isready

# Check connection string
psql -h localhost -U postgres -d kos_terpadu
```

### Migration Failed
```bash
# Drop and recreate database
dropdb kos_terpadu
createdb kos_terpadu
npm run db:migrate
```

### Port Already in Use
```bash
# Kill process on port 5000
lsof -ti:5000 | xargs kill -9
```

---

## 📞 Support

- **Backend Lead:** [Your Name]
- **Documentation:** `/docs` folder
- **API Testing:** Postman collection available

---

**Built with ❤️ for TCC Practicum Project**
