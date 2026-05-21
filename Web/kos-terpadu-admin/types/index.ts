export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: "admin" | "tenant";
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}
export interface LoginCredentials { email: string; password: string; }
export interface LoginResponse { user: User; token: string; }
export type RoomStatus = "available" | "occupied" | "maintenance";
export interface Room {
  id: string; roomNumber: string; price: number; status: RoomStatus;
  description?: string; facilities: string[]; images: string[];
  createdAt: string; updatedAt?: string;
}
export interface RoomFormData { roomNumber: string; price: number; status: RoomStatus; description?: string; facilities: string[]; }
export type TenantStatus = "active" | "inactive";
export interface Tenant {
  id: string; userId: string; roomId: string; startDate: string;
  endDate?: string; status: TenantStatus; user: User; room: Room; createdAt: string;
}
export interface TenantFormData { name: string; email: string; phone: string; roomId: string; startDate: string; endDate?: string; }
export type BillStatus = "pending" | "paid" | "overdue";
export interface Bill {
  id: string; tenantId: string; month: number; year: number; amount: number;
  dueDate: string; status: BillStatus; tenant?: Tenant; payment?: Payment; createdAt: string;
}
export type PaymentStatus = "pending" | "verified" | "rejected";
export interface Payment {
  id: string; billId: string; amount: number; proofImage?: string;
  status: PaymentStatus; paymentDate: string; bill?: Bill; createdAt: string;
}
export type MaintenanceStatus = "pending" | "in_progress" | "completed";
export interface MaintenanceReport {
  id: string; tenantId: string; title: string; description: string;
  status: MaintenanceStatus; tenant?: Tenant; progress?: MaintenanceProgress[]; createdAt: string;
}
export interface MaintenanceProgress { id: string; reportId: string; description: string; image?: string; createdAt: string; }
export interface Announcement { id: string; title: string; content: string; createdAt: string; updatedAt?: string; }
export interface AnnouncementFormData { title: string; content: string; }
export type NotificationType = "payment" | "maintenance" | "chat" | "tenant" | "bill";
export interface Notification { id: string; userId: string; title: string; message: string; type: NotificationType; isRead: boolean; createdAt: string; }
export interface ChatMessage { id: string; senderId: string; receiverId: string; message: string; image?: string; timestamp: string; read: boolean; }
export interface ChatRoom { id: string; tenant: User; lastMessage?: ChatMessage; unreadCount: number; }
export interface DashboardStats { totalTenants: number; totalRooms: number; availableRooms: number; occupiedRooms: number; totalIncome: number; unpaidBills: number; pendingPayments: number; pendingMaintenance: number; }
export interface MonthlyIncome { month: string; income: number; }
export interface RecentActivity { id: string; type: string; description: string; createdAt: string; }
export interface ApiResponse<T> { success: boolean; data: T; message?: string; }
export interface PaginatedResponse<T> { success: boolean; data: T[]; pagination: { page: number; limit: number; total: number; totalPages: number; }; }
export interface PaginationParams { page?: number; limit?: number; search?: string; }
export interface RoomFilterParams extends PaginationParams { status?: RoomStatus | ""; }
export interface TenantFilterParams extends PaginationParams { status?: TenantStatus | ""; }
export interface PaymentFilterParams extends PaginationParams { status?: PaymentStatus | ""; month?: number; year?: number; }