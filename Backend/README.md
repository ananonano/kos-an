# KosTerpadu Backend API

Backend REST API untuk aplikasi manajemen kos terpadu berbasis cloud.
**Shared backend untuk Web Admin dan Mobile App.**

## Tech Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL
- **Authentication:** JWT (JSON Web Token)
- **Language:** TypeScript
- **ORM:** Native PostgreSQL queries with pg library

## Features

- Authentication & Authorization (JWT)
- Role-based access control (Admin & Tenant)
- Complete CRUD operations for all entities
- Pagination & filtering
- File upload support
- Transaction support
- Statistics & reporting
- 57+ REST API endpoints

## Prerequisites

- Node.js v18 or higher
- PostgreSQL v14 or higher
- npm or yarn

## Installation

1. Navigate to backend directory:
```bash
cd Backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Configure environment variables in `.env`:
```env
PORT=5000
NODE_ENV=development

DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=kos_terpadu
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password

JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRES_IN=7d

CLOUD_STORAGE_BUCKET=your_bucket_name
```

## Database Setup

### Cloud SQL PostgreSQL (Production)

**Already configured and running!**
- Host: `34.50.122.143`
- Database: `kosterpadu_db`
- Migrations: ✅ Completed (10 tables)
- Dummy Data: ✅ Seeded

### Local Development

1. Create PostgreSQL database:
```sql
CREATE DATABASE kos_terpadu;
```

2. Run migrations:
```bash
npm run migrate
```

3. Seed database with dummy data (optional):
```bash
npm run seed
```

### Data Migration from Existing Database

Need to migrate real data from local PostgreSQL server?

See **[Data Migration Guide](../DATA-MIGRATION.md)** for complete instructions on:
- Exporting data from source PostgreSQL server
- Importing to Cloud SQL
- Network connectivity solutions
- Migration scripts and tools

## Running the Application

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm run build
npm start
```

### Other Commands
```bash
npm run lint          # Run ESLint
npm run format        # Format code with Prettier
npm run type-check    # TypeScript type checking
```

## Project Structure

```
src/
├── config/           # Configuration files
│   ├── database.ts   # Database connection
│   ├── migrate.ts    # Migration script
│   └── seed.ts       # Seed script
├── controllers/      # Request handlers
│   ├── auth.controller.ts
│   ├── room.controller.ts
│   ├── tenant.controller.ts
│   ├── bill.controller.ts
│   ├── payment.controller.ts
│   ├── maintenance.controller.ts
│   ├── announcement.controller.ts
│   └── dashboard.controller.ts
├── models/           # Database models
│   ├── user.model.ts
│   ├── room.model.ts
│   ├── tenant.model.ts
│   ├── contract.model.ts
│   ├── bill.model.ts
│   ├── payment.model.ts
│   ├── maintenance.model.ts
│   └── announcement.model.ts
├── routes/           # API routes
│   ├── auth.routes.ts
│   ├── room.routes.ts
│   ├── tenant.routes.ts
│   ├── bill.routes.ts
│   ├── payment.routes.ts
│   ├── maintenance.routes.ts
│   ├── announcement.routes.ts
│   ├── dashboard.routes.ts
│   └── index.ts
├── middleware/       # Express middleware
│   ├── auth.middleware.ts
│   ├── error.middleware.ts
│   └── upload.middleware.ts
├── types/            # TypeScript types
│   └── index.ts
├── utils/            # Utility functions
│   └── helpers.ts
└── index.ts          # Application entry point
```

## API Documentation

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for complete API reference.

**Base URL:** `http://localhost:5000/api`

**Total Endpoints:** 57+

### Main Endpoints:
- `/api/auth` - Authentication (5 endpoints)
- `/api/rooms` - Room management (6 endpoints)
- `/api/tenants` - Tenant management (6 endpoints)
- `/api/bills` - Bill management (8 endpoints)
- `/api/payments` - Payment management (9 endpoints)
- `/api/maintenance` - Maintenance requests (9 endpoints)
- `/api/announcements` - Announcements (9 endpoints)
- `/api/dashboard` - Dashboard statistics (5 endpoints)

## Database Schema

### SQL Tables (8 tables):
1. **users** - User accounts (admin & tenant)
2. **rooms** - Room information
3. **tenants** - Tenant details
4. **contracts** - Rental contracts
5. **bills** - Monthly bills
6. **payments** - Payment records
7. **maintenance** - Maintenance requests
8. **announcements** - System announcements

## Authentication

All protected endpoints require JWT token in Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

### Default Admin Account (after seeding):
- Email: `admin@kosterpadu.com`
- Password: `admin123`

### Default Tenant Account (after seeding):
- Email: `tenant1@example.com`
- Password: `password123`

## Testing with Postman

1. Import the Postman collection (if available)
2. Set environment variables:
   - `base_url`: `http://localhost:5000/api`
   - `token`: Your JWT token after login

3. Test authentication:
   - POST `/auth/login` to get token
   - Use token in subsequent requests

## Deployment

### Deploy to Google Cloud Run

1. Build Docker image:
```bash
docker build -t kos-terpadu-backend .
```

2. Push to Google Container Registry:
```bash
docker tag kos-terpadu-backend gcr.io/YOUR_PROJECT_ID/kos-terpadu-backend
docker push gcr.io/YOUR_PROJECT_ID/kos-terpadu-backend
```

3. Deploy to Cloud Run:
```bash
gcloud run deploy kos-terpadu-backend \
  --image gcr.io/YOUR_PROJECT_ID/kos-terpadu-backend \
  --platform managed \
  --region asia-southeast2 \
  --allow-unauthenticated
```

### Database on Cloud SQL

1. Create Cloud SQL instance (PostgreSQL)
2. Update `.env` with Cloud SQL connection details
3. Use Cloud SQL Proxy for local development

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| PORT | Server port | 5000 |
| NODE_ENV | Environment | development/production |
| DATABASE_HOST | PostgreSQL host | localhost |
| DATABASE_PORT | PostgreSQL port | 5432 |
| DATABASE_NAME | Database name | kos_terpadu |
| DATABASE_USER | Database user | postgres |
| DATABASE_PASSWORD | Database password | your_password |
| JWT_SECRET | JWT secret key | random_secret_key |
| JWT_EXPIRES_IN | Token expiration | 7d |
| CLOUD_STORAGE_BUCKET | GCS bucket name | kos-terpadu-files |

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

Private - Academic Project

## Contact

For questions or issues, contact the development team.
