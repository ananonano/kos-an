"use client";
import { useState } from "react";
import { Wrench, Plus, ChevronDown, ChevronUp, ImageIcon } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { MaintenanceStatusBadge } from "@/components/shared/StatusBadge";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { formatDate, timeAgo } from "@/lib/utils";
import { seedMaintenance, seedTenants } from "@/utils/seed-data";
import { toast } from "@/components/ui/toaster";
import type { MaintenanceReport, MaintenanceStatus } from "@/types";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

const progressSchema = z.object({ description: z.string().min(1, "Deskripsi wajib diisi") });
type ProgressForm = z.infer<typeof progressSchema>;

export default function MaintenancePage() {
  const [reports, setReports] = useState<MaintenanceReport[]>(seedMaintenance);
  const [statusFilter, setStatusFilter] = useState<MaintenanceStatus | "">("");
  const [expanded, setExpanded] = useState<string | null>(null);
  const [progressDialog, setProgressDialog] = useState<MaintenanceReport | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, reset, formState: { errors } } = useForm<ProgressForm>({ resolver: zodResolver(progressSchema) });

  const filtered = reports.filter(r => statusFilter ? r.status === statusFilter : true);
  const getTenant = (id: string) => seedTenants.find(t => t.id === id);

  const updateStatus = async (id: string, status: MaintenanceStatus) => {
    setReports(prev => prev.map(r => r.id === id ? { ...r, status } : r));
    toast({ title: "Status keluhan diperbarui", variant: "success" });
  };

  const addProgress = async (data: ProgressForm) => {
    if (!progressDialog) return;
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 600));
    const newProgress = { id: Date.now().toString(), reportId: progressDialog.id, description: data.description, createdAt: new Date().toISOString() };
    setReports(prev => prev.map(r => r.id === progressDialog.id
      ? { ...r, progress: [...(r.progress || []), newProgress], status: "in_progress" as MaintenanceStatus }
      : r
    ));
    toast({ title: "Progress ditambahkan", variant: "success" });
    setIsLoading(false);
    setProgressDialog(null);
    reset();
  };

  const statusColors: Record<MaintenanceStatus, string> = {
    pending: "border-l-amber-500",
    in_progress: "border-l-blue-500",
    completed: "border-l-emerald-500",
  };

  const summary = {
    total: reports.length,
    pending: reports.filter(r => r.status === "pending").length,
    in_progress: reports.filter(r => r.status === "in_progress").length,
    completed: reports.filter(r => r.status === "completed").length,
  };

  return (
    <div className="space-y-6">
      <PageHeader title="Keluhan Fasilitas" description="Monitor dan tangani keluhan penghuni" />

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: "Total Keluhan", value: summary.total, color: "text-blue-600" },
          { label: "Pending", value: summary.pending, color: "text-amber-600" },
          { label: "Diproses", value: summary.in_progress, color: "text-blue-600" },
          { label: "Selesai", value: summary.completed, color: "text-emerald-600" },
        ].map((s) => (
          <Card key={s.label}><CardContent className="pt-4 pb-4">
            <p className="text-xs text-muted-foreground">{s.label}</p>
            <p className={`text-xl font-bold mt-1 ${s.color}`}>{s.value}</p>
          </CardContent></Card>
        ))}
      </div>

      <div className="flex gap-3 flex-wrap">
        {(["", "pending", "in_progress", "completed"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "pending" ? "Pending" : s === "in_progress" ? "Diproses" : "Selesai"}
          </button>
        ))}
      </div>

      <div className="space-y-3">
        {filtered.length === 0 && (
          <Card><CardContent className="py-12 text-center text-muted-foreground">
            <Wrench className="w-10 h-10 mx-auto mb-3 opacity-30" />
            <p>Tidak ada keluhan ditemukan</p>
          </CardContent></Card>
        )}
        {filtered.map((report) => {
          const tenant = getTenant(report.tenantId);
          const isExpanded = expanded === report.id;
          return (
            <Card key={report.id} className={`border-l-4 ${statusColors[report.status]}`}>
              <CardContent className="pt-4">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="font-semibold">{report.title}</h3>
                      <MaintenanceStatusBadge status={report.status} />
                    </div>
                    <p className="text-sm text-muted-foreground mt-1">{report.description}</p>
                    <div className="flex items-center gap-4 mt-2 text-xs text-muted-foreground">
                      <span> {tenant?.user.name || "-"}</span>
                      <span> Kamar {tenant?.room.roomNumber || "-"}</span>
                      <span> {timeAgo(report.createdAt)}</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-2 shrink-0">
                    <Select value={report.status} onValueChange={(v) => updateStatus(report.id, v as MaintenanceStatus)}>
                      <SelectTrigger className="w-36 h-8 text-xs"><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="pending">Pending</SelectItem>
                        <SelectItem value="in_progress">Diproses</SelectItem>
                        <SelectItem value="completed">Selesai</SelectItem>
                      </SelectContent>
                    </Select>
                    <Button variant="outline" size="sm" onClick={() => setProgressDialog(report)}>
                      <Plus className="w-3 h-3 mr-1" />Progress
                    </Button>
                    <Button variant="ghost" size="icon" onClick={() => setExpanded(isExpanded ? null : report.id)}>
                      {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                    </Button>
                  </div>
                </div>

                {isExpanded && (
                  <div className="mt-4 pt-4 border-t space-y-3">
                    <p className="text-sm font-medium">Riwayat Progress</p>
                    {(!report.progress || report.progress.length === 0) ? (
                      <p className="text-sm text-muted-foreground">Belum ada progress</p>
                    ) : (
                      report.progress.map((p) => (
                        <div key={p.id} className="flex gap-3 text-sm">
                          <div className="w-2 h-2 rounded-full bg-blue-500 mt-1.5 shrink-0" />
                          <div>
                            <p>{p.description}</p>
                            <p className="text-xs text-muted-foreground">{timeAgo(p.createdAt)}</p>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>

      <Dialog open={!!progressDialog} onOpenChange={() => { setProgressDialog(null); reset(); }}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>Tambah Progress Perbaikan</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit(addProgress)} className="space-y-4">
            <div className="space-y-2">
              <Label>Deskripsi Progress</Label>
              <Input {...register("description")} placeholder="Contoh: Teknisi sudah datang dan memeriksa AC..." />
              {errors.description && <p className="text-red-500 text-xs">{errors.description.message}</p>}
            </div>
            <div className="space-y-2">
              <Label>Foto Dokumentasi (opsional)</Label>
              <div className="border-2 border-dashed rounded-lg p-4 text-center cursor-pointer hover:bg-muted/30">
                <ImageIcon className="w-6 h-6 mx-auto text-muted-foreground mb-1" />
                <p className="text-xs text-muted-foreground">Upload foto</p>
              </div>
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => { setProgressDialog(null); reset(); }}>Batal</Button>
              <Button type="submit" loading={isLoading}>Tambah</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}