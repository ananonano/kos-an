"use client";
import { useState } from "react";
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
import { seedBills, seedTenants } from "@/utils/seed-data";
import { toast } from "@/components/ui/toaster";
import type { Bill, BillStatus } from "@/types";

export default function BillsPage() {
  const [bills, setBills] = useState<Bill[]>(seedBills);
  const [statusFilter, setStatusFilter] = useState<BillStatus | "">("");
  const [generateOpen, setGenerateOpen] = useState(false);
  const [genMonth, setGenMonth] = useState(String(new Date().getMonth() + 1));
  const [genYear, setGenYear] = useState(String(new Date().getFullYear()));
  const [isLoading, setIsLoading] = useState(false);

  const filtered = bills.filter(b => statusFilter ? b.status === statusFilter : true);
  const getTenant = (tenantId: string) => seedTenants.find(t => t.id === tenantId);

  const handleGenerate = async () => {
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 1000));
    const activeTenants = seedTenants.filter(t => t.status === "active");
    const newBills: Bill[] = activeTenants.map(t => ({
      id: `gen-${Date.now()}-${t.id}`,
      tenantId: t.id,
      month: parseInt(genMonth),
      year: parseInt(genYear),
      amount: t.room.price,
      dueDate: `${genYear}-${genMonth.padStart(2, "0")}-10`,
      status: "pending" as BillStatus,
      createdAt: new Date().toISOString(),
    }));
    setBills(prev => [...prev, ...newBills]);
    toast({ title: `${newBills.length} tagihan berhasil digenerate`, description: `Tagihan ${getMonthName(parseInt(genMonth))} ${genYear}`, variant: "success" });
    setIsLoading(false);
    setGenerateOpen(false);
  };

  const columns = [
    { key: "tenant", header: "Penghuni", render: (b: Bill) => {
      const t = getTenant(b.tenantId);
      return <span className="font-medium">{t?.user.name || "-"}</span>;
    }},
    { key: "room", header: "Kamar", render: (b: Bill) => {
      const t = getTenant(b.tenantId);
      return <span>Kamar {t?.room.roomNumber || "-"}</span>;
    }},
    { key: "period", header: "Periode", render: (b: Bill) => <span className="font-medium">{getMonthName(b.month)} {b.year}</span> },
    { key: "amount", header: "Jumlah", render: (b: Bill) => <span className="font-semibold">{formatCurrency(b.amount)}</span> },
    { key: "dueDate", header: "Jatuh Tempo", render: (b: Bill) => (
      <span className={`text-sm ${new Date(b.dueDate) < new Date() && b.status === "pending" ? "text-red-500 font-medium" : ""}`}>
        {formatDate(b.dueDate)}
      </span>
    )},
    { key: "status", header: "Status", render: (b: Bill) => <BillStatusBadge status={b.status} /> },
  ];

  const summary = {
    total: bills.length,
    paid: bills.filter(b => b.status === "paid").length,
    pending: bills.filter(b => b.status === "pending").length,
    overdue: bills.filter(b => b.status === "overdue").length,
    totalAmount: bills.filter(b => b.status === "paid").reduce((s, b) => s + b.amount, 0),
  };

  const years = [2024, 2025, 2026, 2027];

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
        {(["", "pending", "paid", "overdue"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "pending" ? "Belum Bayar" : s === "paid" ? "Lunas" : "Jatuh Tempo"}
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
              <p className="mt-1 text-xs">Total: {seedTenants.filter(t => t.status === "active").length} penghuni</p>
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