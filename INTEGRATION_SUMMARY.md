# KosTerpadu - Backend-Frontend Integration Summary

## Project Status: READY FOR TESTING 🚀

### Backend Status ✅
- **Location**: `D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-backend`
- **Status**: Running on port 5000 (PID 7492)
- **Framework**: Express.js + TypeScript
- **Database**: PostgreSQL (kosan)
- **Models**: 8 models (User, Room, Tenant, Bill, Payment, Maintenance, MaintenanceProgress, Announcement)
- **Controllers**: 8 controllers
- **Endpoints**: 57+ endpoints
- **Authentication**: JWT
- **CORS**: Configured for http://localhost:3000

### Frontend Status ✅
- **Location**: `D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-admin`
- **Status**: Ready to run
- **Framework**: Next.js 14 + TypeScript
- **UI**: TailwindCSS + Radix UI
- **Pages**: 12 pages implemented
- **Components**: 30+ components
- **State**: Zustand
- **API Client**: Axios (configured)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                              │
│                   http://localhost:3000                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Next.js Frontend (React)                   │    │
│  │  - 12 Pages (Login, Dashboard, Rooms, etc.)       │    │
│  │  - Zustand State Management                        │    │
│  │  - Axios HTTP Client                               │    │
│  │  - JWT Token in localStorage                       │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP Requests
                            │ Authorization: Bearer <token>
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Express.js Backend                        │
│                   http://localhost:5000                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         API Server (Express + TypeScript)          │    │
│  │  - 8 Controllers                                   │    │
│  │  - 57+ Endpoints                                   │    │
│  │  - JWT Authentication Middleware                   │    │
│  │  - CORS Middleware                                 │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SQL Queries
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Database                       │
│                   localhost:5432/kosan                       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Database Tables                            │    │
│  │  - users                                           │    │
│  │  - rooms                                           │    │
│  │  - tenants                                         │    │
│  │  - bills                                           │    │
│  │  - payments                                        │    │
│  │  - maintenance_reports                             │    │
│  │  - maintenance_progress                            │    │
│  │  - announcements                                   │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## API Integration Map

### Authentication Flow
```
Frontend                          Backend                      Database
--------                          -------                      --------
Login Form                        
  │                               
  ├─ POST /api/auth/login ───────▶ auth.controller.ts
  │  { email, password }           │
  │                                ├─ Validate credentials ───▶ users table
  │                                │                            │
  │                                │◀─ User data ───────────────┘
  │                                │
  │                                ├─ Generate JWT token
  │                                │
  │◀─ { user, token } ─────────────┘
  │
  ├─ Save to localStorage
  │  - kos_token
  │  - kos_user
  │
  └─ Redirect to /dashboard
```

### Data Fetching Flow
```
Frontend                          Backend                      Database
--------                          -------                      --------
Dashboard Page
  │
  ├─ GET /api/dashboard/stats ───▶ dashboard.controller.ts
  │  Authorization: Bearer token   │
  │                                ├─ Verify JWT token
  │                                │
  │                                ├─ Query statistics ────────▶ Multiple tables
  │                                │                            │
  │                                │◀─ Aggregated data ─────────┘
  │                                │
  │◀─ { stats } ───────────────────┘
  │
  └─ Display in UI
```

### CRUD Flow (Example: Rooms)
```
Frontend                          Backend                      Database
--------                          -------                      --------
Rooms Page
  │
  ├─ GET /api/rooms ──────────────▶ room.controller.ts
  │  Authorization: Bearer token   │
  │                                ├─ Verify JWT token
  │                                │
  │                                ├─ Query rooms ─────────────▶ rooms table
  │                                │                            │
  │                                │◀─ Rooms data ──────────────┘
  │                                │
  │◀─ { data: [...] } ─────────────┘
  │
  ├─ Display in DataTable
  │
  ├─ User clicks "Add Room"
  │
  ├─ POST /api/rooms ─────────────▶ room.controller.ts
  │  { roomNumber, price, ... }    │
  │  Authorization: Bearer token   ├─ Verify JWT token
  │                                │
  │                                ├─ Validate data
  │                                │
  │                                ├─ Insert room ─────────────▶ rooms table
  │                                │                            │
  │                                │◀─ New room ────────────────┘
  │                                │
  │◀─ { data: {...} } ─────────────┘
  │
  ├─ Show success toast
  │
  └─ Refresh table
```

## Endpoint Mapping

### Frontend Services → Backend Endpoints

