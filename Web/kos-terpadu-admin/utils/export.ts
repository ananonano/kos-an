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
    "Jumlah": p.amount,
    "Tanggal Bayar": formatDate(p.paymentDate),
    "Status": p.status === "verified" ? "Lunas" : p.status === "pending" ? "Pending" : "Ditolak",
  }));
  exportToExcel(data, "laporan-pembayaran", "Pembayaran");
}

export function exportBillsExcel(bills: Bill[]) {
  const data = bills.map((b, i) => ({
    "No": i + 1,
    "Periode": `${getMonthName(b.month)} ${b.year}`,
    "Jumlah": b.amount,
    "Jatuh Tempo": formatDate(b.dueDate),
    "Status": b.status === "paid" ? "Lunas" : b.status === "pending" ? "Belum Bayar" : "Jatuh Tempo",
  }));
  exportToExcel(data, "laporan-tagihan", "Tagihan");
}

export function exportTenantsExcel(tenants: Tenant[]) {
  const data = tenants.map((t, i) => ({
    "No": i + 1,
    "Nama": t.user.name,
    "Email": t.user.email,
    "No. HP": t.user.phone || "-",
    "Kamar": `Kamar ${t.room.roomNumber}`,
    "Tgl Masuk": formatDate(t.startDate),
    "Status": t.status === "active" ? "Aktif" : "Nonaktif",
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
      formatCurrency(p.amount),
      formatDate(p.paymentDate),
      p.status === "verified" ? "Lunas" : p.status === "pending" ? "Pending" : "Ditolak",
    ];
    row.forEach((cell, i) => {
      doc.text(cell, x, y);
      x += colWidths[i];
    });
  });

  // Summary
  y += 15;
  const total = payments.filter(p => p.status === "verified").reduce((s, p) => s + p.amount, 0);
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
      `${getMonthName(b.month)} ${b.year}`,
      formatCurrency(b.amount),
      formatDate(b.dueDate),
      b.status === "paid" ? "Lunas" : b.status === "pending" ? "Belum Bayar" : "Jatuh Tempo",
    ];
    row.forEach((cell, i) => { doc.text(cell, x, y); x += colWidths[i]; });
  });

  doc.save("laporan-tagihan.pdf");
}