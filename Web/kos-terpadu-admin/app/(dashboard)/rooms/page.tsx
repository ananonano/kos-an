"use client";
import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Plus, Pencil, Trash2, BedDouble, ImageIcon } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { DataTable } from "@/components/shared/DataTable";
import { RoomStatusBadge } from "@/components/shared/StatusBadge";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import { FACILITIES_OPTIONS } from "@/lib/constants";
import { toast } from "@/components/ui/toaster";
import type { Room, RoomStatus } from "@/types";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import api from "@/lib/axios";

const schema = z.object({
  roomNumber: z.string().min(1, "Nomor kamar wajib diisi"),
  type: z.string().min(1, "Tipe kamar wajib diisi"),
  price: z.coerce.number().min(1, "Harga wajib diisi"),
  status: z.enum(["available", "occupied", "maintenance"]),
  description: z.string().optional(),
  facilities: z.array(z.string()).min(1, "Pilih minimal 1 fasilitas"),
});
type FormData = z.infer<typeof schema>;

export default function RoomsPage() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<RoomStatus | "">("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editRoom, setEditRoom] = useState<Room | null>(null);
  const [deleteRoom, setDeleteRoom] = useState<Room | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isFetching, setIsFetching] = useState(true);

  // Fetch rooms from backend
  useEffect(() => {
    fetchRooms();
  }, []);

  const fetchRooms = async () => {
    try {
      setIsFetching(true);
      const response = await api.get("/rooms");
      if (response.data.success) {
        setRooms(response.data.data);
      }
    } catch (error: any) {
      console.error("Fetch rooms error:", error);
      toast({
        title: "Gagal memuat data kamar",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsFetching(false);
    }
  };

  const { register, handleSubmit, control, reset, setValue, watch, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { status: "available", facilities: [] },
  });

  const selectedFacilities = watch("facilities") || [];

  const filtered = rooms.filter(r => {
    const matchSearch = r.roomNumber.toLowerCase().includes(search.toLowerCase());
    const matchStatus = statusFilter ? r.status === statusFilter : true;
    return matchSearch && matchStatus;
  });

  const openAdd = () => { setEditRoom(null); reset({ status: "available", facilities: [] }); setDialogOpen(true); };
  const openEdit = (room: Room) => {
    setEditRoom(room);
    reset({ roomNumber: room.roomNumber, type: room.type, price: room.price, status: room.status, description: room.description, facilities: room.facilities });
    setDialogOpen(true);
  };

  const onSubmit = async (data: FormData) => {
    try {
      setIsLoading(true);

      if (editRoom) {
        // Update existing room
        const response = await api.put(`/rooms/${editRoom.id}`, data);
        if (response.data.success) {
          toast({ title: "Kamar berhasil diperbarui", variant: "success" });
          fetchRooms(); // Refresh data
        }
      } else {
        // Create new room
        const response = await api.post("/rooms", data);
        if (response.data.success) {
          toast({ title: "Kamar berhasil ditambahkan", variant: "success" });
          fetchRooms(); // Refresh data
        }
      }

      setDialogOpen(false);
    } catch (error: any) {
      console.error("Submit room error:", error);
      toast({
        title: editRoom ? "Gagal memperbarui kamar" : "Gagal menambahkan kamar",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteRoom) return;
    try {
      setIsLoading(true);
      const response = await api.delete(`/rooms/${deleteRoom.id}`);
      if (response.data.success) {
        toast({ title: "Kamar berhasil dihapus", variant: "destructive" });
        fetchRooms(); // Refresh data
      }
      setDeleteRoom(null);
    } catch (error: any) {
      console.error("Delete room error:", error);
      toast({
        title: "Gagal menghapus kamar",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  const toggleFacility = (f: string) => {
    const current = selectedFacilities;
    setValue("facilities", current.includes(f) ? current.filter(x => x !== f) : [...current, f]);
  };

  const columns = [
    {
      key: "roomNumber", header: "No. Kamar", render: (r: Room) => (
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
            <BedDouble className="w-4 h-4 text-blue-600" />
          </div>
          <span className="font-semibold">Kamar {r.roomNumber}</span>
        </div>
      )
    },
    { key: "price", header: "Harga/Bulan", render: (r: Room) => <span className="font-medium">{formatCurrency(r.price)}</span> },
    { key: "status", header: "Status", render: (r: Room) => <RoomStatusBadge status={r.status} /> },
    {
      key: "facilities", header: "Fasilitas", render: (r: Room) => (
        <div className="flex flex-wrap gap-1 max-w-xs">
          {r.facilities.slice(0, 3).map(f => (
            <span key={f} className="text-xs bg-muted px-2 py-0.5 rounded-full">{f}</span>
          ))}
          {r.facilities.length > 3 && <span className="text-xs text-muted-foreground">+{r.facilities.length - 3}</span>}
        </div>
      )
    },
    {
      key: "actions", header: "Aksi", render: (r: Room) => (
        <div className="flex gap-2">
          <Button variant="ghost" size="icon" onClick={() => openEdit(r)}><Pencil className="w-4 h-4" /></Button>
          <Button variant="ghost" size="icon" className="text-red-500 hover:text-red-600" onClick={() => setDeleteRoom(r)}><Trash2 className="w-4 h-4" /></Button>
        </div>
      )
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Manajemen Kamar" description={`${rooms.length} kamar terdaftar`}
        actions={<Button onClick={openAdd}><Plus className="w-4 h-4 mr-2" />Tambah Kamar</Button>}
      />

      {/* Filter */}
      <div className="flex gap-3 flex-wrap">
        {(["", "available", "occupied", "maintenance"] as const).map((s) => (
          <button key={s} onClick={() => setStatusFilter(s)}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-all ${statusFilter === s ? "bg-primary text-primary-foreground shadow" : "bg-muted hover:bg-muted/80"}`}>
            {s === "" ? "Semua" : s === "available" ? "Tersedia" : s === "occupied" ? "Terisi" : "Perbaikan"}
          </button>
        ))}
      </div>

      <Card>
        <CardContent className="pt-6">
          <DataTable data={filtered} columns={columns} searchable searchPlaceholder="Cari nomor kamar..."
            onSearch={setSearch} emptyMessage="Tidak ada kamar ditemukan" />
        </CardContent>
      </Card>

      {/* Add/Edit Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editRoom ? "Edit Kamar" : "Tambah Kamar Baru"}</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Nomor Kamar</Label>
                <Input {...register("roomNumber")} placeholder="101" />
                {errors.roomNumber && <p className="text-red-500 text-xs">{errors.roomNumber.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Tipe Kamar</Label>
                <Input {...register("type")} placeholder="Standard / Deluxe / VIP" />
                {errors.type && <p className="text-red-500 text-xs">{errors.type.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Harga/Bulan (Rp)</Label>
                <Input {...register("price")} type="number" placeholder="1500000" />
                {errors.price && <p className="text-red-500 text-xs">{errors.price.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Status</Label>
                <Controller name="status" control={control} render={({ field }) => (
                  <Select value={field.value} onValueChange={field.onChange}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="available">Tersedia</SelectItem>
                      <SelectItem value="occupied">Terisi</SelectItem>
                      <SelectItem value="maintenance">Perbaikan</SelectItem>
                    </SelectContent>
                  </Select>
                )} />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Deskripsi</Label>
              <Input {...register("description")} placeholder="Deskripsi kamar..." />
            </div>
            <div className="space-y-2">
              <Label>Fasilitas</Label>
              <div className="flex flex-wrap gap-2 p-3 border rounded-lg max-h-40 overflow-y-auto">
                {FACILITIES_OPTIONS.map(f => (
                  <button key={f} type="button" onClick={() => toggleFacility(f)}
                    className={`px-3 py-1 rounded-full text-xs font-medium transition-all ${selectedFacilities.includes(f) ? "bg-primary text-primary-foreground" : "bg-muted hover:bg-muted/80"}`}>
                    {f}
                  </button>
                ))}
              </div>
              {errors.facilities && <p className="text-red-500 text-xs">{errors.facilities.message}</p>}
            </div>
            <div className="space-y-2">
              <Label>Foto Kamar</Label>
              <div className="border-2 border-dashed rounded-lg p-6 text-center cursor-pointer hover:bg-muted/30 transition-colors">
                <ImageIcon className="w-8 h-8 mx-auto text-muted-foreground mb-2" />
                <p className="text-sm text-muted-foreground">Klik untuk upload foto</p>
                <p className="text-xs text-muted-foreground">PNG, JPG max 5MB</p>
              </div>
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>Batal</Button>
              <Button type="submit" loading={isLoading}>{editRoom ? "Simpan" : "Tambah"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog open={!!deleteRoom} onClose={() => setDeleteRoom(null)} onConfirm={handleDelete}
        title="Hapus Kamar" description={`Yakin ingin menghapus kamar ${deleteRoom?.roomNumber}? Tindakan ini tidak dapat dibatalkan.`}
        confirmLabel="Hapus" isLoading={isLoading} />
    </div>
  );
}