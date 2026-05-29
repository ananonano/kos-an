"use client";
import { useTheme } from "next-themes";
import { Moon, Sun, Monitor, Bell, Shield, Database } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import { useState } from "react";
import { cn } from "@/lib/utils";

export default function SettingsPage() {
  const { theme, setTheme } = useTheme();
  const [notifSettings, setNotifSettings] = useState({
    payment: true, maintenance: true, chat: true, bill: true, tenant: false,
  });

  const themes = [
    { value: "light", label: "Terang", icon: Sun },
    { value: "dark", label: "Gelap", icon: Moon },
    { value: "system", label: "Sistem", icon: Monitor },
  ];

  return (
    <div className="space-y-6 max-w-2xl">
      <PageHeader title="Pengaturan" description="Konfigurasi preferensi aplikasi" />

      {/* Theme */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Tampilan</CardTitle>
          <CardDescription>Pilih tema tampilan aplikasi</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-3 gap-3">
            {themes.map(({ value, label, icon: Icon }) => (
              <button key={value} onClick={() => setTheme(value)}
                className={cn(
                  "flex flex-col items-center gap-2 p-4 rounded-xl border-2 transition-all",
                  theme === value ? "border-primary bg-primary/5" : "border-border hover:border-muted-foreground/30"
                )}>
                <Icon className={cn("w-5 h-5", theme === value ? "text-primary" : "text-muted-foreground")} />
                <span className={cn("text-sm font-medium", theme === value ? "text-primary" : "text-muted-foreground")}>{label}</span>
              </button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Notifications */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2"><Bell className="w-4 h-4" />Notifikasi</CardTitle>
          <CardDescription>Atur notifikasi yang ingin Anda terima</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {[
            { key: "payment", label: "Pembayaran Baru", desc: "Notifikasi saat penghuni mengirim bukti bayar" },
            { key: "maintenance", label: "Keluhan Baru", desc: "Notifikasi saat ada keluhan fasilitas masuk" },
            { key: "chat", label: "Pesan Baru", desc: "Notifikasi saat ada pesan dari penghuni" },
            { key: "bill", label: "Tagihan Jatuh Tempo", desc: "Pengingat tagihan yang akan jatuh tempo" },
            { key: "tenant", label: "Penghuni Baru", desc: "Notifikasi saat ada penghuni baru terdaftar" },
          ].map(({ key, label, desc }) => (
            <div key={key}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium">{label}</p>
                  <p className="text-xs text-muted-foreground">{desc}</p>
                </div>
                <Switch
                  checked={notifSettings[key as keyof typeof notifSettings]}
                  onCheckedChange={(v) => setNotifSettings(prev => ({ ...prev, [key]: v }))}
                />
              </div>
              <Separator className="mt-4" />
            </div>
          ))}
        </CardContent>
      </Card>

      {/* System Info */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2"><Database className="w-4 h-4" />Informasi Sistem</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          {[
            { label: "Versi Aplikasi", value: "1.0.0" },
            { label: "Database", value: "PostgreSQL + Firebase" },
            { label: "Framework", value: "Next.js 15 App Router" },
            { label: "Environment", value: "Development" },
          ].map(({ label, value }) => (
            <div key={label} className="flex justify-between text-sm">
              <span className="text-muted-foreground">{label}</span>
              <span className="font-medium">{value}</span>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}