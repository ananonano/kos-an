export const ROOM_STATUS = {
  available: { label: "Tersedia", color: "bg-emerald-100 text-emerald-700" },
  occupied: { label: "Terisi", color: "bg-blue-100 text-blue-700" },
  maintenance: { label: "Perbaikan", color: "bg-amber-100 text-amber-700" },
} as const;

export const PAYMENT_STATUS = {
  pending: { label: "Menunggu", color: "bg-amber-100 text-amber-700" },
  verified: { label: "Lunas", color: "bg-emerald-100 text-emerald-700" },
  rejected: { label: "Ditolak", color: "bg-red-100 text-red-700" },
} as const;

export const BILL_STATUS = {
  pending: { label: "Belum Bayar", color: "bg-amber-100 text-amber-700" },
  paid: { label: "Lunas", color: "bg-emerald-100 text-emerald-700" },
  overdue: { label: "Jatuh Tempo", color: "bg-red-100 text-red-700" },
} as const;

export const MAINTENANCE_STATUS = {
  pending: { label: "Pending", color: "bg-amber-100 text-amber-700" },
  in_progress: { label: "Diproses", color: "bg-blue-100 text-blue-700" },
  completed: { label: "Selesai", color: "bg-emerald-100 text-emerald-700" },
} as const;

export const TENANT_STATUS = {
  active: { label: "Aktif", color: "bg-emerald-100 text-emerald-700" },
  inactive: { label: "Nonaktif", color: "bg-slate-100 text-slate-700" },
} as const;

export const MONTHS = [
  "Januari","Februari","Maret","April","Mei","Juni",
  "Juli","Agustus","September","Oktober","November","Desember"
];

export const FACILITIES_OPTIONS = [
  "AC","WiFi","Kamar Mandi Dalam","Kamar Mandi Luar","Lemari","Kasur",
  "Meja Belajar","Kursi","TV","Kulkas","Dapur Bersama","Parkir Motor",
  "Parkir Mobil","Laundry","CCTV","Security 24 Jam",
];

export const ITEMS_PER_PAGE = 10;