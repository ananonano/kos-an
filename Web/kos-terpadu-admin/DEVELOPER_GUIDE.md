# Developer Quick Reference Guide

## Quick Start

```bash
# Install
npm install

# Run dev server
npm run dev

# Open browser
http://localhost:3000

# Login
Email: admin@kosterpadu.com
Password: admin123
```

## Project Structure Cheat Sheet

```
app/
├── (auth)/login              → Login page
├── (dashboard)/
│   ├── dashboard             → Main dashboard
│   ├── rooms                 → Room management
│   ├── tenants               → Tenant management
│   ├── bills                 → Bill management
│   ├── payments              → Payment verification
│   ├── maintenance           → Maintenance reports
│   ├── announcements         → Announcements
│   ├── chat                  → Chat with tenants
│   ├── notifications         → Notifications
│   ├── profile               → Admin profile
│   └── settings              → Settings

components/
├── layout/                   → Sidebar, Navbar
├── shared/                   → PageHeader, DataTable, StatsCard
└── ui/                       → Button, Input, Dialog, etc.

services/                     → API calls (auth, room, tenant, etc.)
store/                        → Zustand stores (auth, ui, notification)
hooks/                        → Custom hooks (useAuth, useDebounce)
lib/                          → Utils (axios, constants, firebase)
types/                        → TypeScript types
```

## Common Tasks

### 1. Add New Page

```typescript
// 1. Create page file
// app/(dashboard)/new-page/page.tsx
"use client";
import { PageHeader } from "@/components/shared/PageHeader";

export default function NewPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="New Page" description="Description" />
      {/* Content */}
    </div>
  );
}

// 2. Add to sidebar
// components/layout/Sidebar.tsx
const menuItems = [
  // ... existing items
  { icon: Icon, label: "New Page", href: "/new-page" },
];
```

### 2. Create API Service

```typescript
// services/new.service.ts
import api from "@/lib/axios";
import type { ApiResponse } from "@/types";

export const newService = {
  getAll: async () => {
    const res = await api.get<ApiResponse<Item[]>>("/items");
    return res.data;
  },
  
  getById: async (id: string) => {
    const res = await api.get<ApiResponse<Item>>(`/items/${id}`);
    return res.data;
  },
  
  create: async (data: CreateData) => {
    const res = await api.post<ApiResponse<Item>>("/items", data);
    return res.data;
  },
  
  update: async (id: string, data: UpdateData) => {
    const res = await api.put<ApiResponse<Item>>(`/items/${id}`, data);
    return res.data;
  },
  
  delete: async (id: string) => {
    const res = await api.delete<ApiResponse<void>>(`/items/${id}`);
    return res.data;
  },
};
```

### 3. Add TypeScript Types

```typescript
// types/index.ts
export interface NewItem {
  id: string;
  name: string;
  status: "active" | "inactive";
  createdAt: string;
}

export interface NewItemFormData {
  name: string;
  status: "active" | "inactive";
}
```

### 4. Create Form with Validation

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Invalid email"),
  age: z.coerce.number().min(18, "Must be 18+"),
});

type FormData = z.infer<typeof schema>;

export default function MyForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    // Handle submit
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input {...register("name")} />
      {errors.name && <p className="text-red-500">{errors.name.message}</p>}
      
      <Button type="submit">Submit</Button>
    </form>
  );
}
```

### 5. Use Zustand Store

```typescript
// Create store
// store/my.store.ts
import { create } from "zustand";

interface MyStore {
  count: number;
  increment: () => void;
  decrement: () => void;
}

export const useMyStore = create<MyStore>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));

// Use in component
import { useMyStore } from "@/store/my.store";

export default function MyComponent() {
  const { count, increment, decrement } = useMyStore();
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+</button>
      <button onClick={decrement}>-</button>
    </div>
  );
}
```

### 6. Show Toast Notification

```typescript
import { toast } from "@/components/ui/toaster";

// Success
toast({ title: "Success!", variant: "success" });

// Error
toast({ title: "Error!", variant: "destructive" });

// Info
toast({ title: "Info", variant: "default" });
```

### 7. Create Custom Hook

```typescript
// hooks/useMyHook.ts
import { useState, useEffect } from "react";

export function useMyHook(initialValue: string) {
  const [value, setValue] = useState(initialValue);
  
  useEffect(() => {
    // Side effect
  }, [value]);
  
  return { value, setValue };
}

