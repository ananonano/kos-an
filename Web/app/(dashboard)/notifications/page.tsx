"use client";
import { useState, useEffect } from "react";
import { Bell, CheckCheck, Trash2, CreditCard, Wrench, MessageSquare, UserCheck, FileText, Loader2 } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { cn, timeAgo } from "@/lib/utils";
import { useNotificationStore } from "@/store/notification.store";
import type { Notification, NotificationType } from "@/types";
import api from "@/lib/axios";

const typeIconMap: Record<NotificationType, any> = {
  payment: CreditCard,
  maintenance: Wrench,
  chat: MessageSquare,
  tenant: UserCheck,
  bill: FileText,
};
const typeColors: Record<NotificationType, string> = {
  payment: "bg-[#FFF8F0]",
  maintenance: "bg-amber-100 dark:bg-amber-900/30",
  chat: "bg-[#FFF8F0]",
  tenant: "bg-emerald-100 dark:bg-emerald-900/30",
  bill: "bg-red-100 dark:bg-red-900/30",
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { setNotifications: setStore, markAllAsRead } = useNotificationStore();

  // Fetch notifications from backend
  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      setIsLoading(true);
      console.log('📥 Fetching notifications from backend...');
      
      const response = await api.get('/notifications');
      
      if (response.data.success) {
        const backendNotifs = response.data.data.map((notif: any) => ({
          id: notif.id.toString(),
          type: notif.type as NotificationType,
          title: notif.title,
          message: notif.message,
          isRead: notif.is_read,
          createdAt: notif.created_at,
          relatedId: notif.related_id,
        }));
        
        console.log(`✅ Fetched ${backendNotifs.length} notifications`);
        setNotifications(backendNotifs);
        setStore(backendNotifs);
      }
    } catch (error: any) {
      console.error('❌ Error fetching notifications:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const markRead = async (id: string) => {
    try {
      // Optimistic update
      setNotifications(prev => prev.map(n => n.id === id ? { ...n, isRead: true } : n));
      
      // Call backend API
      await api.put(`/notifications/${id}/read`);
      console.log(`✅ Marked notification ${id} as read`);
      
      // Update store
      const updatedNotifs = notifications.map(n => n.id === id ? { ...n, isRead: true } : n);
      setStore(updatedNotifs);
    } catch (error: any) {
      console.error('❌ Error marking notification as read:', error);
      // Revert optimistic update on error
      fetchNotifications();
    }
  };

  const markAll = async () => {
    try {
      // Optimistic update
      setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
      
      // Call backend API
      await api.put('/notifications/mark-all-read');
      console.log('✅ Marked all notifications as read');
      
      markAllAsRead();
    } catch (error: any) {
      console.error('❌ Error marking all as read:', error);
      // Revert optimistic update on error
      fetchNotifications();
    }
  };

  const deleteNotif = async (id: string) => {
    try {
      // Optimistic update
      setNotifications(prev => prev.filter(n => n.id !== id));
      
      // Call backend API
      await api.delete(`/notifications/${id}`);
      console.log(`✅ Deleted notification ${id}`);
      
      // Update store
      const updatedNotifs = notifications.filter(n => n.id !== id);
      setStore(updatedNotifs);
    } catch (error: any) {
      console.error('❌ Error deleting notification:', error);
      // Revert optimistic update on error
      fetchNotifications();
    }
  };

  const unread = notifications.filter(n => !n.isRead).length;

  return (
    <div className="space-y-6">
      <PageHeader title="Notifikasi" description={`${unread} notifikasi belum dibaca`}
        actions={unread > 0 ? (
          <Button variant="outline" onClick={markAll}>
            <CheckCheck className="w-4 h-4 mr-2" />Tandai Semua Dibaca
          </Button>
        ) : undefined}
      />

      {isLoading && (
        <Card><CardContent className="py-16 text-center">
          <Loader2 className="w-12 h-12 mx-auto text-muted-foreground/30 mb-3 animate-spin" />
          <p className="text-muted-foreground">Memuat notifikasi...</p>
        </CardContent></Card>
      )}

      {!isLoading && notifications.length === 0 && (
        <Card><CardContent className="py-16 text-center">
          <Bell className="w-12 h-12 mx-auto text-muted-foreground/30 mb-3" />
          <p className="text-muted-foreground">Tidak ada notifikasi</p>
        </CardContent></Card>
      )}

      {!isLoading && notifications.length > 0 && (
        <div className="space-y-2">
          {notifications.map((notif) => {
            const IconComponent = typeIconMap[notif.type] || FileText;
            return (
              <Card key={notif.id}
                className={cn("cursor-pointer hover:shadow-sm transition-all", !notif.isRead && "border-l-4 border-l-[#A23900]")}
                onClick={() => markRead(notif.id)}
              >
                <CardContent className="py-4">
                  <div className="flex items-start gap-3">
                    <div className={cn("w-10 h-10 rounded-xl flex items-center justify-center shrink-0", typeColors[notif.type])}>
                      <IconComponent className="w-5 h-5 text-[#A23900]" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <p className={cn("text-sm font-medium", !notif.isRead && "font-semibold")}>{notif.title}</p>
                          <p className="text-sm text-muted-foreground mt-0.5">{notif.message}</p>
                          <p className="text-xs text-muted-foreground mt-1">{timeAgo(notif.createdAt)}</p>
                        </div>
                        <div className="flex items-center gap-1 shrink-0">
                          {!notif.isRead && <div className="w-2 h-2 rounded-full bg-[#A23900]" />}
                          <Button variant="ghost" size="icon" className="h-7 w-7 text-muted-foreground hover:text-red-500"
                            onClick={(e) => { e.stopPropagation(); deleteNotif(notif.id); }}>
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
