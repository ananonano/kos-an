"use client";
import { useState } from "react";
import { Plus, Pencil, Trash2, Megaphone } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent } from "@/components/ui/card";
import { formatDate, timeAgo } from "@/lib/utils";
import { seedAnnouncements } from "@/utils/seed-data";
import { toast } from "@/components/ui/toaster";
import type { Announcement } from "@/types";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z.object({
  title: z.string().min(1, "Judul wajib diisi"),
  content: z.string().min(10, "Konten minimal 10 karakter"),
});
type FormData = z.infer<typeof schema>;

export default function AnnouncementsPage() {
  const [announcements, setAnnouncements] = useState<Announcement[]>(seedAnnouncements);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editItem, setEditItem] = useState<Announcement | null>(null);
  const [deleteItem, setDeleteItem] = useState<Announcement | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, reset, formState: { errors } } = useForm<FormData>({ resolver: zodResolver(schema) });

  const openAdd = () => { setEditItem(null); reset(); setDialogOpen(true); };
  const openEdit = (a: Announcement) => { setEditItem(a); reset({ title: a.title, content: a.content }); setDialogOpen(true); };

  const onSubmit = async (data: FormData) => {
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 700));
    if (editItem) {
      setAnnouncements(prev => prev.map(a => a.id === editItem.id ? { ...a, ...data, updatedAt: new Date().toISOString() } : a));
      toast({ title: "Pengumuman diperbarui", variant: "success" });
    } else {
      const newAnn: Announcement = { id: Date.now().toString(), ...data, createdAt: new Date().toISOString() };
      setAnnouncements(prev => [newAnn, ...prev]);
      toast({ title: "Pengumuman dikirim", description: "Notifikasi dikirim ke semua penghuni.", variant: "success" });
    }
    setIsLoading(false);
    setDialogOpen(false);
  };

  const handleDelete = async () => {
    if (!deleteItem) return;
    setIsLoading(true);
    await new Promise(r => setTimeout(r, 500));
    setAnnouncements(prev => prev.filter(a => a.id !== deleteItem.id));
    toast({ title: "Pengumuman dihapus", variant: "destructive" });
    setIsLoading(false);
    setDeleteItem(null);
  };

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
                    <h3 className="font-semibold text-base">{ann.title}</h3>
                    <p className="text-sm text-muted-foreground mt-1 line-clamp-2">{ann.content}</p>
                    <p className="text-xs text-muted-foreground mt-2">{timeAgo(ann.createdAt)}</p>
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
              <Input {...register("title")} placeholder="Judul pengumuman..." />
              {errors.title && <p className="text-red-500 text-xs">{errors.title.message}</p>}
            </div>
            <div className="space-y-2">
              <Label>Konten</Label>
              <Textarea {...register("content")} placeholder="Isi pengumuman..." rows={5} />
              {errors.content && <p className="text-red-500 text-xs">{errors.content.message}</p>}
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
        title="Hapus Pengumuman" description={`Yakin ingin menghapus pengumuman "${deleteItem?.title}"?`}
        confirmLabel="Hapus" isLoading={isLoading} />
    </div>
  );
}