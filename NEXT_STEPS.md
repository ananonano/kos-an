# Next Steps - KosTerpadu Development

## Status Saat Ini

### ✅ Completed
1. **Backend Structure** - 100% Complete
   - 8 Models dengan full CRUD operations
   - 8 Controllers dengan 57+ endpoints
   - Complete routes dengan authentication
   - Migration & seed scripts ready
   - TypeScript types & interfaces
   - Error handling & validation

2. **Documentation** - 100% Complete
   - API Documentation (57+ endpoints)
   - Architecture documentation
   - Project roadmap
   - Quick start guide
   - Database schema

3. **Mobile App** - 80% Complete (by teammate)
   - Basic structure exists
   - Needs integration testing

### 🔄 In Progress
1. **Web Frontend** - 20% Complete
   - Basic Next.js setup exists
   - Needs page implementation

### ⏳ Not Started
1. **Backend Testing**
2. **Web Frontend Pages**
3. **Integration Testing**
4. **Deployment**

---

## Langkah Selanjutnya

### STEP 1: Test Backend API (PRIORITAS TINGGI)

**Tujuan:** Pastikan semua endpoint backend berfungsi dengan baik

**Tasks:**
1. Setup database dan run migration
2. Run seed untuk data dummy
3. Start backend server
4. Test semua endpoint dengan Postman

**Instruksi Detail:**

```bash
# 1. Navigate ke backend
cd Web/kos-terpadu-backend

# 2. Install dependencies (jika belum)
npm install

# 3. Setup .env file
# Copy .env.example ke .env dan isi dengan credentials database

# 4. Create database
createdb -U postgres kos_terpadu

# 5. Run migration
npm run migrate

# 6. Run seed
npm run seed

# 7. Start server
npm run dev
```

**Testing Checklist:**
- [ ] Health check endpoint works
- [ ] Login dengan admin account works
- [ ] Login dengan tenant account works
- [ ] Get all rooms works
- [ ] Create room works (admin only)
- [ ] Get all tenants works
- [ ] Create tenant works
- [ ] Get all bills works
- [ ] Create bill works
- [ ] Generate monthly bills works
- [ ] Submit payment works
- [ ] Verify payment works (admin only)
- [ ] Create maintenance request works
- [ ] Update maintenance status works
- [ ] Get dashboard statistics works

**Expected Result:**
- Semua endpoint return response yang benar
- Authentication & authorization berfungsi
- Data tersimpan di database dengan benar

---

### STEP 2: Build Web Frontend Pages

**Tujuan:** Buat halaman web admin untuk manage kos

**Priority Pages:**
1. Login Page
2. Dashboard Page
3. Rooms Management Page
4. Tenants Management Page
5. Bills Management Page
6. Payments Verification Page
7. Maintenance Requests Page

**Tech Stack:**
- Next.js 14 (App Router)
- TailwindCSS
- Axios untuk API calls
- React Hook Form untuk forms
- Zustand untuk state management

