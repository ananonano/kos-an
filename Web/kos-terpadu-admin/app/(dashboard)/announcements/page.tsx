"use client";
import { useState, useEffect } from "react";
import { Plus, Pencil, Trash2, Megaphone } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { formatDate, timeAgo } from "@/lib/utils";
import { toast } from "@/components/ui/toaster";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import api from "@/lib/axios";
import { useAuthStore } from "@/store/auth.store";

const schema = z.object({
  judul: z.string().min(1, "Judul wajib diisi"),
  konten: z.string().min(10, "Konten minimal 10 karakter"),
  kategori: z.string().min(1, "Kategori wajib diisi"),
  prioritas: z.enum(["info", "penting", "urgent"]).default("info"),
  target: z.enum(["semua", "tenant", "admin"]).default("semua"),
});
type FormData = z.infer<typeof schema>;

export default function AnnouncementsPage() {
  const { user } = useAuthStore();
  const [announcements, setAnnouncements] = useState<any[]>([]);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editItem, setEditItem] = useState<any | null>(null);
  const [deleteItem, setDeleteItem] = useState<any | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  const { register, handleSubmit, control, reset, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      prioritas: "info",
      target: "semua",
      kategori: "Umum"
    }
  });

  // Fetch announcements from backend
  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const fetchAnnouncements = async () => {
    try {
      setIsFetching(true);
      const response = await api.get("/announcements");
      if (response.data.success) {
        setAnnouncements(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch announcements error:", error);
      toast({
        title: "Gagal memuat pengumuman",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsFetching(false);
    }
  };

  const openAdd = () => {
    setEditItem(null);
    reset({
      judul: "",
      konten: "",
      kategori: "Umum",
      prioritas: "info",
      target: "semua"
    });
    setDialogOpen(true);
  };

  const openEdit = (a: any) => {
    setEditItem(a);
    reset({
      judul: a.judul,
      konten: a.konten,
      kategori: a.kategori,
      prioritas: a.prioritas,
      target: a.target
    });
    setDialogOpen(true);
  };

  const onSubmit = async (data: FormData) => {
    try {
      setIsLoading(true);

      if (editItem) {
        // Update existing announcement
        const response = await api.put(`/announcements/${editItem.id}`, data);
        if (response.data.success) {
          toast({ title: "Pengumuman diperbarui", variant: "success" });
          fetchAnnouncements(); // Refresh data
        }
      } else {
        // Create new announcement
        const response = await api.post("/announcements", {
          ...data,
          created_by: user?.id
        });
        if (response.data.success) {
          toast({
            title: "Pengumuman dikirim",
            description: "Notifikasi dikirim ke semua penghuni.",
            variant: "success"
          });
          fetchAnnouncements(); // Refresh data
        }
      }

      setDialogOpen(false);
    } catch (error: any) {
      console.error("Submit announcement error:", error);
      toast({
        title: editItem ? "Gagal memperbarui pengumuman" : "Gagal mengirim pengumuman",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteItem) return;
    try {
      setIsLoading(true);
      const response = await api.delete(`/announcements/${deleteItem.id}`);
      if (response.data.success) {
        toast({ title: "Pengumuman dihapus", variant: "destructive" });
        fetchAnnouncements(); // Refresh data
      }
      setDeleteItem(null);
    } catch (error: any) {
      console.error("Delete announcement error:", error);
      toast({
        title: "Gagal menghapus pengumuman",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  if (isFetching) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Memuat pengumuman...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader title="Pengumuman" description="Buat dan kelola pengumuman untuk penghuni"
        actions={<Button onClick={openAdd}><Plus className="w-4 h-4 mr-2" />Buat Pengumuman</Button>}
      />

      {announcements.length === 0 && (
        <Card><CardContent className="py-16 text-center">
          <Megaphone className="w-12 h-12 mx-auto text-muted-foreground/30 mb-3" />
          <p className="text-muted-foreground">Belum ada pengumuman</p>
          <Button className="mt-4" onClick={openAdd}><Plus className="w-4 h-4 mr-2" />Buat Pengumuman</Button>
        </CardContent></Card>
      )}

      <div className="space-y-4">
        {announcements.map((ann, i) => (
          <Card key={ann.id} className="hover:shadow-md transition-shadow">
            <CardContent className="pt-5">
              <div className="flex items-start justify-between gap-4">
                <div className="flex gap-3 flex-1 min-w-0">
                  <div className="w-10 h-10 rounded-xl bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center shrink-0">
                    <Megaphone className="w-5 h-5 text-blue-600" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="font-semibold text-base">{ann.judul}</h3>
                      {ann.prioritas === "urgent" && (
                        <span className="text-xs bg-red-100 text-red-700 px-2 py-0.5 rounded-full">Urgent</span>
                      )}
                      {ann.prioritas === "penting" && (
                        <span className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">Penting</span>
                      )}
                    </div>
                    <p className="text-sm text-muted-foreground mt-1 line-clamp-2">{ann.konten}</p>
                    <div className="flex items-center gap-3 mt-2 text-xs text-muted-foreground">
                      <span>{timeAgo(ann.created_at)}</span>
                      <span>•</span>
                      <span>{ann.kategori}</span>
                      <span>•</span>
                      <span className="capitalize">{ann.target}</span>
                    </div>
                  </div>
                </div>
                <div className="flex gap-1 shrink-0">
                  <Button variant="ghost" size="icon" onClick={() => openEdit(ann)}><Pencil className="w-4 h-4" /></Button>
                  <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-600" onClick={() => setDeleteItem(ann)}><Trash2 className="w-4 h-4" /></Button>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader><DialogTitle>{editItem ? "Edit Pengumuman" : "Buat Pengumuman Baru"}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="space-y-2">
              <Label>Judul</Label>
              <Input {...register("judul")} placeholder="Judul pengumuman..." />
              {errors.judul && <p className="text-red-500 text-xs">{errors.judul.message}</p>}
            </div>
            <div className="space-y-2">
              <Label>Konten</Label>
              <Textarea {...register("konten")} placeholder="Isi pengumuman..." rows={5} />
              {errors.konten && <p className="text-red-500 text-xs">{errors.konten.message}</p>}
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Kategori</Label>
                <Input {...register("kategori")} placeholder="Umum, Pembayaran, dll" />
                {errors.kategori && <p className="text-red-500 text-xs">{errors.kategori.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Prioritas</Label>
                <Controller name="prioritas" control={control} render={({ field }) => (
                  <Select value={field.value} onValueChange={field.onChange}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="info">Info</SelectItem>
                      <SelectItem value="penting">Penting</SelectItem>
                      <SelectItem value="urgent">Urgent</SelectItem>
                    </SelectContent>
                  </Select>
                )} />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Target</Label>
              <Controller name="target" control={control} render={({ field }) => (
                <Select value={field.value} onValueChange={field.onChange}>
                  <SelectTrigger><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="semua">Semua</SelectItem>
                    <SelectItem value="tenant">Tenant Saja</SelectItem>
                    <SelectItem value="admin">Admin Saja</SelectItem>
                  </SelectContent>
                </Select>
              )} />
            </div>
            {!editItem && (
              <div className="bg-blue-50 dark:bg-blue-950/30 rounded-lg p-3 text-xs text-blue-700 dark:text-blue-300">
                Notifikasi akan dikirim ke semua penghuni melalui aplikasi mobile.
              </div>
            )}
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>Batal</Button>
              <Button type="submit" loading={isLoading}>{editItem ? "Simpan" : "Kirim"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog open={!!deleteItem} onClose={() => setDeleteItem(null)} onConfirm={handleDelete}
        title="Hapus Pengumuman" description={`Yakin ingin menghapus pengumuman "${deleteItem?.judul}"?`}
        confirmLabel="Hapus" isLoading={isLoading} />
    </div>
  );
}