// Use in component
import { useMyHook } from "@/hooks/useMyHook";

export default function MyComponent() {
  const { value, setValue } = useMyHook("initial");
  
  return <input value={value} onChange={(e) => setValue(e.target.value)} />;
}
```

## Common Components

### PageHeader
```typescript
import { PageHeader } from "@/components/shared/PageHeader";

<PageHeader 
  title="Page Title" 
  description="Description"
  actions={<Button>Action</Button>}
/>
```

### DataTable
```typescript
import { DataTable } from "@/components/shared/DataTable";

const columns = [
  { key: "name", header: "Name", render: (item) => item.name },
  { key: "status", header: "Status", render: (item) => <Badge>{item.status}</Badge> },
];

<DataTable 
  data={items}
  columns={columns}
  searchable
  searchPlaceholder="Search..."
  onSearch={setSearch}
  emptyMessage="No items found"
/>
```

### StatsCard
```typescript
import { StatsCard } from "@/components/shared/StatsCard";
import { Users } from "lucide-react";

<StatsCard
  title="Total Users"
  value={100}
  subtitle="Active users"
  icon={Users}
  color="blue"
  trend={{ value: 10, label: "vs last month" }}
  index={0}
/>
```

### Dialog
```typescript
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";

<Dialog open={open} onOpenChange={setOpen}>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Dialog Title</DialogTitle>
    </DialogHeader>
    <div>Content</div>
    <DialogFooter>
      <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
      <Button onClick={handleSubmit}>Submit</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

### ConfirmDialog
```typescript
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";

<ConfirmDialog
  open={!!deleteItem}
  onClose={() => setDeleteItem(null)}
  onConfirm={handleDelete}
  title="Delete Item"
  description="Are you sure? This action cannot be undone."
  confirmLabel="Delete"
  isLoading={isLoading}
/>
```

## Utility Functions

### Format Currency
```typescript
import { formatCurrency } from "@/lib/utils";

formatCurrency(1500000); // "Rp 1.500.000"
```

### Format Date
```typescript
import { formatDate, timeAgo } from "@/lib/utils";

formatDate("2024-01-01"); // "1 Jan 2024"
timeAgo("2024-01-01"); // "2 months ago"
```

### Get Initials
```typescript
import { getInitials } from "@/lib/utils";

getInitials("John Doe"); // "JD"
```

### Class Names
```typescript
import { cn } from "@/lib/utils";

<div className={cn("base-class", isActive && "active-class")} />
```

## API Integration Pattern

```typescript
"use client";
import { useState, useEffect } from "react";
import { myService } from "@/services/my.service";
import { toast } from "@/components/ui/toaster";

export default function MyPage() {
  const [items, setItems] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  // Fetch data
  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      setIsLoading(true);
      const response = await myService.getAll();
      setItems(response.data);
    } catch (err) {
      setError(err.message);
      toast({ title: "Error fetching items", variant: "destructive" });
    } finally {
      setIsLoading(false);
    }
  };

  // Create
  const handleCreate = async (data) => {
    try {
      setIsLoading(true);
      await myService.create(data);
      toast({ title: "Item created", variant: "success" });
      fetchItems(); // Refresh
    } catch (err) {
      toast({ title: "Error creating item", variant: "destructive" });
    } finally {
      setIsLoading(false);
    }
  };

  // Update
  const handleUpdate = async (id, data) => {
    try {
      setIsLoading(true);
      await myService.update(id, data);
      toast({ title: "Item updated", variant: "success" });
      fetchItems(); // Refresh
    } catch (err) {
      toast({ title: "Error updating item", variant: "destructive" });
    } finally {
      setIsLoading(false);
    }
  };

  // Delete
  const handleDelete = async (id) => {
    try {
      setIsLoading(true);
      await myService.delete(id);
      toast({ title: "Item deleted", variant: "destructive" });
      fetchItems(); // Refresh
    } catch (err) {
      toast({ title: "Error deleting item", variant: "destructive" });
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      {/* Render items */}
    </div>
  );
}
```

## Styling Patterns

### Responsive Grid
```typescript
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  {/* Items */}
</div>
```

### Card
```typescript
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
    <CardDescription>Description</CardDescription>
  </CardHeader>
  <CardContent>
    {/* Content */}
  </CardContent>
</Card>
```

