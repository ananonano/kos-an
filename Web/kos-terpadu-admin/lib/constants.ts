export const ROOM_STATUS = {
  kosong: { label: "Tersedia", color: "bg-emerald-100 text-emerald-700" },
  terisi: { label: "Terisi", color: "bg-blue-100 text-blue-700" },
} as const;

export const PAYMENT_STATUS = {
  menunggu_verifikasi: { label: "Menunggu", color: "bg-amber-100 text-amber-700" },
  lunas: { label: "Lunas", color: "bg-emerald-100 text-emerald-700" },
  ditolak: { label: "Ditolak", color: "bg-red-100 text-red-700" },
} as const;

export const BILL_STATUS = {
  belum_lunas: { label: "Belum Bayar", color: "bg-amber-100 text-amber-700" },
  lunas: { label: "Lunas", color: "bg-emerald-100 text-emerald-700" },
  terlambat: { label: "Jatuh Tempo", color: "bg-red-100 text-red-700" },
} as const;

export const MAINTENANCE_STATUS = {
  baru: { label: "Pending", color: "bg-amber-100 text-amber-700" },
  diproses: { label: "Diproses", color: "bg-blue-100 text-blue-700" },
  selesai: { label: "Selesai", color: "bg-emerald-100 text-emerald-700" },
  ditolak: { label: "Ditolak", color: "bg-red-100 text-red-700" },
} as const;

export const TENANT_STATUS = {
  aktif: { label: "Aktif", color: "bg-emerald-100 text-emerald-700" },
  tidak_aktif: { label: "Nonaktif", color: "bg-slate-100 text-slate-700" },
} as const;

export const MONTHS = [
  "Januari", "Februari", "Maret", "April", "Mei", "Juni",
  "Juli", "Agustus", "September", "Oktober", "November", "Desember"
];

export const FACILITIES_OPTIONS = [
  "AC", "WiFi", "Kamar Mandi Dalam", "Kamar Mandi Luar", "Lemari", "Kasur",
  "Meja Belajar", "Kursi", "TV", "Kulkas", "Dapur Bersama", "Parkir Motor",
  "Parkir Mobil", "Laundry", "CCTV", "Security 24 Jam",
];

export const ITEMS_PER_PAGE = 10;