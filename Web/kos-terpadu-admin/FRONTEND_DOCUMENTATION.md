# KosTerpadu Admin Panel - Frontend Documentation

## Project Overview

Admin panel untuk sistem manajemen kos terpadu yang dibangun dengan Next.js 14 (App Router), TypeScript, dan TailwindCSS.

## Tech Stack

### Core
- **Next.js 14** - React framework dengan App Router
- **React 19** - UI library
- **TypeScript 5** - Type safety
- **TailwindCSS 3.4** - Utility-first CSS framework

### UI Components
- **Radix UI** - Headless UI components (Dialog, Select, Dropdown, etc.)
- **Lucide React** - Icon library
- **Framer Motion** - Animation library
- **Recharts** - Chart library untuk dashboard

### State Management & Data Fetching
- **Zustand** - Lightweight state management
- **React Hook Form** - Form handling
- **Zod** - Schema validation
- **Axios** - HTTP client

### Additional Libraries
- **date-fns** - Date manipulation
- **Firebase** - Real-time chat & notifications
- **jsPDF** - PDF export
- **xlsx** - Excel export

## Project Structure

```
kos-terpadu-admin/
├── app/                          # Next.js App Router
│   ├── (auth)/                   # Auth layout group
│   │   ├── login/                # Login page
│   │   ├── forgot-password/      # Forgot password page
│   │   └── reset-password/       # Reset password page
│   ├── (dashboard)/              # Dashboard layout group
│   │   ├── dashboard/            # Main dashboard
│   │   ├── rooms/                # Room management
│   │   ├── tenants/              # Tenant management
│   │   ├── bills/                # Bill management
│   │   ├── payments/             # Payment verification
│   │   ├── maintenance/          # Maintenance reports
│   │   ├── announcements/        # Announcements
│   │   ├── chat/                 # Chat with tenants
│   │   ├── notifications/        # Notifications
│   │   ├── profile/              # Admin profile
│   │   └── settings/             # Settings
│   ├── globals.css               # Global styles
│   ├── layout.tsx                # Root layout
│   └── page.tsx                  # Home page (redirects)
├── components/
│   ├── layout/                   # Layout components
│   │   ├── Sidebar.tsx           # Sidebar navigation
│   │   └── Navbar.tsx            # Top navbar
│   ├── shared/                   # Shared components
│   │   ├── PageHeader.tsx        # Page header with title
│   │   ├── DataTable.tsx         # Reusable data table
│   │   ├── StatsCard.tsx         # Dashboard stats card
│   │   ├── StatusBadge.tsx       # Status badges
│   │   └── ConfirmDialog.tsx     # Confirmation dialog
│   └── ui/                       # UI primitives (Radix UI)
│       ├── button.tsx
│       ├── input.tsx
│       ├── dialog.tsx
│       ├── select.tsx
│       └── ...
├── hooks/                        # Custom React hooks
│   ├── useAuth.ts                # Authentication hook
│   ├── useDebounce.ts            # Debounce hook
│   ├── useFirebaseChat.ts        # Firebase chat hook
│   ├── useFirebaseNotifications.ts
│   └── useLocalStorage.ts        # LocalStorage hook
├── lib/                          # Utilities & configs
│   ├── axios.ts                  # Axios instance with interceptors
│   ├── constants.ts              # App constants
│   ├── firebase.ts               # Firebase config
│   └── utils.ts                  # Utility functions
├── services/                     # API services
│   ├── auth.service.ts           # Auth API calls
│   ├── room.service.ts           # Room API calls
│   ├── tenant.service.ts         # Tenant API calls
│   ├── payment.service.ts        # Payment API calls
│   ├── maintenance.service.ts    # Maintenance API calls
│   ├── announcement.service.ts   # Announcement API calls
│   ├── dashboard.service.ts      # Dashboard API calls
│   └── firebase.service.ts       # Firebase operations
├── store/                        # Zustand stores
│   ├── auth.store.ts             # Auth state
│   ├── ui.store.ts               # UI state (sidebar, theme)
│   └── notification.store.ts     # Notification state
├── types/                        # TypeScript types
│   └── index.ts                  # All type definitions
├── utils/                        # Helper utilities
│   ├── export.ts                 # Export to PDF/Excel
│   └── seed-data.ts              # Mock data for development
├── .env.local                    # Environment variables
├── next.config.ts                # Next.js config
├── tailwind.config.ts            # Tailwind config
└── tsconfig.json                 # TypeScript config
```

