"use client";
import { useState, useEffect } from "react";
import { Zap, FileText, Download, FileSpreadsheet } from "lucide-react";
import { exportBillsExcel, exportBillsPDF } from "@/utils/export";
import { PageHeader } from "@/components/shared/PageHeader";
import { DataTable } from "@/components/shared/DataTable";
import { BillStatusBadge } from "@/components/shared/StatusBadge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Card, CardContent } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { formatCurrency, formatDate, getMonthName } from "@/lib/utils";
import { MONTHS } from "@/lib/constants";
import { toast } from "@/components/ui/toaster";
import type { BillStatus } from "@/types";
import api from "@/lib/axios";

export default function BillsPage() {
  const [bills, setBills] = useState<any[]>([]);
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [generateOpen, setGenerateOpen] = useState(false);
  const [genMonth, setGenMonth] = useState(String(new Date().getMonth() + 1));
  const [genYear, setGenYear] = useState(String(new Date().getFullYear()));
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  // Fetch bills from backend
  useEffect(() => {
    updateOverdueBills();
  }, []);

  const updateOverdueBills = async () => {
    try {
      // Auto-update overdue bills first
      await api.post("/bills/update-overdue");
    } catch (error: any) {
      console.error("Update overdue error:", error);
    } finally {
      // Then fetch bills
      fetchBills();
    }
  };

  const fetchBills = async () => {
    try {
      setIsFetching(true);
      const response = await api.get("/bills");
      if (response.data.success) {
        setBills(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch bills error:", error);
      toast({
        title: "Gagal memuat data tagihan",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsFetching(false);
    }
  };

  const filtered = bills.filter(b => statusFilter ? b.status === statusFilter : true);

  const handleGenerate = async () => {
    try {
      setIsLoading(true);

      const response = await api.post("/bills/generate-monthly", {
        bulan: MONTHS[parseInt(genMonth) - 1],
        tahun: parseInt(genYear)
      });

      if (response.data.success) {
        toast({
          title: "Tagihan berhasil digenerate",
          description: `Tagihan ${MONTHS[parseInt(genMonth) - 1]} ${genYear}`,
          variant: "success"
        });
        fetchBills(); // Refresh data
      }

      setGenerateOpen(false);
    } catch (error: any) {
      console.error("Generate bills error:", error);
      toast({
        title: "Gagal generate tagihan",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const columns = [
    {
      key: "tenant", header: "Penghuni", render: (b: any) => {
        return <span className="font-medium">{b.nama_tenant || "-"}</span>;
      }
    },
    {
      key: "room", header: "Kamar", render: (b: any) => {
        return <span>Kamar {b.nomor_kamar || "-"}</span>;
      }
    },
    { key: "period", header: "Periode", render: (b: any) => <span className="font-medium">{b.bulan} {b.tahun}</span> },
    { key: "amount", header: "Jumlah", render: (b: any) => <span className="font-semibold">{formatCurrency(b.jumlah)}</span> },
    {
      key: "dueDate", header: "Jatuh Tempo", render: (b: any) => (
        <span className={`text-sm ${new Date(b.jatuh_tempo) < new Date() && b.status === "belum_lunas" ? "text-red-500 font-medium" : ""}`}>
          {b.jatuh_tempo ? formatDate(b.jatuh_tempo) : "-"}
        </span>
      )
    },
    {
      key: "status", header: "Status", render: (b: any) => {
        return <BillStatusBadge status={b.status} />;
      }
    },
  ];

  const summary = {
    total: bills.length,
    paid: bills.filter(b => b.status === "lunas").length,
    pending: bills.filter(b => b.status === "belum_lunas").length,
    overdue: bills.filter(b => b.status === "terlambat").length,
    totalAmount: bills.filter(b => b.status === "lunas").reduce((s, b) => s + parseFloat(b.jumlah || 0), 0),
  };

  const years = [2024, 2025, 2026, 2027];

  if (isFetching) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Memuat data tagihan...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Manajemen Tagihan" description="Generate dan monitor tagihan bulanan penghuni"
        actions={
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => exportBillsExcel(filtered)}>
              <FileSpreadsheet className="w-4 h-4 mr-2" />Excel
            </Button>
            <Button variant="outline" size="sm" onClick={() => exportBillsPDF(filtered)}>
              <Download className="w-4 h-4 mr-2" />PDF
            </Button>
            <Button onClick={() => setGenerateOpen(true)}>
              <Zap className="w-4 h-4 mr-2" />Generate Tagihan
            </Button>
          </div>
        }
      />

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Total Tagihan", value: summary.total, color: "text-blue-600" },
          { label: "Lunas", value: summary.paid, color: "text-emerald-600" },
          { label: "Belum Bayar", value: summary.pending, color: "text-amber-600" },
          { label: "Total Terkumpul", value: formatCurrency(summary.totalAmount), color: "text-purple-600" },
        ].map((s) => (
          <Card key={s.label}><CardContent className="pt-4 pb-4">
            <p className="text-xs text-muted-foreground">{s.label}</p>
            <p className={`text-xl font-bold mt-1 ${s.color}`}>{s.value}</p>
          </CardContent></Card>
        ))}
      </div>

      <div className="flex gap-3 flex-wrap">
        {(["", "belum_lunas", "lunas", "terlambat"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "belum_lunas" ? "Belum Bayar" : s === "lunas" ? "Lunas" : "Jatuh Tempo"}
          </button>
        ))}
      </div>

      <Card><CardContent className="pt-6">
        <DataTable data={filtered} columns={columns} emptyMessage="Tidak ada tagihan" />
      </CardContent></Card>

      <Dialog open={generateOpen} onOpenChange={setGenerateOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader><DialogTitle>Generate Tagihan Bulanan</DialogTitle></DialogHeader>
          <div className="space-y-4">
            <div className="bg-blue-50 dark:bg-blue-950/30 rounded-lg p-4 text-sm text-blue-700 dark:text-blue-300">
              <p className="font-medium">Tagihan akan digenerate untuk semua penghuni aktif.</p>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Bulan</Label>
                <Select value={genMonth} onValueChange={setGenMonth}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {MONTHS.map((m, i) => <SelectItem key={i} value={String(i + 1)}>{m}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Tahun</Label>
                <Select value={genYear} onValueChange={setGenYear}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    {years.map(y => <SelectItem key={y} value={String(y)}>{y}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setGenerateOpen(false)}>Batal</Button>
            <Button onClick={handleGenerate} loading={isLoading}>Generate</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
