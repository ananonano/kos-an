import type { Bill, Payment, Tenant } from "@/types";
import { formatCurrency, formatDate, getMonthName } from "@/lib/utils";

//  EXCEL EXPORT 
export async function exportToExcel(data: any[], filename: string, sheetName = "Data") {
  const XLSX = await import("xlsx");
  const ws = XLSX.utils.json_to_sheet(data);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, sheetName);
  XLSX.writeFile(wb, `${filename}.xlsx`);
}

export function exportPaymentsExcel(payments: Payment[]) {
  const data = payments.map((p, i) => ({
    "No": i + 1,
    "ID Pembayaran": p.id,
    "Jumlah": p.jumlah,
    "Tanggal Bayar": formatDate(p.tanggal_bayar),
    "Status": p.status === "lunas" ? "Lunas" : p.status === "menunggu_verifikasi" ? "Menunggu Verifikasi" : "Ditolak",
  }));
  exportToExcel(data, "laporan-pembayaran", "Pembayaran");
}

export function exportBillsExcel(bills: Bill[]) {
  const data = bills.map((b, i) => ({
    "No": i + 1,
    "Periode": `${b.bulan} ${b.tahun}`,
    "Jumlah": b.jumlah,
    "Jatuh Tempo": formatDate(b.jatuh_tempo),
    "Status": b.status === "lunas" ? "Lunas" : b.status === "belum_lunas" ? "Belum Lunas" : "Terlambat",
  }));
  exportToExcel(data, "laporan-tagihan", "Tagihan");
}

export function exportTenantsExcel(tenants: Tenant[]) {
  const data = tenants.map((t, i) => ({
    "No": i + 1,
    "Nama": t.nama,
    "Email": t.email,
    "No. HP": t.no_telepon || "-",
    "Kamar": t.nomor_kamar ? `Kamar ${t.nomor_kamar}` : "-",
    "Tgl Masuk": t.tanggal_masuk ? formatDate(t.tanggal_masuk) : "-",
    "Status": t.status === "aktif" ? "Aktif" : "Tidak Aktif",
  }));
  exportToExcel(data, "data-penghuni", "Penghuni");
}

//  PDF EXPORT 
export async function exportPaymentsPDF(payments: Payment[]) {
  const { default: jsPDF } = await import("jspdf");
  const doc = new jsPDF();

  // Header
  doc.setFontSize(18);
  doc.setTextColor(30, 64, 175);
  doc.text("KosTerpadu Admin", 14, 20);
  doc.setFontSize(12);
  doc.setTextColor(100, 100, 100);
  doc.text("Laporan Pembayaran", 14, 28);
  doc.text(`Dicetak: ${formatDate(new Date())}`, 14, 35);

  // Line
  doc.setDrawColor(200, 200, 200);
  doc.line(14, 40, 196, 40);

  // Table header
  doc.setFontSize(10);
  doc.setTextColor(0, 0, 0);
  doc.setFont("helvetica", "bold");
  const headers = ["No", "ID", "Jumlah", "Tgl Bayar", "Status"];
  const colWidths = [10, 30, 45, 45, 35];
  let x = 14;
  let y = 50;

  headers.forEach((h, i) => {
    doc.text(h, x, y);
    x += colWidths[i];
  });

  // Table rows
  doc.setFont("helvetica", "normal");
  payments.forEach((p, idx) => {
    y += 8;
    if (y > 270) { doc.addPage(); y = 20; }
    x = 14;
    const row = [
      String(idx + 1),
      `#${p.id}`,
      formatCurrency(p.jumlah),
      formatDate(p.tanggal_bayar),
      p.status === "lunas" ? "Lunas" : p.status === "menunggu_verifikasi" ? "Menunggu Verifikasi" : "Ditolak",
    ];
    row.forEach((cell, i) => {
      doc.text(cell, x, y);
      x += colWidths[i];
    });
  });

  // Summary
  y += 15;
  const total = payments.filter(p => p.status === "lunas").reduce((s, p) => s + p.jumlah, 0);
  doc.setFont("helvetica", "bold");
  doc.text(`Total Diterima: ${formatCurrency(total)}`, 14, y);

  doc.save("laporan-pembayaran.pdf");
}

export async function exportBillsPDF(bills: Bill[]) {
  const { default: jsPDF } = await import("jspdf");
  const doc = new jsPDF();

  doc.setFontSize(18);
  doc.setTextColor(30, 64, 175);
  doc.text("KosTerpadu Admin", 14, 20);
  doc.setFontSize(12);
  doc.setTextColor(100, 100, 100);
  doc.text("Laporan Tagihan", 14, 28);
  doc.text(`Dicetak: ${formatDate(new Date())}`, 14, 35);
  doc.setDrawColor(200, 200, 200);
  doc.line(14, 40, 196, 40);

  doc.setFontSize(10);
  doc.setTextColor(0, 0, 0);
  doc.setFont("helvetica", "bold");
  const headers = ["No", "Periode", "Jumlah", "Jatuh Tempo", "Status"];
  const colWidths = [10, 40, 45, 45, 35];
  let x = 14, y = 50;
  headers.forEach((h, i) => { doc.text(h, x, y); x += colWidths[i]; });

  doc.setFont("helvetica", "normal");
  bills.forEach((b, idx) => {
    y += 8;
    if (y > 270) { doc.addPage(); y = 20; }
    x = 14;
    const row = [
      String(idx + 1),
      `${b.bulan} ${b.tahun}`,
      formatCurrency(b.jumlah),
      formatDate(b.jatuh_tempo),
      b.status === "lunas" ? "Lunas" : b.status === "belum_lunas" ? "Belum Lunas" : "Terlambat",
    ];
    row.forEach((cell, i) => { doc.text(cell, x, y); x += colWidths[i]; });
  });

  doc.save("laporan-tagihan.pdf");
}