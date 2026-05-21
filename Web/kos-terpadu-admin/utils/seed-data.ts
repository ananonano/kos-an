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

export const seedRooms: Room[] = [
  { id: "1", roomNumber: "101", price: 1500000, status: "occupied", description: "Kamar standar lantai 1", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur","Lemari"], images: [], createdAt: "2024-01-01" },
  { id: "2", roomNumber: "102", price: 1500000, status: "available", description: "Kamar standar lantai 1", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur"], images: [], createdAt: "2024-01-01" },
  { id: "3", roomNumber: "201", price: 2000000, status: "occupied", description: "Kamar deluxe lantai 2", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur","Lemari","TV","Kulkas"], images: [], createdAt: "2024-01-01" },
  { id: "4", roomNumber: "202", price: 2000000, status: "maintenance", description: "Kamar deluxe lantai 2", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur","Lemari","TV"], images: [], createdAt: "2024-01-01" },
  { id: "5", roomNumber: "301", price: 2500000, status: "occupied", description: "Kamar premium lantai 3", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur","Lemari","TV","Kulkas","Dapur Bersama"], images: [], createdAt: "2024-01-01" },
  { id: "6", roomNumber: "302", price: 2500000, status: "available", description: "Kamar premium lantai 3", facilities: ["AC","WiFi","Kamar Mandi Dalam","Kasur","Lemari","TV","Kulkas"], images: [], createdAt: "2024-01-01" },
];

export const seedTenants: Tenant[] = [
  { id: "1", userId: "u1", roomId: "1", startDate: "2024-01-01", status: "active", user: { id: "u1", name: "Budi Santoso", email: "budi@email.com", phone: "081234567890", role: "tenant", createdAt: "2024-01-01", updatedAt: "2024-01-01" }, room: seedRooms[0], createdAt: "2024-01-01" },
  { id: "2", userId: "u2", roomId: "3", startDate: "2024-02-01", status: "active", user: { id: "u2", name: "Siti Rahayu", email: "siti@email.com", phone: "081234567891", role: "tenant", createdAt: "2024-02-01", updatedAt: "2024-02-01" }, room: seedRooms[2], createdAt: "2024-02-01" },
  { id: "3", userId: "u3", roomId: "5", startDate: "2024-03-01", status: "active", user: { id: "u3", name: "Ahmad Fauzi", email: "ahmad@email.com", phone: "081234567892", role: "tenant", createdAt: "2024-03-01", updatedAt: "2024-03-01" }, room: seedRooms[4], createdAt: "2024-03-01" },
  { id: "4", userId: "u4", roomId: "1", startDate: "2023-06-01", endDate: "2024-01-01", status: "inactive", user: { id: "u4", name: "Dewi Lestari", email: "dewi@email.com", phone: "081234567893", role: "tenant", createdAt: "2023-06-01", updatedAt: "2024-01-01" }, room: seedRooms[0], createdAt: "2023-06-01" },
];

export const seedBills: Bill[] = [
  { id: "b1", tenantId: "1", month: 5, year: 2026, amount: 1500000, dueDate: "2026-05-10", status: "pending", createdAt: "2026-05-01" },
  { id: "b2", tenantId: "2", month: 5, year: 2026, amount: 2000000, dueDate: "2026-05-10", status: "paid", createdAt: "2026-05-01" },
  { id: "b3", tenantId: "3", month: 5, year: 2026, amount: 2500000, dueDate: "2026-05-10", status: "pending", createdAt: "2026-05-01" },
  { id: "b4", tenantId: "1", month: 4, year: 2026, amount: 1500000, dueDate: "2026-04-10", status: "paid", createdAt: "2026-04-01" },
];

export const seedPayments: Payment[] = [
  { id: "p1", billId: "b2", amount: 2000000, proofImage: "", status: "verified", paymentDate: "2026-05-05", createdAt: "2026-05-05" },
  { id: "p2", billId: "b4", amount: 1500000, proofImage: "", status: "verified", paymentDate: "2026-04-08", createdAt: "2026-04-08" },
  { id: "p3", billId: "b1", amount: 1500000, proofImage: "", status: "pending", paymentDate: "2026-05-12", createdAt: "2026-05-12" },
];

export const seedMaintenance: MaintenanceReport[] = [
  { id: "m1", tenantId: "1", title: "AC tidak dingin", description: "AC di kamar 101 tidak berfungsi dengan baik, sudah 3 hari tidak dingin.", status: "in_progress", createdAt: "2026-05-10" },
  { id: "m2", tenantId: "2", title: "Keran bocor", description: "Keran kamar mandi bocor dan air terus mengalir.", status: "pending", createdAt: "2026-05-14" },
  { id: "m3", tenantId: "3", title: "Lampu mati", description: "Lampu kamar utama mati dan perlu diganti.", status: "completed", createdAt: "2026-05-08" },
  { id: "m4", tenantId: "1", title: "Pintu susah dikunci", description: "Kunci pintu kamar susah diputar.", status: "pending", createdAt: "2026-05-16" },
];

export const seedAnnouncements: Announcement[] = [
  { id: "a1", title: "Jadwal Pemadaman Listrik", content: "Akan ada pemadaman listrik pada tanggal 20 Mei 2026 pukul 08.00-12.00 WIB untuk pemeliharaan jaringan PLN.", createdAt: "2026-05-15" },
  { id: "a2", title: "Peraturan Baru Tamu", content: "Mulai 1 Juni 2026, tamu hanya diperbolehkan berkunjung hingga pukul 21.00 WIB. Harap mematuhi peraturan ini.", createdAt: "2026-05-10" },
  { id: "a3", title: "Pembayaran Bulan Juni", content: "Tagihan bulan Juni 2026 akan diterbitkan pada tanggal 1 Juni 2026. Harap melakukan pembayaran sebelum tanggal 10 Juni 2026.", createdAt: "2026-05-01" },
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