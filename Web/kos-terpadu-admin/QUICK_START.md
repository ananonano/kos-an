# Quick Start Guide - Testing Backend Connection

## Status Check

✅ **Backend**: Running on port 5000 (PID 7492)  
✅ **Frontend**: Ready to connect  
✅ **Environment**: Configured  

## Step-by-Step Testing

### 1. Start Frontend

```bash
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-admin"
npm run dev
```

Frontend akan running di: `http://localhost:3000`

### 2. Test Login

1. Buka browser: `http://localhost:3000`
2. Akan auto-redirect ke `/login`
3. Login dengan credentials:
   ```
   Email: admin@kosterpadu.com
   Password: admin123
   ```

### 3. Verify Connection

Setelah login berhasil, cek:
- ✅ Dashboard muncul dengan data
- ✅ Sidebar navigation berfungsi
- ✅ Semua halaman bisa diakses
- ✅ Data dari backend muncul

### 4. Test Each Module

#### A. Dashboard
- Buka `/dashboard`
- Cek apakah statistik muncul
- Cek apakah grafik muncul

#### B. Rooms (Kamar)
- Buka `/rooms`
- Cek list kamar
- Test filter by status
- Test search
- Test add new room
- Test edit room
- Test delete room

#### C. Tenants (Penghuni)
- Buka `/tenants`
- Cek list penghuni
- Test filter by status
- Test search
- Test add new tenant
- Test edit tenant
- Test delete tenant

#### D. Bills (Tagihan)
- Buka `/bills`
- Cek list tagihan
- Test filter by status
- Test filter by month/year
- Test generate bills

#### E. Payments (Pembayaran)
- Buka `/payments`
- Cek list pembayaran
- Test verify payment
- Test reject payment

#### F. Maintenance (Perbaikan)
- Buka `/maintenance`
- Cek list laporan
- Test update status
- Test add progress

#### G. Announcements (Pengumuman)
- Buka `/announcements`
- Test create announcement
- Test edit announcement
- Test delete announcement

## Troubleshooting

### Issue 1: Login Failed
**Error**: "Network Error" atau "Cannot connect to server"

**Solution**:
```bash
# Check if backend is running
netstat -ano | findstr :5000

# If not running, start backend
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-backend"
npm run dev
```

### Issue 2: CORS Error
**Error**: "CORS policy: No 'Access-Control-Allow-Origin' header"

**Solution**:
Backend `.env` sudah configured dengan `CORS_ORIGIN=http://localhost:3000`
Restart backend jika perlu.

### Issue 3: 401 Unauthorized
**Error**: "Unauthorized" atau auto-logout

**Solution**:
- Token expired, login ulang
- Check JWT_SECRET di backend `.env`

### Issue 4: Data Not Loading
**Error**: Empty tables atau "No data found"

**Solution**:
```bash
# Seed database
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-backend"
npm run seed
```

## API Endpoints Test

### Manual Test dengan cURL

#### 1. Test Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"admin@kosterpadu.com\",\"password\":\"admin123\"}"
```

Expected response:
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 2. Test Get Rooms (with token)
```bash
curl -X GET http://localhost:5000/api/rooms \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### 3. Test Dashboard Stats
```bash
curl -X GET http://localhost:5000/api/dashboard/stats \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Browser DevTools Check

### 1. Network Tab
- Open DevTools (F12)
- Go to Network tab
- Filter by XHR/Fetch
- Check API requests:
  - Status should be 200 (success)
  - Response should have data

### 2. Console Tab
- Should have no errors
- Check for any warnings

### 3. Application Tab
- Check localStorage:
  - `kos_token` should exist
  - `kos_user` should exist

## Expected Behavior

### After Login Success:
1. Token saved to localStorage
2. User data saved to localStorage
3. Redirect to `/dashboard`
4. Sidebar shows user info
5. Dashboard loads statistics

### Navigation:
- All menu items clickable
- Pages load without errors
- Data displays correctly
- Forms work properly

### CRUD Operations:
- Create: Form validation works, success toast shows
- Read: Data loads in tables
- Update: Edit form pre-fills, saves correctly
- Delete: Confirmation dialog shows, deletes successfully

## Performance Check

### Page Load Times (Expected)
- Login page: < 1s
- Dashboard: < 2s (with data)
- Other pages: < 1.5s

### API Response Times (Expected)
- Login: < 500ms
- Get data: < 300ms
- Create/Update: < 500ms
- Delete: < 300ms

## Demo Credentials

### Admin Account
```
Email: admin@kosterpadu.com
Password: admin123
Role: admin
```

### Test Tenant Account (if seeded)
```
Email: tenant1@example.com
Password: password123
Role: tenant
```

## Next Steps After Testing

### If Everything Works:
1. ✅ Backend-Frontend connection successful
2. ✅ Ready for development
3. ✅ Can start adding features or customizing

### If Issues Found:
1. Check error messages
2. Review troubleshooting section
3. Check backend logs
4. Check browser console
5. Verify database has data

## Development Workflow

```bash
# Terminal 1: Backend
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-backend"
npm run dev

# Terminal 2: Frontend
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-admin"
npm run dev

# Terminal 3: Database (if needed)
psql -U postgres -d kosan
```

## Useful Commands

```bash
# Check backend status
netstat -ano | findstr :5000

# Check frontend status
netstat -ano | findstr :3000

# Kill process on port (if needed)
# Find PID first, then:
taskkill /PID <PID> /F

# Restart backend
cd backend
npm run dev

# Restart frontend
cd frontend
npm run dev

# Check database
psql -U postgres -d kosan -c "SELECT * FROM users;"
```

## Success Checklist

After testing, verify:
- [ ] Login works
- [ ] Dashboard loads with data
- [ ] All pages accessible
- [ ] CRUD operations work
- [ ] Search works
- [ ] Filter works
- [ ] Pagination works
- [ ] Forms validate correctly
- [ ] Toast notifications show
- [ ] No console errors
- [ ] No network errors
- [ ] Responsive design works

## Contact

If you encounter issues:
1. Check documentation files
2. Review error messages
3. Check backend logs
4. Ask the team

---

**Last Updated**: May 21, 2026  
**Backend Status**: Running ✅  
**Frontend Status**: Ready ✅  
**Connection**: Configured ✅