### Status Badge
```typescript
<span className="px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">
  Active
</span>
```

### Button Variants
```typescript
<Button variant="default">Default</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="destructive">Destructive</Button>
<Button size="sm">Small</Button>
<Button size="lg">Large</Button>
<Button size="icon"><Icon /></Button>
```

## Animation with Framer Motion

```typescript
import { motion } from "framer-motion";

<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3 }}
>
  Content
</motion.div>
```

## Environment Variables

```env
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
```

Access in code:
```typescript
const apiUrl = process.env.NEXT_PUBLIC_API_URL;
```

## Debugging

### Console Log
```typescript
console.log("Debug:", data);
console.error("Error:", error);
console.table(array);
```

### React DevTools
- Install React DevTools extension
- Inspect component tree
- View props and state

### Network Tab
- Open browser DevTools
- Go to Network tab
- Filter by XHR/Fetch
- Check API requests/responses

## Common Errors & Solutions

### 1. API Connection Error
**Error**: `Network Error` or `ERR_CONNECTION_REFUSED`

**Solution**:
- Check if backend is running on port 5000
- Verify `NEXT_PUBLIC_API_URL` in `.env.local`
- Check CORS settings in backend

### 2. TypeScript Error
**Error**: `Type 'X' is not assignable to type 'Y'`

**Solution**:
- Check type definitions in `types/index.ts`
- Add proper type annotations
- Use type assertion if needed: `as Type`

### 3. Hydration Error
**Error**: `Hydration failed because the initial UI does not match`

**Solution**:
- Use `"use client"` directive
- Check for client-only code (localStorage, window)
- Use `useEffect` for client-side operations

### 4. Module Not Found
**Error**: `Module not found: Can't resolve '@/...'`

**Solution**:
- Check import path
- Verify file exists
- Check `tsconfig.json` paths configuration

## Git Workflow

```bash
# Check status
git status

# Add files
git add .

# Commit
git commit -m "feat: add new feature"

# Push
git push origin main

# Pull
git pull origin main

# Create branch
git checkout -b feature/new-feature

# Merge branch
git checkout main
git merge feature/new-feature
```

## Commit Message Convention

```
feat: add new feature
fix: fix bug
docs: update documentation
style: format code
refactor: refactor code
test: add tests
chore: update dependencies
```

## Useful VS Code Extensions

- ESLint
- Prettier
- Tailwind CSS IntelliSense
- TypeScript Error Translator
- Auto Rename Tag
- GitLens
- Error Lens

## Keyboard Shortcuts

### VS Code
- `Ctrl + P` - Quick open file
- `Ctrl + Shift + P` - Command palette
- `Ctrl + B` - Toggle sidebar
- `Ctrl + /` - Toggle comment
- `Alt + Up/Down` - Move line up/down
- `Ctrl + D` - Select next occurrence

### Browser DevTools
- `F12` - Open DevTools
- `Ctrl + Shift + C` - Inspect element
- `Ctrl + Shift + M` - Toggle device toolbar
- `Ctrl + R` - Reload page
- `Ctrl + Shift + R` - Hard reload

## Resources

### Documentation
- Next.js: https://nextjs.org/docs
- React: https://react.dev
- TailwindCSS: https://tailwindcss.com/docs
- Radix UI: https://www.radix-ui.com/docs
- Zustand: https://docs.pmnd.rs/zustand

### Tools
- TypeScript Playground: https://www.typescriptlang.org/play
- Tailwind Play: https://play.tailwindcss.com
- Regex101: https://regex101.com

## Quick Commands Reference

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Start production server
npm run lint             # Run ESLint

# Package Management
npm install              # Install dependencies
npm install <package>    # Install package
npm uninstall <package>  # Uninstall package
npm update               # Update packages
npm outdated             # Check outdated packages

# Git
git status               # Check status
git add .                # Stage all changes
git commit -m "message"  # Commit changes
git push                 # Push to remote
git pull                 # Pull from remote
git log                  # View commit history

# File Operations
ls                       # List files
cd <dir>                 # Change directory
mkdir <dir>              # Create directory
rm <file>                # Remove file
cp <src> <dest>          # Copy file
mv <src> <dest>          # Move file
```

---

**Last Updated**: May 21, 2026  
**Version**: 0.1.0
