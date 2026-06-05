"use client";
import { useState, useRef, useEffect } from "react";
import { Send, ImageIcon, Search, AlertCircle } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { cn, getInitials, timeAgo } from "@/lib/utils";
import { useAuthStore } from "@/store/auth.store";
import { db } from "@/lib/firebase";
import { 
  collection, 
  query, 
  where, 
  orderBy, 
  onSnapshot, 
  addDoc, 
  updateDoc,
  doc,
  serverTimestamp,
  Timestamp,
  type DocumentData
} from "firebase/firestore";

interface ChatRoom {
  id: string;
  admin_id: string;
  penghuni_id: string;
  admin_name?: string;
  penghuni_name?: string;
  last_message?: string;
  last_message_time?: Timestamp | null;
  unread_count?: number;
  createdAt?: Timestamp;
  updatedAt?: Timestamp;
}

interface ChatMessageFS {
  id: string;
  chat_room_id: string;
  sender_id: string;
  message: string;
  image_url?: string;
  sender_name?: string;
  sender_role?: string;
  createdAt?: Timestamp | null;
  updatedAt?: Timestamp;
}

export default function ChatPage() {
  const { user } = useAuthStore();
  const [chatRooms, setChatRooms] = useState<ChatRoom[]>([]);
  const [selectedRoom, setSelectedRoom] = useState<ChatRoom | null>(null);
  const [messages, setMessages] = useState<ChatMessageFS[]>([]);
  const [input, setInput] = useState("");
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Stream chat rooms for admin
  useEffect(() => {
    if (!user) {
      setLoading(false);
      return;
    }
    
    try {
      console.log("🔍 [ChatPage] Current user:", user);
      console.log("🔍 [ChatPage] Querying chat rooms for admin_id:", user.id.toString());
      
      const chatRoomsRef = collection(db, "chats");
      
      // DEBUG: Query all chats first to see structure
      const debugQuery = query(chatRoomsRef);
      const debugUnsubscribe = onSnapshot(debugQuery, (snapshot) => {
        console.log("🐛 [DEBUG] All chats in Firestore:", snapshot.docs.length);
        snapshot.docs.forEach(doc => {
          console.log("🐛 [DEBUG] Chat doc:", doc.id, doc.data());
        });
      });
      
      // Actual query with filter
      const q = query(
        chatRoomsRef,
        where("admin_id", "==", user.id.toString())
      );
      
      const unsubscribe = onSnapshot(q, (snapshot) => {
        console.log("📦 [ChatPage] Filtered snapshot, docs count:", snapshot.docs.length);
        
        const rooms: ChatRoom[] = snapshot.docs
          .map(doc => {
            const data = doc.data();
            console.log("[ChatPage] Chat room doc:", doc.id, data);
            return {
              id: doc.id,
              ...data as Omit<ChatRoom, 'id'>
            };
          })
          .sort((a, b) => {
            const timeA = a.updatedAt?.toMillis() || 0;
            const timeB = b.updatedAt?.toMillis() || 0;
            return timeB - timeA;
          });
        
        console.log("✅ [ChatPage] Processed rooms:", rooms);
        setChatRooms(rooms);
        setLoading(false);
        setError(null);
        
        if (!selectedRoom && rooms.length > 0) {
          setSelectedRoom(rooms[0]);
        }
      }, (error) => {
        console.error("❌ [ChatPage] Error fetching chat rooms:", error);
        setError("Gagal memuat chat. " + error.message);
        setLoading(false);
      });

      return () => {
        unsubscribe();
        debugUnsubscribe();
      };
    } catch (err: any) {
      console.error("❌ [ChatPage] Exception in useEffect:", err);
      setError("Terjadi kesalahan: " + err.message);
      setLoading(false);
    }
  }, [user]);

  // Stream messages for selected room
  useEffect(() => {
    if (!selectedRoom) return;
    
    try {
      const messagesRef = collection(db, "chats", selectedRoom.id, "messages");
      const q = query(messagesRef, orderBy("createdAt", "asc"));
      
      const unsubscribe = onSnapshot(q, (snapshot) => {
        const msgs: ChatMessageFS[] = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data() as Omit<ChatMessageFS, 'id'>
        }));
        setMessages(msgs);
      }, (error) => {
        console.error("Error fetching messages:", error);
      });

      return () => unsubscribe();
    } catch (err) {
      console.error("Exception fetching messages:", err);
    }
  }, [selectedRoom]);

  // Auto scroll to bottom when messages change
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const filteredRooms = chatRooms.filter(room =>
    (room.penghuni_name || "").toLowerCase().includes(search.toLowerCase())
  );

  const sendMessage = async () => {
    if (!input.trim() || !selectedRoom || !user) return;
    
    try {
      const messagesRef = collection(db, "chats", selectedRoom.id, "messages");
      
      await addDoc(messagesRef, {
        chat_room_id: selectedRoom.id,
        sender_id: user.id.toString(),
        message: input.trim(),
        image_url: null,
        sender_name: user.nama || "Admin",
        sender_role: "admin",
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      
      const roomRef = doc(db, "chats", selectedRoom.id);
      await updateDoc(roomRef, {
        last_message: input.trim(),
        last_message_time: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      
      setInput("");
    } catch (error) {
      console.error("Error sending message:", error);
      alert("Gagal mengirim pesan. Coba lagi.");
    }
  };

  const formatTimestamp = (timestamp?: Timestamp | null) => {
    if (!timestamp) return "";
    return timeAgo(timestamp.toDate().toISOString());
  };

  return (
    <div className="space-y-4">
      <PageHeader title="Chat" description="Komunikasi realtime dengan penghuni" />

      {error ? (
        <div className="flex items-center justify-center h-[calc(100vh-220px)]">
          <div className="text-center max-w-md">
            <AlertCircle className="w-16 h-16 text-red-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold mb-2">Terjadi Kesalahan</h3>
            <p className="text-muted-foreground mb-4">{error}</p>
            <Button onClick={() => window.location.reload()}>Muat Ulang</Button>
          </div>
        </div>
      ) : loading ? (
        <div className="flex items-center justify-center h-[calc(100vh-220px)]">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <p className="text-muted-foreground">Memuat chat...</p>
          </div>
        </div>
      ) : chatRooms.length === 0 ? (
        <div className="flex items-center justify-center h-[calc(100vh-220px)]">
          <div className="text-center">
            <p className="text-muted-foreground">Belum ada chat dengan penghuni</p>
          </div>
        </div>
      ) : (
        <div className="flex h-[calc(100vh-220px)] min-h-[500px] border rounded-xl overflow-hidden bg-background">
          {/* Sidebar */}
          <div className="w-72 border-r flex flex-col shrink-0">
            <div className="p-3 border-b">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                <Input placeholder="Cari penghuni..." value={search} onChange={e => setSearch(e.target.value)} className="pl-9 h-8 text-sm" />
              </div>
            </div>
            <div className="flex-1 overflow-y-auto">
              {filteredRooms.map(room => {
                const isSelected = selectedRoom?.id === room.id;
                return (
                  <button key={room.id} onClick={() => setSelectedRoom(room)}
                    className={cn("w-full flex items-center gap-3 p-3 hover:bg-muted/50 transition-colors text-left", isSelected && "bg-muted")}>
                    <div className="relative">
                      <Avatar className="w-10 h-10">
                        <AvatarFallback className="bg-[#FFF8F0] text-[#A23900] text-xs font-semibold">{getInitials(room.penghuni_name || "?")}</AvatarFallback>
                      </Avatar>
                      <div className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 rounded-full border-2 border-background" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <p className="text-sm font-medium truncate">{room.penghuni_name || "Penghuni"}</p>
                        {room.last_message_time && <p className="text-xs text-muted-foreground shrink-0">{formatTimestamp(room.last_message_time)}</p>}
                      </div>
                      <div className="flex items-center justify-between">
                        <p className="text-xs text-muted-foreground truncate">{room.last_message || "Belum ada pesan"}</p>
                        {(room.unread_count || 0) > 0 && (
                          <span className="w-5 h-5 bg-[#A23900] text-white text-[10px] font-bold rounded-full flex items-center justify-center shrink-0">
                            {room.unread_count}
                          </span>
                        )}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Chat Area */}
          <div className="flex-1 flex flex-col">
            {selectedRoom ? (
              <>
                {/* Header */}
                <div className="h-14 border-b flex items-center px-4 gap-3">
                  <Avatar className="w-8 h-8">
                    <AvatarFallback className="bg-[#FFF8F0] text-[#A23900] text-xs">{getInitials(selectedRoom.penghuni_name || "?")}</AvatarFallback>
                  </Avatar>
                  <div>
                    <p className="font-medium text-sm">{selectedRoom.penghuni_name || "Penghuni"}</p>
                    <p className="text-xs text-emerald-500">Online</p>
                  </div>
                </div>

                {/* Messages */}
                <div className="flex-1 overflow-y-auto p-4 space-y-3">
                  {messages.length === 0 && (
                    <div className="flex items-center justify-center h-full text-muted-foreground text-sm">
                      Belum ada pesan. Mulai percakapan!
                    </div>
                  )}
                  {messages.map(msg => {
                    const isAdmin = msg.sender_role === "admin";
                    return (
                      <div key={msg.id} className={cn("flex", isAdmin ? "justify-end" : "justify-start")}>
                        <div className={cn(
                          "max-w-[70%] rounded-2xl px-4 py-2.5 text-sm",
                          isAdmin ? "bg-[#A23900] text-white rounded-br-sm" : "bg-muted rounded-bl-sm"
                        )}>
                          <p>{msg.message}</p>
                          <p className={cn("text-[10px] mt-1", isAdmin ? "text-blue-200" : "text-muted-foreground")}>
                            {formatTimestamp(msg.createdAt)}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                  <div ref={messagesEndRef} />
                </div>

                {/* Input */}
                <div className="p-3 border-t flex gap-2">
                  <Button variant="ghost" size="icon" className="shrink-0"><ImageIcon className="w-5 h-5" /></Button>
                  <Input
                    placeholder="Ketik pesan..."
                    value={input}
                    onChange={e => setInput(e.target.value)}
                    onKeyDown={e => e.key === "Enter" && !e.shiftKey && (e.preventDefault(), sendMessage())}
                    className="flex-1"
                  />
                  <Button onClick={sendMessage} disabled={!input.trim()} size="icon" className="shrink-0">
                    <Send className="w-4 h-4" />
                  </Button>
                </div>
              </>
            ) : (
              <div className="flex-1 flex items-center justify-center text-muted-foreground">
                Pilih chat untuk memulai percakapan
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}