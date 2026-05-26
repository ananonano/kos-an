import type { DashboardStats, MonthlyIncome, Room, Tenant, Bill, Payment, MaintenanceReport, Announcement, Notification, RecentActivity } from "@/types";

export const seedStats: DashboardStats = {
  totalTenants: 24,
  totalRooms: 30,
  availableRooms: 6,
  occupiedRooms: 24,
  totalIncome: 48000000,
  unpaidBills: 5,
  pendingPayments: 3,
  pendingMaintenance: 4,
};

export const seedMonthlyIncome: MonthlyIncome[] = [
  { month: "Jan", income: 36000000 },
  { month: "Feb", income: 38000000 },
  { month: "Mar", income: 40000000 },
  { month: "Apr", income: 42000000 },
  { month: "Mei", income: 44000000 },
  { month: "Jun", income: 46000000 },
  { month: "Jul", income: 48000000 },
  { month: "Agu", income: 45000000 },
  { month: "Sep", income: 47000000 },
  { month: "Okt", income: 50000000 },
  { month: "Nov", income: 48000000 },
  { month: "Des", income: 52000000 },
];

export const seedRooms: any[] = [
  { id: 1, nomor_kamar: "101", harga: 1500000, status: "terisi", deskripsi: "Kamar standar lantai 1", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur", "Lemari"], foto: "", created_at: "2024-01-01" },
  { id: 2, nomor_kamar: "102", harga: 1500000, status: "kosong", deskripsi: "Kamar standar lantai 1", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur"], foto: "", created_at: "2024-01-01" },
  { id: 3, nomor_kamar: "201", harga: 2000000, status: "terisi", deskripsi: "Kamar deluxe lantai 2", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur", "Lemari", "TV", "Kulkas"], foto: "", created_at: "2024-01-01" },
  { id: 4, nomor_kamar: "202", harga: 2000000, status: "kosong", deskripsi: "Kamar deluxe lantai 2", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur", "Lemari", "TV"], foto: "", created_at: "2024-01-01" },
  { id: 5, nomor_kamar: "301", harga: 2500000, status: "terisi", deskripsi: "Kamar premium lantai 3", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur", "Lemari", "TV", "Kulkas", "Dapur Bersama"], foto: "", created_at: "2024-01-01" },
  { id: 6, nomor_kamar: "302", harga: 2500000, status: "kosong", deskripsi: "Kamar premium lantai 3", fasilitas: ["AC", "WiFi", "Kamar Mandi Dalam", "Kasur", "Lemari", "TV", "Kulkas"], foto: "", created_at: "2024-01-01" },
];

export const seedTenants: any[] = [
  { id: 1, user_id: 1, kamar_id: 1, nama: "Budi Santoso", email: "budi@email.com", no_telepon: "081234567890", tanggal_masuk: "2024-01-01", status: "aktif", created_at: "2024-01-01" },
  { id: 2, user_id: 2, kamar_id: 3, nama: "Siti Rahayu", email: "siti@email.com", no_telepon: "081234567891", tanggal_masuk: "2024-02-01", status: "aktif", created_at: "2024-02-01" },
  { id: 3, user_id: 3, kamar_id: 5, nama: "Ahmad Fauzi", email: "ahmad@email.com", no_telepon: "081234567892", tanggal_masuk: "2024-03-01", status: "aktif", created_at: "2024-03-01" },
  { id: 4, user_id: 4, kamar_id: 1, nama: "Dewi Lestari", email: "dewi@email.com", no_telepon: "081234567893", tanggal_masuk: "2023-06-01", tanggal_keluar: "2024-01-01", status: "tidak_aktif", created_at: "2023-06-01" },
];

export const seedBills: any[] = [
  { id: 1, tenant_id: 1, bulan: "Mei", tahun: 2026, jumlah: 1500000, jatuh_tempo: "2026-05-10", status: "belum_lunas", created_at: "2026-05-01" },
  { id: 2, tenant_id: 2, bulan: "Mei", tahun: 2026, jumlah: 2000000, jatuh_tempo: "2026-05-10", status: "lunas", created_at: "2026-05-01" },
  { id: 3, tenant_id: 3, bulan: "Mei", tahun: 2026, jumlah: 2500000, jatuh_tempo: "2026-05-10", status: "belum_lunas", created_at: "2026-05-01" },
  { id: 4, tenant_id: 1, bulan: "April", tahun: 2026, jumlah: 1500000, jatuh_tempo: "2026-04-10", status: "lunas", created_at: "2026-04-01" },
];

export const seedPayments: any[] = [
  { id: 1, bill_id: 2, tenant_id: 2, jumlah: 2000000, bukti_pembayaran: "", status: "lunas", tanggal_bayar: "2026-05-05", created_at: "2026-05-05" },
  { id: 2, bill_id: 4, tenant_id: 1, jumlah: 1500000, bukti_pembayaran: "", status: "lunas", tanggal_bayar: "2026-04-08", created_at: "2026-04-08" },
  { id: 3, bill_id: 1, tenant_id: 1, jumlah: 1500000, bukti_pembayaran: "", status: "menunggu_verifikasi", tanggal_bayar: "2026-05-12", created_at: "2026-05-12" },
];

export const seedMaintenance: any[] = [
  { id: 1, tenant_id: 1, kamar_id: 1, judul: "AC tidak dingin", deskripsi: "AC di kamar 101 tidak berfungsi dengan baik, sudah 3 hari tidak dingin.", status: "diproses", prioritas: "tinggi", kategori: "AC", created_at: "2026-05-10" },
  { id: 2, tenant_id: 2, kamar_id: 3, judul: "Keran bocor", deskripsi: "Keran kamar mandi bocor dan air terus mengalir.", status: "baru", prioritas: "sedang", kategori: "Kamar Mandi", created_at: "2026-05-14" },
  { id: 3, tenant_id: 3, kamar_id: 5, judul: "Lampu mati", deskripsi: "Lampu kamar utama mati dan perlu diganti.", status: "selesai", prioritas: "rendah", kategori: "Listrik", created_at: "2026-05-08" },
  { id: 4, tenant_id: 1, kamar_id: 1, judul: "Pintu susah dikunci", deskripsi: "Kunci pintu kamar susah diputar.", status: "baru", prioritas: "sedang", kategori: "Pintu", created_at: "2026-05-16" },
];

export const seedAnnouncements: any[] = [
  { id: 1, judul: "Jadwal Pemadaman Listrik", konten: "Akan ada pemadaman listrik pada tanggal 20 Mei 2026 pukul 08.00-12.00 WIB untuk pemeliharaan jaringan PLN.", kategori: "Informasi", prioritas: "urgent", target: "semua", created_at: "2026-05-15" },
  { id: 2, judul: "Peraturan Baru Tamu", konten: "Mulai 1 Juni 2026, tamu hanya diperbolehkan berkunjung hingga pukul 21.00 WIB. Harap mematuhi peraturan ini.", kategori: "Peraturan", prioritas: "penting", target: "semua", created_at: "2026-05-10" },
  { id: 3, judul: "Pembayaran Bulan Juni", konten: "Tagihan bulan Juni 2026 akan diterbitkan pada tanggal 1 Juni 2026. Harap melakukan pembayaran sebelum tanggal 10 Juni 2026.", kategori: "Pembayaran", prioritas: "info", target: "tenant", created_at: "2026-05-01" },
];

export const seedNotifications: Notification[] = [
  { id: "n1", userId: "admin", title: "Pembayaran Baru", message: "Budi Santoso telah mengirim bukti pembayaran untuk bulan Mei 2026.", type: "payment", isRead: false, createdAt: "2026-05-12T10:30:00" },
  { id: "n2", userId: "admin", title: "Keluhan Baru", message: "Siti Rahayu melaporkan keran bocor di kamar 201.", type: "maintenance", isRead: false, createdAt: "2026-05-14T14:20:00" },
  { id: "n3", userId: "admin", title: "Penghuni Baru", message: "Ahmad Fauzi telah terdaftar sebagai penghuni kamar 301.", type: "tenant", isRead: true, createdAt: "2026-05-01T09:00:00" },
  { id: "n4", userId: "admin", title: "Tagihan Jatuh Tempo", message: "5 tagihan akan jatuh tempo dalam 3 hari.", type: "bill", isRead: true, createdAt: "2026-05-07T08:00:00" },
];

export const seedActivities: RecentActivity[] = [
  { id: "act1", type: "payment", description: "Pembayaran dari Budi Santoso diverifikasi", createdAt: "2026-05-12T10:30:00" },
  { id: "act2", type: "maintenance", description: "Keluhan AC kamar 101 sedang diproses", createdAt: "2026-05-11T14:00:00" },
  { id: "act3", type: "tenant", description: "Ahmad Fauzi ditambahkan sebagai penghuni baru", createdAt: "2026-05-01T09:00:00" },
  { id: "act4", type: "announcement", description: "Pengumuman jadwal pemadaman listrik dikirim", createdAt: "2026-04-28T11:00:00" },
  { id: "act5", type: "bill", description: "Tagihan bulan Mei 2026 berhasil digenerate", createdAt: "2026-05-01T08:00:00" },
];