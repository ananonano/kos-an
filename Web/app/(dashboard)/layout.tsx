"use client";
import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/auth.store";
import { useNotificationStore } from "@/store/notification.store";
import { Sidebar } from "@/components/layout/Sidebar";
import { Navbar } from "@/components/layout/Navbar";
import { useUIStore } from "@/store/ui.store";
import { cn } from "@/lib/utils";
import api from "@/lib/axios";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user, logout } = useAuthStore();
  const { sidebarCollapsed } = useUIStore();
  const { setNotifications } = useNotificationStore();
  const router = useRouter();

  useEffect(() => {
    if (!isAuthenticated) {
      router.push("/login");
      return;
    }
    
    // Block tenant from accessing web dashboard
    if (user?.role !== 'admin') {
      logout();
      router.push("/login");
    }
  }, [isAuthenticated, user, router, logout]);

  // Fetch notifications for unread count
  useEffect(() => {
    if (!isAuthenticated || user?.role !== 'admin') return;

    const fetchNotifications = async () => {
      try {
        console.log('📥 [Layout] Fetching notifications for unread count...');
        const response = await api.get('/notifications');
        
        if (response.data.success) {
          const backendNotifs = response.data.data.map((notif: any) => ({
            id: notif.id.toString(),
            type: notif.type,
            title: notif.title,
            message: notif.message,
            isRead: notif.is_read,
            createdAt: notif.created_at,
            relatedId: notif.related_id,
          }));
          
          setNotifications(backendNotifs);
          console.log(`✅ [Layout] Loaded ${backendNotifs.length} notifications, unread: ${backendNotifs.filter((n: any) => !n.isRead).length}`);
        }
      } catch (error: any) {
        console.error('❌ [Layout] Error fetching notifications:', error);
      }
    };

    fetchNotifications();

    // Refresh notifications every 30 seconds
    const interval = setInterval(fetchNotifications, 30000);
    return () => clearInterval(interval);
  }, [isAuthenticated, user, setNotifications]);

  if (!isAuthenticated || user?.role !== 'admin') return null;

  return (
    <div className="flex h-screen bg-background overflow-hidden">
      <Sidebar />
      <div className={cn(
        "flex-1 flex flex-col overflow-hidden transition-all duration-300",
        sidebarCollapsed ? "ml-0 lg:ml-16" : "ml-0 lg:ml-64"
      )}>
        <Navbar />
        <main className="flex-1 overflow-y-auto p-4 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}