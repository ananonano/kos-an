"use client";
import { useState } from "react";
import { Plus, Pencil, Trash2, User, Phone, Mail } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { DataTable } from "@/components/shared/DataTable";
import { TenantStatusBadge } from "@/components/shared/StatusBadge";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { formatDate, getInitials } from "@/lib/utils";
import { seedTenants, seedRooms } from "@/utils/seed-data";
import { toast } from "@/components/ui/toaster";
import type { Tenant, TenantStatus } from "@/types";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z.object({
  name: z.string().min(1, "Nama wajib diisi"),
  email: z.string().email("Email tidak valid"),
  phone: z.string().min(10, "Nomor HP tidak valid"),
  roomId: z.string().min(1, "Pilih kamar"),
  startDate: z.string().min(1, "Tanggal masuk wajib diisi"),
  endDate: z.string().optional(),
});
type FormData = z.infer<typeof schema>;

export default function TenantsPage() {
  const [tenants, setTenants] = useState<Tenant[]>(seedTenants);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<TenantStatus | "">("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editTenant, setEditTenant] = useState<Tenant | null>(null);
  const [deleteTenant, setDeleteTenant] = useState<Tenant | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, control, reset, formState: { errors } } = useForm<FormData>({ resolver: zodResolver(schema) });

  const filtered = tenants.filter(t => {
    const matchSearch = t.user.name.toLowerCase().includes(search.toLowerCase()) ||
      t.user.email.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter ? t.status === statusFilter : true;
    return matchSearch && matchStatus;
  });

  const openAdd = () => { setEditTenant(null); reset(); setDialogOpen(true); };
  const openEdit = (t: Tenant) => {
    setEditTenant(t);
    reset({ name: t.user.name, email: t.user.email, phone: t.user.phone || "", roomId: t.roomId, startDate: t.startDate, endDate: t.endDate });
    setDialogOpen(true);
  };

  const onSubmit = async (data: FormData) => {
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 800));
    const room = seedRooms.find(r => r.id === data.roomId) || seedRooms[0];
    if (editTenant) {
      setTenants(prev => prev.map(t => t.id === editTenant.id ? {
        ...t, roomId: data.roomId, startDate: data.startDate, endDate: data.endDate,
        user: { ...t.user, name: data.name, email: data.email, phone: data.phone }, room
      } : t));
      toast({ title: "Data penghuni diperbarui", variant: "success" });
    } else {
      const newTenant: Tenant = {
        id: Date.now().toString(), userId: Date.now().toString(), roomId: data.roomId,
        startDate: data.startDate, endDate: data.endDate, status: "active",
        user: { id: Date.now().toString(), name: data.name, email: data.email, phone: data.phone, role: "tenant", createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
        room, createdAt: new Date().toISOString()
      };
      setTenants(prev => [...prev, newTenant]);
      toast({ title: "Penghuni ditambahkan", variant: "success" });
    }
    setIsLoading(false);
    setDialogOpen(false);
  };

  const handleDelete = async () => {
    if (!deleteTenant) return;
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 500));
    setTenants(prev => prev.filter(t => t.id !== deleteTenant.id));
    toast({ title: "Penghuni dihapus", variant: "destructive" });
    setIsLoading(false);
    setDeleteTenant(null);
  };

  const columns = [
    { key: "user", header: "Penghuni", render: (t: Tenant) => (
      <div className="flex items-center gap-3">
        <Avatar className="w-9 h-9">
          <AvatarFallback className="bg-blue-100 text-blue-700 text-xs font-semibold">{getInitials(t.user.name)}</AvatarFallback>
        </Avatar>
        <div>
          <p className="font-medium text-sm">{t.user.name}</p>
          <p className="text-xs text-muted-foreground">{t.user.email}</p>
        </div>
      </div>
    )},
    { key: "room", header: "Kamar", render: (t: Tenant) => <span className="font-medium">Kamar {t.room.roomNumber}</span> },
    { key: "phone", header: "No. HP", render: (t: Tenant) => (
      <div className="flex items-center gap-1 text-sm text-muted-foreground">
        <Phone className="w-3 h-3" />{t.user.phone || "-"}
      </div>
    )},
    { key: "startDate", header: "Tgl Masuk", render: (t: Tenant) => <span className="text-sm">{formatDate(t.startDate)}</span> },
    { key: "status", header: "Status", render: (t: Tenant) => <TenantStatusBadge status={t.status} /> },
    { key: "actions", header: "Aksi", render: (t: Tenant) => (
      <div className="flex gap-2">
        <Button variant="ghost" size="icon" onClick={() => openEdit(t)}><Pencil className="w-4 h-4" /></Button>
        <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-600" onClick={() => setDeleteTenant(t)}><Trash2 className="w-4 h-4" /></Button>
      </div>
    )},
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Manajemen Penghuni" description={`${tenants.filter(t => t.status === "active").length} penghuni aktif`}
        actions={<Button onClick={openAdd}><Plus className="w-4 h-4 mr-2" />Tambah Penghuni</Button>}
      />

      <div className="flex gap-3 flex-wrap">
        {(["", "active", "inactive"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "active" ? "Aktif" : "Nonaktif"}
          </button>
        ))}
      </div>

      <Card><CardContent className="pt-6">
        <DataTable data={filtered} columns={columns} searchable searchPlaceholder="Cari nama atau email..."
          onSearch={setSearch} emptyMessage="Tidak ada penghuni ditemukan" />
      </CardContent></Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader><DialogTitle>{editTenant ? "Edit Penghuni" : "Tambah Penghuni Baru"}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2 col-span-2">
                <Label>Nama Lengkap</Label>
                <Input {...register("name")} placeholder="Budi Santoso" />
                {errors.name && <p className="text-red-500 text-xs">{errors.name.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Email</Label>
                <Input {...register("email")} type="email" placeholder="budi@email.com" />
                {errors.email && <p className="text-red-500 text-xs">{errors.email.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>No. HP</Label>
                <Input {...register("phone")} placeholder="081234567890" />
                {errors.phone && <p className="text-red-500 text-xs">{errors.phone.message}</p>}
              </div>
              <div className="space-y-2 col-span-2">
                <Label>Kamar</Label>
                <Controller name="roomId" control={control} render={({ field }) => (
                  <Select value={field.value} onValueChange={field.onChange}>
                    <SelectTrigger><SelectValue placeholder="Pilih kamar" /></SelectTrigger>
                    <SelectContent>
                      {seedRooms.filter(r => r.status === "available").map(r => (
                        <SelectItem key={r.id} value={r.id}>Kamar {r.roomNumber}  {r.price.toLocaleString("id-ID")}/bln</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                )} />
                {errors.roomId && <p className="text-red-500 text-xs">{errors.roomId.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Tanggal Masuk</Label>
                <Input {...register("startDate")} type="date" />
                {errors.startDate && <p className="text-red-500 text-xs">{errors.startDate.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Tanggal Keluar (opsional)</Label>
                <Input {...register("endDate")} type="date" />
              </div>
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>Batal</Button>
              <Button type="submit" loading={isLoading}>{editTenant ? "Simpan" : "Tambah"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog open={!!deleteTenant} onClose={() => setDeleteTenant(null)} onConfirm={handleDelete}
        title="Hapus Penghuni" description={`Yakin ingin menghapus data ${deleteTenant?.user.name}?`}
        confirmLabel="Hapus" isLoading={isLoading} />
    </div>
  );
}