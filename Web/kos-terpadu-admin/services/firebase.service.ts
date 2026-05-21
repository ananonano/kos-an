import { db, storage } from "@/lib/firebase";
import {
  collection, addDoc, onSnapshot, query, orderBy,
  where, updateDoc, doc, serverTimestamp, getDocs, limit
} from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import type { ChatMessage, Notification } from "@/types";

//  CHAT 

export const chatService = {
  /** Listen to messages between admin and a tenant */
  listenMessages: (
    adminId: string,
    tenantId: string,
    callback: (messages: ChatMessage[]) => void
  ) => {
    const chatId = [adminId, tenantId].sort().join("_");
    const q = query(
      collection(db, "realtime_chat"),
      where("chatId", "==", chatId),
      orderBy("timestamp", "asc"),
      limit(100)
    );
    return onSnapshot(q, (snap) => {
      const msgs: ChatMessage[] = snap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<ChatMessage, "id">),
        timestamp: d.data().timestamp?.toDate?.()?.toISOString() ?? new Date().toISOString(),
      }));
      callback(msgs);
    });
  },

  /** Send a message */
  sendMessage: async (
    senderId: string,
    receiverId: string,
    message: string,
    imageUrl?: string
  ) => {
    const chatId = [senderId, receiverId].sort().join("_");
    await addDoc(collection(db, "realtime_chat"), {
      chatId,
      senderId,
      receiverId,
      message,
      image: imageUrl || null,
      timestamp: serverTimestamp(),
      read: false,
    });
  },

  /** Mark messages as read */
  markAsRead: async (adminId: string, tenantId: string) => {
    const chatId = [adminId, tenantId].sort().join("_");
    const q = query(
      collection(db, "realtime_chat"),
      where("chatId", "==", chatId),
      where("senderId", "==", tenantId),
      where("read", "==", false)
    );
    const snap = await getDocs(q);
    const updates = snap.docs.map((d) => updateDoc(doc(db, "realtime_chat", d.id), { read: true }));
    await Promise.all(updates);
  },

  /** Upload chat image to Firebase Storage */
  uploadImage: async (file: File, chatId: string): Promise<string> => {
    const storageRef = ref(storage, `chat/${chatId}/${Date.now()}_${file.name}`);
    await uploadBytes(storageRef, file);
    return getDownloadURL(storageRef);
  },
};

//  NOTIFICATIONS 

export const notificationService = {
  /** Listen to admin notifications in realtime */
  listenNotifications: (
    adminId: string,
    callback: (notifications: Notification[]) => void
  ) => {
    const q = query(
      collection(db, "realtime_notifications"),
      where("userId", "==", adminId),
      orderBy("createdAt", "desc"),
      limit(50)
    );
    return onSnapshot(q, (snap) => {
      const notifs: Notification[] = snap.docs.map((d) => ({
        id: d.id,
        ...(d.data() as Omit<Notification, "id">),
        createdAt: d.data().createdAt?.toDate?.()?.toISOString() ?? new Date().toISOString(),
      }));
      callback(notifs);
    });
  },

  /** Send notification to a user */
  sendNotification: async (
    userId: string,
    title: string,
    message: string,
    type: Notification["type"]
  ) => {
    await addDoc(collection(db, "realtime_notifications"), {
      userId,
      title,
      message,
      type,
      isRead: false,
      createdAt: serverTimestamp(),
    });
  },

  /** Mark notification as read */
  markAsRead: async (notificationId: string) => {
    await updateDoc(doc(db, "realtime_notifications", notificationId), { isRead: true });
  },
};

//  ACTIVITY LOG 

export const activityService = {
  log: async (userId: string, activity: string) => {
    await addDoc(collection(db, "activity_logs"), {
      userId,
      activity,
      createdAt: serverTimestamp(),
    });
  },
};

//  STORAGE 

export const storageService = {
  uploadFile: async (file: File, path: string): Promise<string> => {
    const storageRef = ref(storage, `${path}/${Date.now()}_${file.name}`);
    await uploadBytes(storageRef, file);
    return getDownloadURL(storageRef);
  },

  uploadRoomImage: (file: File, roomId: string) =>
    storageService.uploadFile(file, `rooms/${roomId}`),

  uploadPaymentProof: (file: File, paymentId: string) =>
    storageService.uploadFile(file, `payments/${paymentId}`),

  uploadMaintenanceDoc: (file: File, reportId: string) =>
    storageService.uploadFile(file, `maintenance/${reportId}`),

  uploadAvatar: (file: File, userId: string) =>
    storageService.uploadFile(file, `avatars/${userId}`),
};