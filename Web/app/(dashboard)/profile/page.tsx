"use client";
import { useState } from "react";
import { Save, Lock } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import { useAuthStore } from "@/store/auth.store";
import { getInitials } from "@/lib/utils";
import { toast } from "@/components/ui/toaster";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { authService } from "@/services/auth.service";

const profileSchema = z.object({
  name: z.string().min(1, "Nama wajib diisi"),
  email: z.string().email("Email tidak valid"),
  phone: z.string().optional(),
});
const passwordSchema = z.object({
  currentPassword: z.string().min(6, "Password minimal 6 karakter"),
  newPassword: z.string().min(6, "Password minimal 6 karakter"),
  confirmPassword: z.string(),
}).refine(d => d.newPassword === d.confirmPassword, { message: "Password tidak cocok", path: ["confirmPassword"] });

type ProfileForm = z.infer<typeof profileSchema>;
type PasswordForm = z.infer<typeof passwordSchema>;

export default function ProfilePage() {
  const { user, updateUser } = useAuthStore();
  const [isLoadingProfile, setIsLoadingProfile] = useState(false);
  const [isLoadingPassword, setIsLoadingPassword] = useState(false);

  const { register: regProfile, handleSubmit: handleProfile, formState: { errors: errProfile } } = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
    defaultValues: { name: user?.name || "", email: user?.email || "", phone: user?.phone || "" },
  });

  const { register: regPass, handleSubmit: handlePass, reset: resetPass, formState: { errors: errPass } } = useForm<PasswordForm>({
    resolver: zodResolver(passwordSchema),
  });

  const onSaveProfile = async (data: ProfileForm) => {
    try {
      setIsLoadingProfile(true);

      // Call backend API with JSON data
      const response = await authService.updateProfile({
        nama: data.name,
        email: data.email,
        no_telepon: data.phone || "",
      });

      // Update local state with response data
      if (response.success && response.data) {
        updateUser({
          name: response.data.nama,
          email: response.data.email,
          phone: response.data.no_telepon,
        });
      }

      toast({ title: "Profil berhasil diperbarui", variant: "success" });
    } catch (error: any) {
      console.error("Update profile error:", error);
      toast({
        title: "Gagal memperbarui profil",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoadingProfile(false);
    }
  };

  const onChangePassword = async (data: PasswordForm) => {
    try {
      setIsLoadingPassword(true);

      // Call backend API
      await authService.changePassword({
        currentPassword: data.currentPassword,
        newPassword: data.newPassword,
      });

      toast({ title: "Password berhasil diubah", variant: "success" });
      resetPass();
    } catch (error: any) {
      console.error("Change password error:", error);
      toast({
        title: "Gagal mengubah password",
        description: error.response?.data?.message || "Password saat ini salah",
        variant: "destructive"
      });
    } finally {
      setIsLoadingPassword(false);
    }
  };

  return (
    <div className="space-y-6 max-w-2xl">
      <PageHeader title="Profil" description="Kelola informasi akun Anda" />

      {/* Avatar */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex items-center gap-6">
            <Avatar className="w-20 h-20">
              <AvatarImage src={user?.avatar} />
              <AvatarFallback className="bg-[#A23900] text-white text-2xl font-bold">
                {user ? getInitials(user.name) : "A"}
              </AvatarFallback>
            </Avatar>
            <div>
              <h3 className="font-semibold text-lg">{user?.name}</h3>
              <p className="text-muted-foreground text-sm">{user?.email}</p>
              <span className="inline-flex items-center mt-1 px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#FFF8F0] text-[#A23900]">
                Admin
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Profile Form */}
      <Card>
        <CardHeader><CardTitle className="text-base">Informasi Pribadi</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={handleProfile(onSaveProfile)} className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Nama Lengkap</Label>
                <Input {...regProfile("name")} />
                {errProfile.name && <p className="text-red-500 text-xs">{errProfile.name.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Email</Label>
                <Input {...regProfile("email")} type="email" />
                {errProfile.email && <p className="text-red-500 text-xs">{errProfile.email.message}</p>}
              </div>
              <div className="space-y-2 sm:col-span-2">
                <Label>No. HP</Label>
                <Input {...regProfile("phone")} placeholder="081234567890" />
              </div>
            </div>
            <div className="flex justify-end">
              <Button type="submit" loading={isLoadingProfile}>
                <Save className="w-4 h-4 mr-2" />Simpan Perubahan
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Password Form */}
      <Card>
        <CardHeader><CardTitle className="text-base flex items-center gap-2"><Lock className="w-4 h-4" />Ganti Password</CardTitle></CardHeader>
        <CardContent>
          <form onSubmit={handlePass(onChangePassword)} className="space-y-4">
            <div className="space-y-2">
              <Label>Password Saat Ini</Label>
              <Input {...regPass("currentPassword")} type="password" placeholder="" />
              {errPass.currentPassword && <p className="text-red-500 text-xs">{errPass.currentPassword.message}</p>}
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Password Baru</Label>
                <Input {...regPass("newPassword")} type="password" placeholder="" />
                {errPass.newPassword && <p className="text-red-500 text-xs">{errPass.newPassword.message}</p>}
              </div>
              <div className="space-y-2">
                <Label>Konfirmasi Password</Label>
                <Input {...regPass("confirmPassword")} type="password" placeholder="" />
                {errPass.confirmPassword && <p className="text-red-500 text-xs">{errPass.confirmPassword.message}</p>}
              </div>
            </div>
            <div className="flex justify-end">
              <Button type="submit" loading={isLoadingPassword}>Ganti Password</Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}