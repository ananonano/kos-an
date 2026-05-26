# KosTerpadu Admin Panel

Admin panel untuk sistem manajemen kos terpadu. Dibangun dengan Next.js 14, TypeScript, dan TailwindCSS.

## Tech Stack

- **Next.js 14** (App Router)
- **React 19**
- **TypeScript 5**
- **TailwindCSS 3.4**
- **Radix UI** (Components)
- **Zustand** (State Management)
- **Axios** (HTTP Client)
- **React Hook Form + Zod** (Form Validation)
- **Firebase** (Real-time Chat & Notifications)
- **Recharts** (Charts)
- **Framer Motion** (Animations)

## Features

### Implemented
- Authentication (Login, Forgot Password, Reset Password)
- Dashboard dengan statistik dan grafik
- Manajemen Kamar (CRUD, Filter, Search)
- Manajemen Penghuni (CRUD, Filter, Search)
- Manajemen Tagihan (Generate, Filter, Search)
- Verifikasi Pembayaran (Approve/Reject)
- Laporan Maintenance (Status Update, Progress)
- Pengumuman (CRUD)
- Chat Real-time dengan Penghuni (Firebase)
- Notifikasi Real-time (Firebase)
- Profile Management
- Export to PDF/Excel
- Dark Mode Support
- Responsive Design

### Pages
- `/login` - Login page
- `/dashboard` - Main dashboard
- `/rooms` - Room management
- `/tenants` - Tenant management
- `/bills` - Bill management
- `/payments` - Payment verification
- `/maintenance` - Maintenance reports
- `/announcements` - Announcements
- `/chat` - Chat with tenants
- `/notifications` - Notifications
- `/profile` - Admin profile
- `/settings` - Settings

## Quick Start

### Prerequisites
- Node.js 18+
- Backend server running on `http://localhost:5000`
- Firebase project (optional, for chat & notifications)

### Installation

1. **Install dependencies**
```bash
npm install
```

2. **Configure environment**
```bash
# Copy .env.local and update values
NEXT_PUBLIC_API_URL=http://localhost:5000/api
```

3. **Run development server**
```bash
npm run dev
```

4. **Open browser**
```
http://localhost:3000
```

5. **Login**
```
Email: admin@kosterpadu.com
Password: admin123
```

## Project Structure

```
kos-terpadu-admin/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth pages (login, forgot-password)
│   └── (dashboard)/       # Dashboard pages (protected)
├── components/
│   ├── layout/            # Layout components (Sidebar, Navbar)
│   ├── shared/            # Shared components (DataTable, StatsCard)
│   └── ui/                # UI primitives (Button, Input, Dialog)
├── hooks/                 # Custom React hooks
├── lib/                   # Utilities & configs
├── services/              # API services
├── store/                 # Zustand stores
├── types/                 # TypeScript types
└── utils/                 # Helper utilities
```

## API Integration

Backend API: `http://localhost:5000/api`

All requests include JWT token in Authorization header:
```
Authorization: Bearer <token>
```

### Main Endpoints
- `POST /auth/login` - Login
- `GET /dashboard/stats` - Dashboard statistics
- `GET /rooms` - Get all rooms
- `GET /tenants` - Get all tenants
- `GET /bills` - Get all bills
- `GET /payments` - Get all payments
- `GET /maintenance` - Get maintenance reports
- `GET /announcements` - Get announcements

See `FRONTEND_DOCUMENTATION.md` for complete API documentation.

## Design System

### Colors
- Primary Blue: `#3B82F6`
- Secondary Green: `#10B981`
- Danger Red: `#EF4444`
- Warning Amber: `#F59E0B`

### Components
- Rounded corners: `0.75rem`
- Shadows: Subtle elevation
- Smooth transitions
- Focus states with blue ring

## Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm start        # Start production server
npm run lint     # Run ESLint
```

## Environment Variables

Create `.env.local` file:

```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

## Development

### Adding New Page
1. Create page in `app/(dashboard)/new-page/page.tsx`
2. Add route to `components/layout/Sidebar.tsx`
3. Create service in `services/new-page.service.ts`
4. Add types in `types/index.ts`

### Code Style
- Components: PascalCase
- Files: kebab-case
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE
- Add JSDoc comments for all functions
- Use TypeScript strict mode

## Troubleshooting

### API Connection Error
- Check if backend is running on port 5000
- Verify `NEXT_PUBLIC_API_URL` in `.env.local`
- Check CORS settings in backend

### Build Error
```bash
rm -rf .next node_modules
npm install
npm run build
```

## Documentation

- `FRONTEND_DOCUMENTATION.md` - Complete documentation
- `ARCHITECTURE.md` - Architecture overview (if exists)

## License

Private project for educational purposes.

---

**Version**: 0.1.0  
**Last Updated**: May 21, 2026