#### 1. Auth Service (`services/auth.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
login()                  →   POST /api/auth/login            auth.controller.ts
logout()                 →   POST /api/auth/logout           auth.controller.ts
forgotPassword()         →   POST /api/auth/forgot-password  auth.controller.ts
resetPassword()          →   POST /api/auth/reset-password   auth.controller.ts
getProfile()             →   GET /api/auth/profile           auth.controller.ts
updateProfile()          →   PUT /api/auth/profile           auth.controller.ts
changePassword()         →   PUT /api/auth/change-password   auth.controller.ts
```

#### 2. Room Service (`services/room.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAll()                 →   GET /api/rooms                  room.controller.ts
getById()                →   GET /api/rooms/:id              room.controller.ts
create()                 →   POST /api/rooms                 room.controller.ts
update()                 →   PUT /api/rooms/:id              room.controller.ts
delete()                 →   DELETE /api/rooms/:id           room.controller.ts
```

#### 3. Tenant Service (`services/tenant.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAll()                 →   GET /api/tenants                tenant.controller.ts
getById()                →   GET /api/tenants/:id            tenant.controller.ts
create()                 →   POST /api/tenants               tenant.controller.ts
update()                 →   PUT /api/tenants/:id            tenant.controller.ts
delete()                 →   DELETE /api/tenants/:id         tenant.controller.ts
```

#### 4. Bill Service (`services/payment.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAllBills()            →   GET /api/bills                  bill.controller.ts
getBillById()            →   GET /api/bills/:id              bill.controller.ts
generateBills()          →   POST /api/bills/generate        bill.controller.ts
updateBill()             →   PUT /api/bills/:id              bill.controller.ts
```

#### 5. Payment Service (`services/payment.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAllPayments()         →   GET /api/payments               payment.controller.ts
getPaymentById()         →   GET /api/payments/:id           payment.controller.ts
verifyPayment()          →   PUT /api/payments/:id/verify    payment.controller.ts
rejectPayment()          →   PUT /api/payments/:id/reject    payment.controller.ts
```

#### 6. Maintenance Service (`services/maintenance.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAll()                 →   GET /api/maintenance            maintenance.controller.ts
getById()                →   GET /api/maintenance/:id        maintenance.controller.ts
updateStatus()           →   PUT /api/maintenance/:id        maintenance.controller.ts
addProgress()            →   POST /api/maintenance/:id/progress  maintenance.controller.ts
```

#### 7. Announcement Service (`services/announcement.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getAll()                 →   GET /api/announcements          announcement.controller.ts
getById()                →   GET /api/announcements/:id      announcement.controller.ts
create()                 →   POST /api/announcements         announcement.controller.ts
update()                 →   PUT /api/announcements/:id      announcement.controller.ts
delete()                 →   DELETE /api/announcements/:id   announcement.controller.ts
```

#### 8. Dashboard Service (`services/dashboard.service.ts`)
```typescript
Frontend Method              Backend Endpoint                 Controller
---------------              ----------------                 ----------
getStats()               →   GET /api/dashboard/stats        dashboard.controller.ts
getMonthlyIncome()       →   GET /api/dashboard/monthly-income  dashboard.controller.ts
getRecentActivities()    →   GET /api/dashboard/activities   dashboard.controller.ts
```

## Configuration Files

### Backend Configuration
```env
# .env (Backend)
PORT=5000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kosan
DB_USER=postgres
DB_PASSWORD=telorgobalgabul
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:3000
```

### Frontend Configuration
```env
# .env.local (Frontend)
NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

### Axios Configuration (Frontend)
```typescript
// lib/axios.ts
const api = axios.create({
  baseURL: "http://localhost:5000/api",
  headers: { "Content-Type": "application/json" },
  timeout: 15000,
});

// Auto-attach JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("kos_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Auto-redirect on 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("kos_token");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);
```

## Data Flow Examples

### Example 1: Login
```
1. User enters email & password in login form
2. Frontend validates with Zod schema
3. Frontend sends POST /api/auth/login
4. Backend validates credentials
5. Backend generates JWT token
6. Backend returns { user, token }
7. Frontend saves token to localStorage
8. Frontend saves user to Zustand store
9. Frontend redirects to /dashboard
```

### Example 2: View Rooms
```
1. User navigates to /rooms
2. Frontend sends GET /api/rooms with JWT token
3. Backend verifies JWT token
4. Backend queries rooms table
5. Backend returns rooms data
6. Frontend displays in DataTable
7. User can filter, search, paginate
```