## Features Implemented

### Authentication
- Login with email/password
- Forgot password
- Reset password
- JWT token management
- Auto-redirect on auth state change
- Protected routes

### Dashboard
- Overview statistics (8 stat cards)
- Monthly income chart (Area chart)
- Room occupancy breakdown
- Recent activities log
- Pending payments list
- Pending maintenance list

### Room Management
- List all rooms with pagination
- Filter by status (available, occupied, maintenance)
- Search by room number
- Add new room
- Edit room details
- Delete room
- Multi-select facilities
- Image upload placeholder

### Tenant Management
- List all tenants with pagination
- Filter by status (active, inactive)
- Search by name or email
- Add new tenant
- Edit tenant details
- Delete tenant
- Assign room to tenant
- Set start/end date

### Bill Management
- List all bills with pagination
- Filter by status (pending, paid, overdue)
- Filter by month and year
- Search by tenant name
- Generate bills for all tenants
- Mark bill as paid
- View payment proof

### Payment Verification
- List all payments with pagination
- Filter by status (pending, verified, rejected)
- View payment proof image
- Verify payment
- Reject payment with reason
- Auto-update bill status

### Maintenance Reports
- List all maintenance reports
- Filter by status (pending, in_progress, completed)
- View report details
- Update report status
- Add progress updates with images
- Mark as completed

### Announcements
- List all announcements
- Create new announcement
- Edit announcement
- Delete announcement
- Rich text editor placeholder

### Chat (Firebase)
- Real-time chat with tenants
- List of chat rooms
- Unread message count
- Send text messages
- Send images
- Message read status

### Notifications (Firebase)
- Real-time notifications
- Notification badge count
- Mark as read
- Filter by type
- Auto-refresh

### Profile
- View admin profile
- Edit profile information
- Upload avatar
- Change password

### Settings
- App settings
- Theme toggle (light/dark)
- Notification preferences

## Design System

### Colors
- **Primary Blue**: `#3B82F6` (blue-500)
- **Secondary Green**: `#10B981` (emerald-500)
- **Danger Red**: `#EF4444` (red-500)
- **Warning Amber**: `#F59E0B` (amber-500)
- **Success Green**: `#10B981` (emerald-500)

### Typography
- Font: System font stack (default Next.js)
- Headings: Bold, various sizes
- Body: Regular, 14px base

### Components
- Rounded corners: `0.75rem` (12px)
- Shadows: Subtle elevation
- Borders: Light gray
- Hover states: Smooth transitions
- Focus states: Blue ring

## API Integration

### Base URL
```
http://localhost:5000/api
```

### Authentication
All API requests include JWT token in Authorization header:
```
Authorization: Bearer <token>
```

Token is stored in localStorage and automatically attached by Axios interceptor.

### API Endpoints Used

#### Auth
- `POST /auth/login` - Login
- `POST /auth/logout` - Logout
- `POST /auth/forgot-password` - Forgot password
- `POST /auth/reset-password` - Reset password
- `GET /auth/profile` - Get profile
- `PUT /auth/profile` - Update profile
- `PUT /auth/change-password` - Change password

#### Dashboard
- `GET /dashboard/stats` - Get dashboard statistics
- `GET /dashboard/monthly-income` - Get monthly income data
- `GET /dashboard/recent-activities` - Get recent activities

#### Rooms
- `GET /rooms` - Get all rooms (with pagination & filters)
- `GET /rooms/:id` - Get room by ID
- `POST /rooms` - Create room
- `PUT /rooms/:id` - Update room
- `DELETE /rooms/:id` - Delete room

#### Tenants
- `GET /tenants` - Get all tenants (with pagination & filters)
- `GET /tenants/:id` - Get tenant by ID
- `POST /tenants` - Create tenant
- `PUT /tenants/:id` - Update tenant
- `DELETE /tenants/:id` - Delete tenant

