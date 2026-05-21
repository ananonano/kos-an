"use client";
import { useEffect, useState, useCallback } from "react";
import { chatService } from "@/services/firebase.service";
import { useAuthStore } from "@/store/auth.store";
import type { ChatMessage } from "@/types";

export function useFirebaseChat(tenantId: string) {
  const { user } = useAuthStore();
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!user || !tenantId) return;
    setIsLoading(true);
    const unsubscribe = chatService.listenMessages(user.id, tenantId, (msgs) => {
      setMessages(msgs);
      setIsLoading(false);
      // Mark as read
      chatService.markAsRead(user.id, tenantId).catch(() => {});
    });
    return () => unsubscribe();
  }, [user, tenantId]);

  const sendMessage = useCallback(async (message: string, imageUrl?: string) => {
    if (!user || !message.trim()) return;
    await chatService.sendMessage(user.id, tenantId, message, imageUrl);
  }, [user, tenantId]);

  const sendImage = useCallback(async (file: File) => {
    if (!user) return;
    const chatId = [user.id, tenantId].sort().join("_");
    const imageUrl = await chatService.uploadImage(file, chatId);
    await chatService.sendMessage(user.id, tenantId, "", imageUrl);
  }, [user, tenantId]);

  return { messages, isLoading, sendMessage, sendImage };
}