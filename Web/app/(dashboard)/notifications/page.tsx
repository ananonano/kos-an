"use client";
import { useState, useEffect } from "react";
import { Bell, CheckCheck, Trash2, CreditCard, Wrench, MessageSquare, UserCheck, FileText } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { cn, timeAgo } from "@/lib/utils";
import { seedNotifications } from "@/utils/seed-data";
import { useNotificationStore } from "@/store/notification.store";
import type { Notification, NotificationType } from "@/types";

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
  const [notifications, setNotifications] = useState<Notification[]>(seedNotifications);
  const { setNotifications: setStore, markAllAsRead } = useNotificationStore();

  useEffect(() => { setStore(notifications); }, []);

  const markRead = (id: string) => {
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, isRead: true } : n));
  };

  const markAll = () => {
    setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
    markAllAsRead();
  };

  const deleteNotif = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
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

      {notifications.length === 0 && (
        <Card><CardContent className="py-16 text-center">
          <Bell className="w-12 h-12 mx-auto text-muted-foreground/30 mb-3" />
          <p className="text-muted-foreground">Tidak ada notifikasi</p>
        </CardContent></Card>
      )}

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
    </div>
  );
}
