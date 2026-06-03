"use client";
import { useState, useEffect } from "react";
import { CheckCircle, XCircle, Eye, Download, FileSpreadsheet } from "lucide-react";
import { exportPaymentsExcel, exportPaymentsPDF } from "@/utils/export";
import { PageHeader } from "@/components/shared/PageHeader";
import { DataTable } from "@/components/shared/DataTable";
import { PaymentStatusBadge } from "@/components/shared/StatusBadge";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency, formatDate } from "@/lib/utils";
import { toast } from "@/components/ui/toaster";
import type { PaymentStatus } from "@/types";
import api from "@/lib/axios";

export default function PaymentsPage() {
  const [payments, setPayments] = useState<any[]>([]);
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [viewPayment, setViewPayment] = useState<any | null>(null);
  const [confirmAction, setConfirmAction] = useState<{ type: "verify" | "reject"; payment: any } | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  // Fetch payments from backend
  useEffect(() => {
    fetchPayments();
  }, []);

  const fetchPayments = async () => {
    try {
      setIsFetching(true);
      const response = await api.get("/payments");
      if (response.data.success) {
        setPayments(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch payments error:", error);
      toast({
        title: "Gagal memuat data pembayaran",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsFetching(false);
    }
  };

  const filtered = payments.filter(p => statusFilter ? p.status === statusFilter : true);

  const handleVerify = async () => {
    if (!confirmAction) return;
    try {
      setIsLoading(true);
      const response = await api.post(`/payments/${confirmAction.payment.id}/verify`);
      if (response.data.success) {
        toast({ title: "Pembayaran diverifikasi", description: "Status pembayaran berhasil diperbarui.", variant: "success" });
        fetchPayments(); // Refresh data
      }
      setConfirmAction(null);
    } catch (error: any) {
      console.error("Verify payment error:", error);
      toast({
        title: "Gagal verifikasi pembayaran",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleReject = async () => {
    if (!confirmAction) return;
    try {
      setIsLoading(true);
      const response = await api.post(`/payments/${confirmAction.payment.id}/reject`, {
        keterangan: "Pembayaran ditolak oleh admin"
      });
      if (response.data.success) {
        toast({ title: "Pembayaran ditolak", variant: "destructive" });
        fetchPayments(); // Refresh data
      }
      setConfirmAction(null);
    } catch (error: any) {
      console.error("Reject payment error:", error);
      toast({
        title: "Gagal menolak pembayaran",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const columns = [
    { key: "id", header: "ID", render: (p: any) => <span className="font-mono text-xs text-muted-foreground">#{p.id}</span> },
    { key: "tenant", header: "Penghuni", render: (p: any) => <span className="font-medium">{p.nama_tenant || "-"}</span> },
    { key: "bill", header: "Tagihan", render: (p: any) => <span className="text-sm">{p.bulan || "-"} {p.tahun || ""}</span> },
    { key: "amount", header: "Jumlah", render: (p: any) => <span className="font-semibold">{formatCurrency(p.jumlah)}</span> },
    { key: "paymentDate", header: "Tgl Bayar", render: (p: any) => <span className="text-sm">{p.tanggal_bayar ? formatDate(p.tanggal_bayar) : "-"}</span> },
    {
      key: "status", header: "Status", render: (p: any) => {
        return <PaymentStatusBadge status={p.status} />;
      }
    },
    {
      key: "actions", header: "Aksi", render: (p: any) => (
        <div className="flex gap-1">
          <Button variant="ghost" size="icon" onClick={() => setViewPayment(p)} title="Lihat detail">
            <Eye className="w-4 h-4" />
          </Button>
          {p.status === "menunggu_verifikasi" && (
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
      )
    },
  ];

  const summary = {
    total: payments.length,
    verified: payments.filter(p => p.status === "lunas").length,
    pending: payments.filter(p => p.status === "menunggu_verifikasi").length,
    rejected: payments.filter(p => p.status === "ditolak").length,
    totalAmount: payments.filter(p => p.status === "lunas").reduce((s, p) => s + parseFloat(p.jumlah || 0), 0),
  };

  if (isFetching) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Memuat data pembayaran...</p>
        </div>
      </div>
    );
  }

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
          { label: "Total Pembayaran", value: summary.total, color: "text-[#A23900]" },
          { label: "Terverifikasi", value: summary.verified, color: "text-emerald-600" },
          { label: "Pending", value: summary.pending, color: "text-amber-600" },
          { label: "Total Diterima", value: formatCurrency(summary.totalAmount), color: "text-[#A23900]" },
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
        {(["", "menunggu_verifikasi", "lunas", "ditolak"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "menunggu_verifikasi" ? "Pending" : s === "lunas" ? "Terverifikasi" : "Ditolak"}
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
                  { label: "Jumlah", value: formatCurrency(viewPayment.jumlah) },
                  { label: "Tanggal Bayar", value: viewPayment.tanggal_bayar ? formatDate(viewPayment.tanggal_bayar) : "-" },
                  { label: "Metode", value: viewPayment.metode_pembayaran || "-" },
                ].map(({ label, value }) => (
                  <div key={label} className="space-y-1">
                    <p className="text-muted-foreground text-xs">{label}</p>
                    <div className="font-medium">{value}</div>
                  </div>
                ))}
              </div>
              {viewPayment.keterangan && (
                <div className="border rounded-lg p-3 bg-muted/30">
                  <p className="text-xs text-muted-foreground mb-1">Keterangan</p>
                  <p className="text-sm">{viewPayment.keterangan}</p>
                </div>
              )}
              <div className="border rounded-lg p-4 bg-muted/30 text-center">
                <p className="text-sm text-muted-foreground">Bukti Pembayaran</p>
                {viewPayment.bukti_pembayaran ? (
                  <img src={viewPayment.bukti_pembayaran} alt="Bukti" className="mt-2 rounded-lg max-h-48 mx-auto" />
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