### Example 3: Create Room
```
1. User clicks "Add Room" button
2. Frontend opens dialog with form
3. User fills form (roomNumber, price, etc.)
4. User submits form
5. Frontend validates with Zod schema
6. Frontend sends POST /api/rooms with data
7. Backend verifies JWT token
8. Backend validates data
9. Backend inserts to rooms table
10. Backend returns new room
11. Frontend shows success toast
12. Frontend refreshes table
```

### Example 4: Verify Payment
```
1. User navigates to /payments
2. Frontend loads pending payments
3. User clicks "Verify" on a payment
4. Frontend opens confirmation dialog
5. User confirms
6. Frontend sends PUT /api/payments/:id/verify
7. Backend verifies JWT token
8. Backend updates payment status to "verified"
9. Backend updates related bill status to "paid"
10. Backend returns updated payment
11. Frontend shows success toast
12. Frontend refreshes table
```

## Testing Checklist

### Backend Testing
- [ ] Server running on port 5000
- [ ] Database connected
- [ ] All endpoints accessible
- [ ] JWT authentication working
- [ ] CORS configured for localhost:3000
- [ ] Seed data loaded

### Frontend Testing
- [ ] Dev server running on port 3000
- [ ] Environment variables configured
- [ ] Can access login page
- [ ] Can login successfully
- [ ] Token saved to localStorage
- [ ] Dashboard loads with data
- [ ] All pages accessible

### Integration Testing
- [ ] Login flow works end-to-end
- [ ] Dashboard statistics load from backend
- [ ] CRUD operations work for all modules
- [ ] Search and filter work
- [ ] Pagination works
- [ ] Form validation works
- [ ] Error handling works
- [ ] Toast notifications show

## Quick Start Commands

### Terminal 1: Backend
```bash
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-backend"
npm run dev
```

### Terminal 2: Frontend
```bash
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-admin"
npm run dev
```

### Terminal 3: Test
```bash
# Open browser
start http://localhost:3000

# Or test with curl
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@kosterpadu.com\",\"password\":\"admin123\"}"
```

## Common Issues & Solutions

### Issue 1: CORS Error
**Error**: "CORS policy: No 'Access-Control-Allow-Origin' header"

**Solution**: Backend `.env` already configured with `CORS_ORIGIN=http://localhost:3000`. Restart backend if needed.

### Issue 2: 401 Unauthorized
**Error**: "Unauthorized" or auto-logout

**Solution**: Token expired or invalid. Login again.

### Issue 3: Connection Refused
**Error**: "ERR_CONNECTION_REFUSED"

**Solution**: Backend not running. Start backend with `npm run dev`.

### Issue 4: Empty Data
**Error**: Tables show "No data found"

**Solution**: Database not seeded. Run `npm run seed` in backend.

## Next Steps

1. ✅ Backend running
2. ✅ Frontend configured
3. ⏳ Start frontend: `npm run dev`
4. ⏳ Test login
5. ⏳ Test all modules
6. ⏳ Fix any issues
7. ⏳ Deploy to production

## Documentation Files

### Backend
- `Web/kos-terpadu-backend/README.md` - Backend documentation
- `Web/kos-terpadu-backend/.env` - Backend configuration

### Frontend
- `Web/kos-terpadu-admin/README.md` - Quick start
- `Web/kos-terpadu-admin/FRONTEND_DOCUMENTATION.md` - Complete docs
- `Web/kos-terpadu-admin/PROJECT_SUMMARY.md` - Project overview
- `Web/kos-terpadu-admin/DEVELOPER_GUIDE.md` - Developer reference
- `Web/kos-terpadu-admin/PRODUCTION_CHECKLIST.md` - Deployment guide
- `Web/kos-terpadu-admin/QUICK_START.md` - Testing guide
- `Web/kos-terpadu-admin/.env.local` - Frontend configuration

### Integration
- `INTEGRATION_SUMMARY.md` - This file

## Success Criteria

Project is ready when:
- ✅ Backend running without errors
- ✅ Frontend running without errors
- ✅ Login works
- ✅ All pages load
- ✅ All CRUD operations work
- ✅ No console errors
- ✅ No network errors

---

**Status**: READY FOR TESTING  
**Backend**: Running ✅  
**Frontend**: Configured ✅  
**Integration**: Ready ✅  
**Last Updated**: May 21, 2026
