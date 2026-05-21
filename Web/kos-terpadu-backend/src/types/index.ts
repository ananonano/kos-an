// ============================================
// TYPE DEFINITIONS - KosTerpadu Backend
// ============================================

export interface User {
    id: number;
    email: string;
    password: string;
    nama: string;
    role: 'admin' | 'tenant';
    no_telepon: string | null;
    foto: string | null;
    created_at: Date;
    updated_at: Date;
}

export interface Room {
    id: number;
    nomor_kamar: string;
    tipe: string;
    harga: number;
    status: 'kosong' | 'terisi';
    deskripsi: string | null;
    fasilitas: string[] | null;
    foto: string | null;
    created_at: Date;
    updated_at: Date;
}

export interface Tenant {
    id: number;
    user_id: number;
    kamar_id: number | null;
    nama: string;
    email: string;
    no_telepon: string;
    alamat_asal: string | null;
    pekerjaan: string | null;
    kontak_darurat: string | null;
    tanggal_masuk: Date | null;
    tanggal_keluar: Date | null;
    status: 'aktif' | 'tidak_aktif';
    created_at: Date;
    updated_at: Date;
}

export interface Contract {
    id: number;
    tenant_id: number;
    kamar_id: number;
    tanggal_mulai: Date;
    tanggal_selesai: Date | null;
    harga_per_bulan: number;
    deposit: number;
    status: 'aktif' | 'selesai' | 'dibatalkan';
    catatan: string | null;
    created_at: Date;
    updated_at: Date;
}

export interface Bill {
    id: number;
    tenant_id: number;
    contract_id: number;
    bulan: string;
    tahun: number;
    jumlah: number;
    status: 'belum_lunas' | 'lunas' | 'terlambat';
    jatuh_tempo: Date;
    denda: number;
    catatan: string | null;
    created_at: Date;
    updated_at: Date;
}

export interface Payment {
    id: number;
    bill_id: number;
    tenant_id: number;
    jumlah: number;
    tanggal_bayar: Date;
    metode_pembayaran: string;
    bukti_pembayaran: string | null;
    status: 'menunggu_verifikasi' | 'lunas' | 'ditolak';
    keterangan: string | null;
    verified_by: number | null;
    verified_at: Date | null;
    created_at: Date;
    updated_at: Date;
}

export interface Maintenance {
    id: number;
    tenant_id: number;
    kamar_id: number;
    judul: string;
    deskripsi: string;
    kategori: string;
    prioritas: 'rendah' | 'sedang' | 'tinggi' | 'urgent';
    status: 'baru' | 'diproses' | 'selesai' | 'ditolak';
    foto: string[] | null;
    tanggal_lapor: Date;
    tanggal_selesai: Date | null;
    komentar_admin: string | null;
    biaya: number | null;
    created_at: Date;
    updated_at: Date;
}

export interface Announcement {
    id: number;
    judul: string;
    konten: string;
    kategori: string;
    prioritas: 'info' | 'penting' | 'urgent';
    target: 'semua' | 'tenant' | 'admin';
    created_by: number;
    is_active: boolean;
    created_at: Date;
    updated_at: Date;
}

export interface FinancialReport {
    id: number;
    bulan: string;
    tahun: number;
    total_pendapatan: number;
    total_pengeluaran: number;
    total_tunggakan: number;
    jumlah_kamar_terisi: number;
    jumlah_kamar_kosong: number;
    tingkat_okupansi: number;
    catatan: string | null;
    created_by: number;
    created_at: Date;
    updated_at: Date;
}

// ============================================
// REQUEST/RESPONSE TYPES
// ============================================

export interface AuthRequest {
    email: string;
    password: string;
}

export interface RegisterRequest {
    email: string;
    password: string;
    nama: string;
    no_telepon?: string;
    role?: 'admin' | 'tenant';
}

export interface AuthResponse {
    success: boolean;
    message: string;
    token?: string;
    user?: Omit<User, 'password'>;
}

export interface ApiResponse<T = any> {
    success: boolean;
    message: string;
    data?: T;
    pagination?: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}

export interface PaginationQuery {
    page?: number;
    limit?: number;
    search?: string;
    sortBy?: string;
    sortOrder?: 'asc' | 'desc';
}

// ============================================
// JWT PAYLOAD
// ============================================

export interface JwtPayload {
    id: number;
    email: string;
    role: 'admin' | 'tenant';
    iat?: number;
    exp?: number;
}

// ============================================
// FIREBASE TYPES
// ============================================

export interface ChatRoom {
    id: string;
    tenant_id: string;
    admin_id: string;
    tenant_name: string;
    admin_name: string;
    last_message: string;
    last_message_time: Date;
    unread_count_tenant: number;
    unread_count_admin: number;
    created_at: Date;
    updated_at: Date;
}

export interface ChatMessage {
    id: string;
    chat_room_id: string;
    sender_id: string;
    sender_name: string;
    sender_role: 'admin' | 'tenant';
    message: string;
    image_url: string | null;
    is_read: boolean;
    created_at: Date;
}

export interface Notification {
    id: string;
    user_id: string;
    title: string;
    body: string;
    type: 'payment' | 'maintenance' | 'chat' | 'announcement' | 'system';
    data: any;
    is_read: boolean;
    created_at: Date;
}

export interface MaintenanceStatus {
    maintenance_id: string;
    status: 'baru' | 'diproses' | 'selesai' | 'ditolak';
    updated_by: string;
    updated_by_name: string;
    komentar: string | null;
    timestamp: Date;
}

export interface ActivityLog {
    id: string;
    user_id: string;
    user_name: string;
    user_role: 'admin' | 'tenant';
    action: string;
    entity_type: string;
    entity_id: string;
    description: string;
    ip_address: string | null;
    user_agent: string | null;
    created_at: Date;
}