#### Bills
- `GET /bills` - Get all bills (with pagination & filters)
- `GET /bills/:id` - Get bill by ID
- `POST /bills/generate` - Generate bills for all tenants
- `PUT /bills/:id` - Update bill

#### Payments
- `GET /payments` - Get all payments (with pagination & filters)
- `GET /payments/:id` - Get payment by ID
- `PUT /payments/:id/verify` - Verify payment
- `PUT /payments/:id/reject` - Reject payment

#### Maintenance
- `GET /maintenance` - Get all maintenance reports
- `GET /maintenance/:id` - Get maintenance report by ID
- `PUT /maintenance/:id` - Update maintenance report
- `POST /maintenance/:id/progress` - Add progress update

#### Announcements
- `GET /announcements` - Get all announcements
- `GET /announcements/:id` - Get announcement by ID
- `POST /announcements` - Create announcement
- `PUT /announcements/:id` - Update announcement
- `DELETE /announcements/:id` - Delete announcement

## State Management

### Auth Store (Zustand)
```typescript
{
  user: User | null,
  token: string | null,
  isAuthenticated: boolean,
  login: (user, token) => void,
  logout: () => void,
  updateUser: (user) => void
}
```

### UI Store (Zustand)
```typescript
{
  sidebarCollapsed: boolean,
  theme: 'light' | 'dark',
  toggleSidebar: () => void,
  setTheme: (theme) => void
}
```

### Notification Store (Zustand)
```typescript
{
  notifications: Notification[],
  unreadCount: number,
  addNotification: (notification) => void,
  markAsRead: (id) => void,
  clearAll: () => void
}
```

## Environment Variables

Create `.env.local` file in root directory:

```env
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXT_PUBLIC_FIREBASE_API_KEY=your_firebase_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

## Installation & Setup

### Prerequisites
- Node.js 18+ installed
- Backend server running on port 5000
- Firebase project (for chat & notifications)

### Steps

1. **Install dependencies**
```bash
cd "D:\Kuliah\Semester 6\PraktikumTCC\ProyekPrakTCC\Web\kos-terpadu-admin"
npm install
```

2. **Configure environment variables**
- Copy `.env.local` and fill in your values
- Update Firebase credentials

3. **Run development server**
```bash
npm run dev
```

4. **Open browser**
```
http://localhost:3000
```

5. **Login with demo credentials**
```
Email: admin@kosterpadu.com
Password: admin123
```

## Development Workflow

### Adding New Page

1. Create page in `app/(dashboard)/new-page/page.tsx`
2. Add route to sidebar in `components/layout/Sidebar.tsx`
3. Create service in `services/new-page.service.ts`
4. Add types in `types/index.ts`

### Adding New Component

1. Create component in `components/shared/NewComponent.tsx`
2. Export from `components/shared/index.ts` (if needed)
3. Use in pages

### Adding New API Endpoint

1. Add function in appropriate service file
2. Use in page with try-catch
3. Show toast on success/error

## Code Style Guidelines

### Naming Conventions
- Components: PascalCase (e.g., `PageHeader.tsx`)
- Files: kebab-case (e.g., `auth.service.ts`)
- Functions: camelCase (e.g., `formatCurrency`)
- Constants: UPPER_SNAKE_CASE (e.g., `ROOM_STATUS`)

### Component Structure
```typescript
// Imports
import { useState } from "react";
import { Button } from "@/components/ui/button";

// Types
interface Props {
  title: string;
}

// Component
export default function MyComponent({ title }: Props) {
  // State
  const [count, setCount] = useState(0);
  
  // Handlers
  const handleClick = () => {
    setCount(count + 1);
  };
  
  // Render
  return (
    <div>
      <h1>{title}</h1>
      <Button onClick={handleClick}>Count: {count}</Button>
    </div>
  );
}
```

### Comments
- Add JSDoc comments for all functions
- Explain complex logic
- No obvious comments

```typescript
/**
 * Format number to Indonesian Rupiah currency
 * @param amount - The amount to format
 * @returns Formatted currency string
 */
