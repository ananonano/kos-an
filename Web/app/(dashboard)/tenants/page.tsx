"use client";
import { useState, useEffect } from "react";
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
import { toast } from "@/components/ui/toaster";
import type { TenantStatus } from "@/types";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import api from "@/lib/axios";

const schema = z.object({
  nama: z.string().min(1, "Nama wajib diisi"),
  email: z.string().email("Email tidak valid"),
  no_telepon: z.string().min(10, "Nomor HP tidak valid"),
  kamar_id: z.string().min(1, "Pilih kamar"),
  tanggal_masuk: z.string().min(1, "Tanggal masuk wajib diisi"),
  tanggal_keluar: z.string().optional(),
  alamat_asal: z.string().optional(),
  pekerjaan: z.string().optional(),
  kontak_darurat: z.string().optional(),
});
type FormData = z.infer<typeof schema>;

export default function TenantsPage() {
  const [tenants, setTenants] = useState<any[]>([]);
  const [rooms, setRooms] = useState<any[]>([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editTenant, setEditTenant] = useState<any | null>(null);
  const [deleteTenant, setDeleteTenant] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  const { register, handleSubmit, control, reset, formState: { errors } } = useForm<FormData>({ resolver: zodResolver(schema) });

  // Fetch tenants and rooms from backend
  useEffect(() => {
    fetchTenants();
    fetchRooms();
  }, []);

  const fetchTenants = async () => {
    try {
      setIsFetching(true);
      const response = await api.get("/tenants");
      if (response.data.success) {
        setTenants(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch tenants error:", error);
      toast({
        title: "Gagal memuat data penghuni",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsFetching(false);
    }
  };

  const fetchRooms = async () => {
    try {
      const response = await api.get("/rooms?status=kosong");
      if (response.data.success) {
        setRooms(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch rooms error:", error);
    }
  };

  const filtered = tenants.filter(t => {
    const matchSearch = t.nama?.toLowerCase().includes(search.toLowerCase()) ||
      t.email?.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter ? t.status === statusFilter : true;
    return matchSearch && matchStatus;
  });

  const openAdd = () => { setEditTenant(null); reset(); setDialogOpen(true); };
  const openEdit = (t: any) => {
    setEditTenant(t);
    reset({
      nama: t.nama,
      email: t.email,
      no_telepon: t.no_telepon || "",
      kamar_id: t.kamar_id?.toString(),
      tanggal_masuk: t.tanggal_masuk?.split('T')[0],
      tanggal_keluar: t.tanggal_keluar?.split('T')[0]
    });
    setDialogOpen(true);
  };

  const onSubmit = async (data: FormData) => {
    try {
      setIsLoading(true);

      if (editTenant) {
        // Update existing tenant
        const response = await api.put(`/tenants/${editTenant.id}`, data);
        if (response.data.success) {
          toast({ title: "Data penghuni berhasil diperbarui", variant: "success" });
          fetchTenants(); // Refresh data
        }
      } else {
        // Create new tenant - first create user account
        try {
          // Create user account first
          const userResponse = await api.post("/auth/register", {
            email: data.email,
            password: "tenant123", // Default password
            nama: data.nama,
            no_telepon: data.no_telepon,
            role: "tenant"
          });

          if (userResponse.data.success) {
            // Then create tenant with user_id
            const tenantData = {
              ...data,
              user_id: userResponse.data.user.id
            };

            const response = await api.post("/tenants", tenantData);
            if (response.data.success) {
              toast({
                title: "Penghuni berhasil ditambahkan",
                description: "Password default: tenant123",
                variant: "success"
              });
              fetchTenants(); // Refresh data
            }
          }
        } catch (userError: any) {
          // If user already exists, try to find user by email
          if (userError.response?.status === 400) {
            toast({
              title: "Email sudah terdaftar",
              description: "Gunakan email lain atau hubungi admin",
              variant: "destructive"
            });
            setIsLoading(false);
            return;
          }
          throw userError;
        }
      }

      setDialogOpen(false);
    } catch (error: any) {
      console.error("Submit tenant error:", error);
      toast({
        title: editTenant ? "Gagal memperbarui penghuni" : "Gagal menambahkan penghuni",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteTenant) return;
    try {
      setIsLoading(true);
      const response = await api.delete(`/tenants/${deleteTenant.id}`);
      if (response.data.success) {
        toast({ title: "Penghuni berhasil dihapus", variant: "destructive" });
        fetchTenants(); // Refresh data
      }
      setDeleteTenant(null);
    } catch (error: any) {
      console.error("Delete tenant error:", error);
      toast({
        title: "Gagal menghapus penghuni",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const columns = [
    {
      key: "user", header: "Penghuni", render: (t: any) => (
        <div className="flex items-center gap-3">
          <Avatar className="w-9 h-9">
            <AvatarFallback className="bg-blue-100 text-blue-700 text-xs font-semibold">{getInitials(t.nama || "")}</AvatarFallback>
          </Avatar>
          <div>
            <p className="font-medium text-sm">{t.nama}</p>
            <p className="text-xs text-muted-foreground">{t.email}</p>
          </div>
        </div>
      )
    },
    { key: "room", header: "Kamar", render: (t: any) => <span className="font-medium">Kamar {t.nomor_kamar || "-"}</span> },
    {
      key: "phone", header: "No. HP", render: (t: any) => (
        <div className="flex items-center gap-1 text-sm text-muted-foreground">
          <Phone className="w-3 h-3" />{t.no_telepon || "-"}
        </div>
      )
    },
    { key: "startDate", header: "Tgl Masuk", render: (t: any) => <span className="text-sm">{t.tanggal_masuk ? formatDate(t.tanggal_masuk) : "-"}</span> },
    { key: "status", header: "Status", render: (t: any) => <TenantStatusBadge status={t.status} /> },
    {
      key: "actions", header: "Aksi", render: (t: any) => (
        <div className="flex gap-2">
          <Button variant="ghost" size="icon" onClick={() => openEdit(t)}><Pencil className="w-4 h-4" /></Button>
          <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-600" onClick={() => setDeleteTenant(t)}><Trash2 className="w-4 h-4" /></Button>
        </div>
      )
    },
  ];

  if (isFetching) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Memuat data penghuni...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Manajemen Penghuni" description={`${tenants.filter(t => t.status === "aktif").length} penghuni aktif`}
        actions={<Button onClick={openAdd}><Plus className="w-4 h-4 mr-2" />Tambah Penghuni</Button>}
      />

      <div className="flex gap-3 flex-wrap">
        {(["", "aktif", "tidak_aktif"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "aktif" ? "Aktif" : "Nonaktif"}
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
                <Input {...register("nama")} placeholder="Budi Santoso" />
                {errors.nama && <p className="text-red-500 text-xs">{errors.nama.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Email</Label>
                <Input {...register("email")} type="email" placeholder="budi@email.com" />
                {errors.email && <p className="text-red-500 text-xs">{errors.email.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>No. HP</Label>
                <Input {...register("no_telepon")} placeholder="081234567890" />
                {errors.no_telepon && <p className="text-red-500 text-xs">{errors.no_telepon.message}</p>}
              </div>
              <div className="space-y-2 col-span-2">
                <Label>Alamat Asal</Label>
                <Input {...register("alamat_asal")} placeholder="Jl. Contoh No. 123, Jakarta" />
              </div>
              <div className="space-y-2">
                <Label>Pekerjaan</Label>
                <Input {...register("pekerjaan")} placeholder="Mahasiswa / Karyawan" />
              </div>
              <div className="space-y-2">
                <Label>Kontak Darurat</Label>
                <Input {...register("kontak_darurat")} placeholder="081234567890" />
              </div>
              <div className="space-y-2 col-span-2">
                <Label>Kamar</Label>
                <Controller name="kamar_id" control={control} render={({ field }) => (
                  <Select value={field.value} onValueChange={field.onChange}>
                    <SelectTrigger><SelectValue placeholder="Pilih kamar" /></SelectTrigger>
                    <SelectContent>
                      {rooms.map(r => (
                        <SelectItem key={r.id} value={r.id.toString()}>Kamar {r.nomor_kamar} - Rp {r.harga.toLocaleString("id-ID")}/bln</SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                )} />
                {errors.kamar_id && <p className="text-red-500 text-xs">{errors.kamar_id.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Tanggal Masuk</Label>
                <Input {...register("tanggal_masuk")} type="date" />
                {errors.tanggal_masuk && <p className="text-red-500 text-xs">{errors.tanggal_masuk.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Tanggal Keluar (opsional)</Label>
                <Input {...register("tanggal_keluar")} type="date" />
                <p className="text-xs text-muted-foreground">Kosongkan jika belum ada rencana keluar</p>
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
        title="Hapus Penghuni" description={`Yakin ingin menghapus data ${deleteTenant?.nama}?`}
        confirmLabel="Hapus" isLoading={isLoading} />
    </div>
  );
}