**Design System:**
- Primary Color: Blue (#3B82F6)
- Secondary Color: Green (#10B981)
- Danger Color: Red (#EF4444)
- Warning Color: Amber (#F59E0B)

**Instruksi:**

```bash
# 1. Navigate ke web frontend
cd Web/kos-terpadu-admin

# 2. Install dependencies
npm install

# 3. Setup .env.local
# NEXT_PUBLIC_API_URL=http://localhost:5000/api

# 4. Start dev server
npm run dev
```

**Page Structure:**

```
app/
├── (auth)/
│   └── login/
│       └── page.tsx          # Login page
├── (dashboard)/
│   ├── layout.tsx            # Dashboard layout with sidebar
│   ├── page.tsx              # Dashboard home
│   ├── rooms/
│   │   ├── page.tsx          # Rooms list
│   │   ├── create/
│   │   │   └── page.tsx      # Create room
│   │   └── [id]/
│   │       └── edit/
│   │           └── page.tsx  # Edit room
│   ├── tenants/
│   │   ├── page.tsx          # Tenants list
│   │   └── ...
│   ├── bills/
│   │   ├── page.tsx          # Bills list
│   │   └── ...
│   ├── payments/
│   │   ├── page.tsx          # Payments list
│   │   └── ...
│   └── maintenance/
│       ├── page.tsx          # Maintenance list
│       └── ...
└── api/                      # API route handlers (optional)
```

**Components to Build:**

```
components/
├── layout/
│   ├── Sidebar.tsx
│   ├── Header.tsx
│   └── Footer.tsx
├── ui/
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Table.tsx
│   ├── Modal.tsx
│   ├── Card.tsx
│   └── Badge.tsx
├── forms/
│   ├── RoomForm.tsx
│   ├── TenantForm.tsx
│   └── BillForm.tsx
└── features/
    ├── dashboard/
    │   ├── StatsCard.tsx
    │   └── RecentActivity.tsx
    ├── rooms/
    │   └── RoomCard.tsx
    └── payments/
        └── PaymentVerification.tsx
```

---

### STEP 3: Integration Testing

**Tujuan:** Test integrasi antara frontend dan backend

**Tasks:**
1. Test login flow dari web
2. Test CRUD operations dari web
3. Test file upload
4. Test real-time updates (jika ada)
5. Test error handling

**Testing Scenarios:**

**Scenario 1: Admin Login & Dashboard**
1. Buka web di browser
2. Login dengan admin credentials
3. Verify redirect ke dashboard
4. Verify statistics ditampilkan dengan benar
5. Verify recent activities ditampilkan

**Scenario 2: Room Management**
1. Navigate ke Rooms page
2. Verify list rooms ditampilkan
3. Click "Add Room"
4. Fill form dan submit
5. Verify room baru muncul di list
6. Edit room
7. Delete room

**Scenario 3: Payment Verification**
1. Login sebagai tenant di mobile
2. Submit payment dengan bukti transfer
3. Login sebagai admin di web
4. Navigate ke Payments page
5. Verify payment baru muncul dengan status "menunggu verifikasi"
6. Click "Verify"
7. Verify status berubah menjadi "lunas"
8. Verify bill status juga berubah menjadi "lunas"

---

### STEP 4: Mobile Integration Testing

**Tujuan:** Test mobile app dengan backend yang sudah jadi

**Tasks:**
1. Update API base URL di mobile app
2. Test login flow
3. Test view bills
4. Test submit payment
5. Test create maintenance request
6. Test view announcements

**Instruksi:**

```bash
# 1. Navigate ke mobile
cd Mobile

# 2. Update API URL
# Edit lib/core/config/app_config.dart
# Change apiBaseUrl to your backend URL

# 3. Run app
flutter run
```

**Testing Checklist:**
- [ ] Login works
- [ ] View profile works
- [ ] View bills works
- [ ] Submit payment with photo works
- [ ] View payment status works
- [ ] Create maintenance request with photo works
- [ ] View maintenance status works
- [ ] View announcements works
- [ ] Logout works

---

### STEP 5: Deployment Preparation

**Tujuan:** Siapkan aplikasi untuk deployment ke Google Cloud

**Tasks:**

**5.1 Setup Cloud SQL (PostgreSQL)**
```bash
# Create Cloud SQL instance
gcloud sql instances create kos-terpadu-db \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=asia-southeast2

# Create database
gcloud sql databases create kos_terpadu \
  --instance=kos-terpadu-db

# Create user
gcloud sql users create kos_admin \
  --instance=kos-terpadu-db \
  --password=your_secure_password
```

**5.2 Deploy Backend to Cloud Run**
```bash
# Navigate to backend
cd Web/kos-terpadu-backend

# Create Dockerfile (if not exists)
# Build and push
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/kos-terpadu-backend

# Deploy
gcloud run deploy kos-terpadu-backend \
  --image gcr.io/YOUR_PROJECT_ID/kos-terpadu-backend \
  --platform managed \
  --region asia-southeast2 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_HOST=CLOUD_SQL_IP,DATABASE_NAME=kos_terpadu
```

**5.3 Deploy Web to App Engine**
```bash
# Navigate to web
cd Web/kos-terpadu-admin

# Create app.yaml
# Deploy
gcloud app deploy
```

**5.4 Setup Cloud Storage**
```bash
# Create bucket for file uploads
gsutil mb -l asia-southeast2 gs://kos-terpadu-files

# Set CORS
gsutil cors set cors.json gs://kos-terpadu-files
```

---

## Timeline Estimasi

### Week 1: Backend Testing & Bug Fixes
- Day 1-2: Setup database, run migration & seed
- Day 3-4: Test all endpoints dengan Postman
- Day 5-7: Fix bugs yang ditemukan

### Week 2: Web Frontend Development
- Day 1-2: Setup project, build layout & components
- Day 3-4: Build authentication & dashboard
- Day 5-7: Build CRUD pages (rooms, tenants, bills)

### Week 3: Integration & Testing
- Day 1-2: Integration testing web + backend
- Day 3-4: Mobile integration testing
- Day 5-7: Bug fixes & improvements

### Week 4: Deployment & Documentation
- Day 1-2: Setup Cloud SQL & Cloud Storage
- Day 3-4: Deploy backend & web
- Day 5-6: Final testing di production
- Day 7: Documentation & presentation prep

---

## Command Cheatsheet

### Backend Commands
```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Start production server

# Database
npm run migrate          # Run migrations
npm run seed             # Seed database
npm run db:reset         # Reset database (drop & recreate)

# Testing
npm test                 # Run tests
npm run test:watch       # Run tests in watch mode
```

### Web Frontend Commands
```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Start production server

# Linting
npm run lint             # Run ESLint
npm run format           # Format with Prettier
```

### Mobile Commands
```bash
# Development
flutter run              # Run app
flutter run -d chrome    # Run on web
flutter build apk        # Build APK

# Testing
flutter test             # Run tests
flutter analyze          # Analyze code
```

### Git Commands
```bash
# Daily workflow
git pull origin main     # Get latest changes
git checkout -b feature/your-feature  # Create feature branch
git add .                # Stage changes
git commit -m "message"  # Commit changes
git push origin feature/your-feature  # Push to remote

# Before merge
git checkout main
git pull origin main
git checkout feature/your-feature
git merge main           # Merge main into feature
# Resolve conflicts if any
git push origin feature/your-feature
```

---

## Tips & Best Practices

### Backend Development
1. Selalu test endpoint setelah membuat perubahan
2. Gunakan transaction untuk operasi yang melibatkan multiple tables
3. Validate input di controller sebelum pass ke model
4. Handle error dengan proper HTTP status codes
5. Log error untuk debugging

### Frontend Development
1. Gunakan TypeScript untuk type safety
2. Buat reusable components
3. Implement loading states
4. Handle error dengan user-friendly messages
5. Optimize images dan assets

### Mobile Development
1. Test di real device, bukan hanya emulator
2. Handle network errors gracefully
3. Implement offline mode jika memungkinkan
4. Optimize image uploads
5. Test di berbagai screen sizes

### Git Workflow
1. Commit often dengan descriptive messages
2. Pull sebelum push untuk avoid conflicts
3. Review code sebelum merge
4. Gunakan feature branches
5. Keep main branch stable

---

## Troubleshooting Common Issues

### Issue: Backend tidak bisa connect ke database
**Solution:**
1. Check PostgreSQL is running
2. Check credentials di .env
3. Check database exists
4. Check firewall settings

### Issue: CORS error di frontend
**Solution:**
1. Check CORS_ORIGIN di backend .env
2. Add proper CORS headers di backend
3. Check API URL di frontend .env

### Issue: JWT token expired
**Solution:**
1. Login ulang untuk get new token
2. Implement token refresh mechanism
3. Increase JWT_EXPIRES_IN di .env

### Issue: File upload fails
**Solution:**
1. Check file size limit
2. Check file type allowed
3. Check storage bucket permissions
4. Check network connection

---

## Resources

### Documentation
- Express.js: https://expressjs.com/
- Next.js: https://nextjs.org/docs
- Flutter: https://docs.flutter.dev/
- PostgreSQL: https://www.postgresql.org/docs/
- Firebase: https://firebase.google.com/docs

### Tools
- Postman: https://www.postman.com/
- pgAdmin: https://www.pgadmin.org/
- VS Code: https://code.visualstudio.com/
- Git: https://git-scm.com/

### Google Cloud
- Cloud Run: https://cloud.google.com/run/docs
- Cloud SQL: https://cloud.google.com/sql/docs
- App Engine: https://cloud.google.com/appengine/docs
- Cloud Storage: https://cloud.google.com/storage/docs

---

## Questions?

Jika ada pertanyaan atau stuck di suatu step:
1. Check documentation terlebih dahulu
2. Search di Google/Stack Overflow
3. Ask team lead atau teammate
4. Create issue di GitHub repository

---

**Good luck! 🚀**