export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(amount);
}
```

## Testing

### Manual Testing Checklist

#### Authentication
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Logout
- [ ] Forgot password
- [ ] Reset password
- [ ] Auto-redirect when not authenticated

#### Dashboard
- [ ] View statistics
- [ ] View charts
- [ ] View recent activities
- [ ] View pending payments

#### Rooms
- [ ] List rooms
- [ ] Filter by status
- [ ] Search rooms
- [ ] Add room
- [ ] Edit room
- [ ] Delete room

#### Tenants
- [ ] List tenants
- [ ] Filter by status
- [ ] Search tenants
- [ ] Add tenant
- [ ] Edit tenant
- [ ] Delete tenant

#### Bills
- [ ] List bills
- [ ] Filter by status
- [ ] Filter by month/year
- [ ] Generate bills
- [ ] View bill details

#### Payments
- [ ] List payments
- [ ] Filter by status
- [ ] View payment proof
- [ ] Verify payment
- [ ] Reject payment

#### Maintenance
- [ ] List maintenance reports
- [ ] Filter by status
- [ ] View report details
- [ ] Update status
- [ ] Add progress

#### Announcements
- [ ] List announcements
- [ ] Create announcement
- [ ] Edit announcement
- [ ] Delete announcement

#### Chat
- [ ] View chat rooms
- [ ] Send message
- [ ] Receive message
- [ ] View unread count

#### Notifications
- [ ] Receive notification
- [ ] Mark as read
- [ ] View notification list

## Deployment

### Build for Production

```bash
npm run build
```

### Start Production Server

```bash
npm start
```

### Deploy to Vercel

1. Push code to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy

## Troubleshooting

### Common Issues

#### 1. API Connection Error
**Problem**: Cannot connect to backend
**Solution**: 
- Check if backend is running on port 5000
- Verify `NEXT_PUBLIC_API_URL` in `.env.local`
- Check CORS settings in backend

#### 2. Firebase Error
**Problem**: Firebase not working
**Solution**:
- Verify Firebase credentials in `.env.local`
- Check Firebase project settings
- Enable Firestore and Realtime Database

#### 3. Build Error
**Problem**: Build fails
**Solution**:
- Delete `.next` folder
- Delete `node_modules` folder
- Run `npm install` again
- Run `npm run build` again

#### 4. TypeScript Error
**Problem**: Type errors
**Solution**:
- Check type definitions in `types/index.ts`
- Run `npm run lint` to see all errors
- Fix type mismatches

## Performance Optimization

### Implemented
- Code splitting with Next.js App Router
- Image optimization with Next.js Image
- Lazy loading components
- Debounced search
- Memoized components
- Optimized re-renders

### TODO
- Add React Query for better caching
- Implement virtual scrolling for large lists
- Add service worker for offline support
- Optimize bundle size

## Security

### Implemented
- JWT token authentication
- HTTP-only cookies (backend)
- CSRF protection (backend)
- XSS prevention (React escaping)
- Input validation (Zod)
- Protected routes

### TODO
- Add rate limiting
- Add 2FA
- Add session timeout
- Add audit logs

## Future Enhancements

### Features
- [ ] Multi-language support (i18n)
- [ ] Dark mode toggle
- [ ] Export to PDF/Excel
- [ ] Advanced filtering
- [ ] Bulk operations
- [ ] Email notifications
- [ ] SMS notifications
- [ ] Payment gateway integration
- [ ] Mobile app (React Native)

### Technical
- [ ] Add unit tests (Jest)
- [ ] Add E2E tests (Playwright)
- [ ] Add Storybook for components
- [ ] Add CI/CD pipeline
- [ ] Add monitoring (Sentry)
- [ ] Add analytics (Google Analytics)

## Contributing

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] All functions have comments
- [ ] No console.logs
- [ ] No hardcoded values
- [ ] Types are properly defined
- [ ] Error handling is implemented
- [ ] Loading states are shown
- [ ] Success/error messages are shown

## License

Private project for educational purposes.

## Contact

For questions or issues, contact the development team.

---

**Last Updated**: May 21, 2026
**Version**: 0.1.0
**Status**: Development
