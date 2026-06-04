"use client";
import { useEffect } from "react";
import { notificationService } from "@/services/firebase.service";
import { useAuthStore } from "@/store/auth.store";
import { useNotificationStore } from "@/store/notification.store";

export function useFirebaseNotifications() {
  const { user } = useAuthStore();
  const { setNotifications } = useNotificationStore();

  useEffect(() => {
    if (!user) return;
    const unsubscribe = notificationService.listenNotifications(String(user.id), (notifs) => {
      setNotifications(notifs);
    });
    return () => unsubscribe();
  }, [user, setNotifications]);
}