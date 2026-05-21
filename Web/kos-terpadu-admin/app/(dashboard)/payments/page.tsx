"use client";
import { useState } from "react";
import { CheckCircle, XCircle, Eye, Download, FileSpreadsheet } from "lucide-react";
import { exportPaymentsExcel, exportPaymentsPDF } from "@/utils/export";
import { PageHeader } from "@/components/shared/PageHeader";
import { DataTable } from "@/components/shared/DataTable";
import { PaymentStatusBadge } from "@/components/shared/StatusBadge";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency, formatDate, getMonthName } from "@/lib/utils";
import { seedPayments, seedBills, seedTenants } from "@/utils/seed-data";
import { toast } from "@/components/ui/toaster";
import type { Payment, PaymentStatus } from "@/types";

export default function PaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>(seedPayments);
  const [statusFilter, setStatusFilter] = useState<PaymentStatus | "">("");
  const [viewPayment, setViewPayment] = useState<Payment | null>(null);
  const [confirmAction, setConfirmAction] = useState<{ type: "verify" | "reject"; payment: Payment } | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const filtered = payments.filter(p => statusFilter ? p.status === statusFilter : true);

  const getBillInfo = (billId: string) => seedBills.find(b => b.id === billId);
  const getTenantInfo = (billId: string) => {
    const bill = getBillInfo(billId);
    return bill ? seedTenants.find(t => t.id === bill.tenantId) : null;
  };

  const handleVerify = async () => {
    if (!confirmAction) return;
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 800));
    setPayments(prev => prev.map(p => p.id === confirmAction.payment.id ? { ...p, status: "verified" as PaymentStatus } : p));
    toast({ title: "Pembayaran diverifikasi", description: "Status pembayaran berhasil diperbarui.", variant: "success" });
    setIsLoading(false);
    setConfirmAction(null);
  };

  const handleReject = async () => {
    if (!confirmAction) return;
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 800));
    setPayments(prev => prev.map(p => p.id === confirmAction.payment.id ? { ...p, status: "rejected" as PaymentStatus } : p));
    toast({ title: "Pembayaran ditolak", variant: "destructive" });
    setIsLoading(false);
    setConfirmAction(null);
  };

  const columns = [
    { key: "id", header: "ID", render: (p: Payment) => <span className="font-mono text-xs text-muted-foreground">#{p.id}</span> },
    { key: "tenant", header: "Penghuni", render: (p: Payment) => {
      const t = getTenantInfo(p.billId);
      return <span className="font-medium">{t?.user.name || "-"}</span>;
    }},
    { key: "bill", header: "Tagihan", render: (p: Payment) => {
      const b = getBillInfo(p.billId);
      return b ? <span className="text-sm">{getMonthName(b.month)} {b.year}</span> : "-";
    }},
    { key: "amount", header: "Jumlah", render: (p: Payment) => <span className="font-semibold">{formatCurrency(p.amount)}</span> },
    { key: "paymentDate", header: "Tgl Bayar", render: (p: Payment) => <span className="text-sm">{formatDate(p.paymentDate)}</span> },
    { key: "status", header: "Status", render: (p: Payment) => <PaymentStatusBadge status={p.status} /> },
    { key: "actions", header: "Aksi", render: (p: Payment) => (
      <div className="flex gap-1">
        <Button variant="ghost" size="icon" onClick={() => setViewPayment(p)} title="Lihat detail">
          <Eye className="w-4 h-4" />
        </Button>
        {p.status === "pending" && (
          <>
            <Button variant="ghost" size="icon" className="text-emerald-600 hover:text-emerald-700"
              onClick={() => setConfirmAction({ type: "verify", payment: p })} title="Verifikasi">
              <CheckCircle className="w-4 h-4" />
            </Button>
            <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-600"
              onClick={() => setConfirmAction({ type: "reject", payment: p })} title="Tolak">
              <XCircle className="w-4 h-4" />
            </Button>
          </>
        )}
      </div>
    )},
  ];

  const summary = {
    total: payments.length,
    verified: payments.filter(p => p.status === "verified").length,
    pending: payments.filter(p => p.status === "pending").length,
    rejected: payments.filter(p => p.status === "rejected").length,
    totalAmount: payments.filter(p => p.status === "verified").reduce((s, p) => s + p.amount, 0),
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Manajemen Pembayaran" description="Verifikasi dan monitoring pembayaran penghuni"
        actions={
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => exportPaymentsExcel(filtered)}>
              <FileSpreadsheet className="w-4 h-4 mr-2" />Excel
            </Button>
            <Button variant="outline" size="sm" onClick={() => exportPaymentsPDF(filtered)}>
              <Download className="w-4 h-4 mr-2" />PDF
            </Button>
          </div>
        }
      />

      {/* Summary Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Total Pembayaran", value: summary.total, color: "text-blue-600" },
          { label: "Terverifikasi", value: summary.verified, color: "text-emerald-600" },
          { label: "Pending", value: summary.pending, color: "text-amber-600" },
          { label: "Total Diterima", value: formatCurrency(summary.totalAmount), color: "text-purple-600" },
        ].map((s) => (
          <Card key={s.label}>
            <CardContent className="pt-4 pb-4">
              <p className="text-xs text-muted-foreground">{s.label}</p>
              <p className={`text-xl font-bold mt-1 ${s.color}`}>{s.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Filter */}
      <div className="flex gap-3 flex-wrap">
        {(["", "pending", "verified", "rejected"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "pending" ? "Pending" : s === "verified" ? "Terverifikasi" : "Ditolak"}
          </button>
        ))}
      </div>

      <Card><CardContent className="pt-6">
        <DataTable data={filtered} columns={columns} emptyMessage="Tidak ada data pembayaran" />
      </CardContent></Card>

      {/* Detail Dialog */}
      <Dialog open={!!viewPayment} onOpenChange={() => setViewPayment(null)}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>Detail Pembayaran</DialogTitle></DialogHeader>
          {viewPayment && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-3 text-sm">
                {[
                  { label: "ID Pembayaran", value: `#${viewPayment.id}` },
                  { label: "Jumlah", value: formatCurrency(viewPayment.amount) },
                  { label: "Tanggal Bayar", value: formatDate(viewPayment.paymentDate) },
                  { label: "Status", value: <PaymentStatusBadge status={viewPayment.status} /> },
                ].map(({ label, value }) => (
                  <div key={label} className="space-y-1">
                    <p className="text-muted-foreground text-xs">{label}</p>
                    <div className="font-medium">{value}</div>
                  </div>
                ))}
              </div>
              <div className="border rounded-lg p-4 bg-muted/30 text-center">
                <p className="text-sm text-muted-foreground">Bukti Pembayaran</p>
                {viewPayment.proofImage ? (
                  <img src={viewPayment.proofImage} alt="Bukti" className="mt-2 rounded-lg max-h-48 mx-auto" />
                ) : (
                  <p className="text-sm mt-2 text-muted-foreground">Tidak ada bukti pembayaran</p>
                )}
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={confirmAction?.type === "verify" ? handleVerify : handleReject}
        title={confirmAction?.type === "verify" ? "Verifikasi Pembayaran" : "Tolak Pembayaran"}
        description={confirmAction?.type === "verify"
          ? "Yakin ingin memverifikasi pembayaran ini? Status akan berubah menjadi Lunas."
          : "Yakin ingin menolak pembayaran ini? Penghuni akan diberitahu."}
        confirmLabel={confirmAction?.type === "verify" ? "Verifikasi" : "Tolak"}
        variant={confirmAction?.type === "verify" ? "default" : "destructive"}
        isLoading={isLoading}
      />
    </div>
  );
}