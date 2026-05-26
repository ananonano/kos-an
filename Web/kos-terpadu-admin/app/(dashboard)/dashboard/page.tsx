"use client";
import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Users, BedDouble, DoorOpen, DoorClosed, TrendingUp, AlertCircle, Clock, Wrench } from "lucide-react";
import { StatsCard } from "@/components/shared/StatsCard";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatCurrency, formatDate, timeAgo } from "@/lib/utils";
import { seedMonthlyIncome, seedActivities } from "@/utils/seed-data";
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar } from "recharts";
import { useAuthStore } from "@/store/auth.store";
import api from "@/lib/axios";
import { toast } from "@/components/ui/toaster";

const activityIcons: Record<string, string> = {
  payment: "💰", maintenance: "🔧", tenant: "👤", announcement: "📢", bill: "📄",
};

export default function DashboardPage() {
  const { user } = useAuthStore();
  const [stats, setStats] = useState<any>(null);
  const [pendingPayments, setPendingPayments] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const monthlyIncome = seedMonthlyIncome;
  const activities = seedActivities;

  // Fetch dashboard data from backend
  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setIsLoading(true);

      // Fetch overview statistics
      const overviewRes = await api.get("/dashboard/admin");
      if (overviewRes.data.success) {
        const data = overviewRes.data.data;

        // Transform backend data to match frontend structure
        setStats({
          totalTenants: data.tenants?.aktif || 0,
          totalRooms: data.rooms?.total || 0,
          occupiedRooms: data.rooms?.terisi || 0,
          availableRooms: data.rooms?.kosong || 0,
          totalIncome: data.payments?.total_amount || 0,
          unpaidBills: data.bills?.total_belum_lunas || 0,
          pendingPayments: data.payments?.total_pending || 0,
          pendingMaintenance: data.maintenance?.baru || 0,
        });
      }

      // Fetch pending payments
      const paymentsRes = await api.get("/payments?status=menunggu_verifikasi&limit=5");
      if (paymentsRes.data.success) {
        setPendingPayments(paymentsRes.data.data);
      }
    } catch (error: any) {
      console.error("Fetch dashboard error:", error);
      toast({
        title: "Gagal memuat data dashboard",
        description: error.response?.data?.message || "Terjadi kesalahan",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading || !stats) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Memuat data dashboard...</p>
        </div>
      </div>
    );
  }

  const statsCards = [
    { title: "Total Penghuni", value: stats.totalTenants, subtitle: "Penghuni aktif", icon: Users, color: "blue" as const, trend: { value: 8, label: "bulan ini" } },
    { title: "Total Kamar", value: stats.totalRooms, subtitle: `${stats.occupiedRooms} terisi, ${stats.availableRooms} kosong`, icon: BedDouble, color: "indigo" as const },
    { title: "Kamar Tersedia", value: stats.availableRooms, subtitle: "Siap dihuni", icon: DoorOpen, color: "emerald" as const },
    { title: "Total Pemasukan", value: formatCurrency(stats.totalIncome), subtitle: "Bulan ini", icon: TrendingUp, color: "purple" as const, trend: { value: 12, label: "vs bulan lalu" } },
    { title: "Tagihan Belum Bayar", value: stats.unpaidBills, subtitle: "Perlu tindakan", icon: AlertCircle, color: "amber" as const },
    { title: "Pembayaran Pending", value: stats.pendingPayments, subtitle: "Menunggu verifikasi", icon: Clock, color: "red" as const },
    { title: "Keluhan Pending", value: stats.pendingMaintenance, subtitle: "Perlu ditangani", icon: Wrench, color: "amber" as const },
    { title: "Kamar Terisi", value: stats.occupiedRooms, subtitle: `${Math.round((stats.occupiedRooms / stats.totalRooms) * 100)}% occupancy rate`, icon: DoorClosed, color: "blue" as const },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title={`Selamat datang, ${user?.name?.split(" ")[0] || "Admin"} `}
        description="Berikut ringkasan aktivitas kos Anda hari ini."
      />

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statsCards.map((card, i) => (
          <StatsCard key={card.title} {...card} index={i} />
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Area Chart */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }} className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>Pemasukan Bulanan</CardTitle>
              <CardDescription>Grafik pemasukan 12 bulan terakhir</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={260}>
                <AreaChart data={monthlyIncome}>
                  <defs>
                    <linearGradient id="incomeGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#3b82f6" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                  <XAxis dataKey="month" tick={{ fontSize: 12 }} className="text-muted-foreground" />
                  <YAxis tickFormatter={(v) => `${(v / 1000000).toFixed(0)}jt`} tick={{ fontSize: 12 }} />
                  <Tooltip formatter={(v: number) => [formatCurrency(v), "Pemasukan"]} />
                  <Area type="monotone" dataKey="income" stroke="#3b82f6" strokeWidth={2} fill="url(#incomeGrad)" />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </motion.div>

        {/* Occupancy Donut */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}>
          <Card className="h-full">
            <CardHeader>
              <CardTitle>Status Kamar</CardTitle>
              <CardDescription>Distribusi kamar saat ini</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {[
                { label: "Terisi", value: stats.occupiedRooms, total: stats.totalRooms, color: "bg-blue-500" },
                { label: "Tersedia", value: stats.availableRooms, total: stats.totalRooms, color: "bg-emerald-500" },
                { label: "Perbaikan", value: stats.totalRooms - stats.occupiedRooms - stats.availableRooms, total: stats.totalRooms, color: "bg-amber-500" },
              ].map((item) => (
                <div key={item.label} className="space-y-1.5">
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">{item.label}</span>
                    <span className="font-semibold">{item.value} kamar</span>
                  </div>
                  <div className="h-2 bg-muted rounded-full overflow-hidden">
                    <div className={`h-full ${item.color} rounded-full transition-all duration-700`}
                      style={{ width: `${(item.value / item.total) * 100}%` }} />
                  </div>
                </div>
              ))}
              <div className="pt-2 border-t">
                <p className="text-center text-2xl font-bold text-blue-600">
                  {Math.round((stats.occupiedRooms / stats.totalRooms) * 100)}%
                </p>
                <p className="text-center text-xs text-muted-foreground">Occupancy Rate</p>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      {/* Bottom Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Activity */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}>
          <Card>
            <CardHeader>
              <CardTitle>Aktivitas Terbaru</CardTitle>
              <CardDescription>Log aktivitas sistem</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {activities.map((act) => (
                <div key={act.id} className="flex items-start gap-3 p-3 rounded-lg hover:bg-muted/50 transition-colors">
                  <span className="text-xl shrink-0">{activityIcons[act.type] || ""}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate">{act.description}</p>
                    <p className="text-xs text-muted-foreground">{timeAgo(act.createdAt)}</p>
                  </div>
                </div>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* Pending Payments */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.6 }}>
          <Card>
            <CardHeader>
              <CardTitle>Pembayaran Pending</CardTitle>
              <CardDescription>Menunggu verifikasi admin</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {pendingPayments.length === 0 ? (
                <div className="text-center py-8 text-muted-foreground">
                  <p className="text-sm">Tidak ada pembayaran pending</p>
                </div>
              ) : (
                pendingPayments.map((pay) => (
                  <div key={pay.id} className="flex items-center justify-between p-3 rounded-lg border hover:bg-muted/30 transition-colors">
                    <div>
                      <p className="text-sm font-medium">Pembayaran #{pay.id}</p>
                      <p className="text-xs text-muted-foreground">{formatDate(pay.tanggal_bayar || pay.created_at)}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold">{formatCurrency(pay.jumlah)}</p>
                      <span className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">Pending</span>
                    </div>
                  </div>
                ))
              )}
            </CardContent>
          </Card>
        </motion.div>
      </div>
    </div>
  );
}