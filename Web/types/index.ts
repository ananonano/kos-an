export interface User {
  id: number;
  nama: string;
  email: string;
  no_telepon?: string;
  role: "admin" | "tenant";
  foto?: string;
  created_at: string;
  updated_at: string;
}
export interface LoginCredentials { email: string; password: string; }
export interface LoginResponse { user: User; token: string; }
export type RoomStatus = "kosong" | "terisi";
export interface Room {
  id: number;
  nomor_kamar: string;
  tipe: string;
  harga: number;
  status: RoomStatus;
  deskripsi?: string;
  fasilitas: string[];
  foto?: string;
  created_at: string;
  updated_at?: string;
}
export interface RoomFormData {
  nomor_kamar: string;
  tipe: string;
  harga: number;
  status: RoomStatus;
  deskripsi?: string;
  fasilitas: string[];
}
export type TenantStatus = "aktif" | "tidak_aktif";
export interface Tenant {
  id: number;
  user_id: number;
  kamar_id?: number;
  nama: string;
  email: string;
  no_telepon: string;
  alamat_asal?: string;
  pekerjaan?: string;
  kontak_darurat?: string;
  tanggal_masuk?: string;
  tanggal_keluar?: string;
  status: TenantStatus;
  nomor_kamar?: string;
  created_at: string;
  updated_at?: string;
}
export interface TenantFormData {
  nama: string;
  email: string;
  no_telepon: string;
  kamar_id?: number;
  alamat_asal?: string;
  pekerjaan?: string;
  kontak_darurat?: string;
  tanggal_masuk?: string;
  tanggal_keluar?: string;
}
export type BillStatus = "belum_lunas" | "lunas" | "terlambat";
export interface Bill {
  id: number;
  tenant_id: number;
  contract_id?: number;
  bulan: string;
  tahun: number;
  jumlah: number;
  status: BillStatus;
  jatuh_tempo: string;
  denda?: number;
  catatan?: string;
  tenant_name?: string;
  tenant_email?: string;
  nomor_kamar?: string;
  created_at: string;
  updated_at?: string;
}
export type PaymentStatus = "menunggu_verifikasi" | "lunas" | "ditolak";
export interface Payment {
  id: number;
  bill_id: number;
  tenant_id: number;
  jumlah: number;
  tanggal_bayar: string;
  metode_pembayaran: string;
  bukti_pembayaran?: string;
  status: PaymentStatus;
  keterangan?: string;
  verified_by?: number;
  verified_at?: string;
  nama_tenant?: string;
  bulan?: string;
  tahun?: number;
  nomor_kamar?: string;
  created_at: string;
  updated_at?: string;
}
export type MaintenanceStatus = "baru" | "diproses" | "selesai" | "ditolak";
export interface MaintenanceReport {
  id: number;
  tenant_id: number;
  kamar_id?: number;
  judul: string;
  deskripsi: string;
  kategori: string;
  prioritas: string;
  status: MaintenanceStatus;
  foto?: string[];
  tanggal_lapor: string;
  tanggal_selesai?: string;
  komentar_admin?: string;
  biaya?: number;
  nama_tenant?: string;
  nomor_kamar?: string;
  created_at: string;
  updated_at?: string;
}
export interface MaintenanceProgress { id: string; reportId: string; description: string; image?: string; createdAt: string; }
export interface Announcement {
  id: number;
  judul: string;
  konten: string;
  kategori: string;
  prioritas: "info" | "penting" | "urgent";
  target: "semua" | "tenant" | "admin";
  created_by: number;
  created_by_name?: string;
  is_active: boolean;
  created_at: string;
  updated_at?: string;
}
export interface AnnouncementFormData {
  judul: string;
  konten: string;
  kategori: string;
  prioritas: "info" | "penting" | "urgent";
  target: "semua" | "tenant" | "admin";
}
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