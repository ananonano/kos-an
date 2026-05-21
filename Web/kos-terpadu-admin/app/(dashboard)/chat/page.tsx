"use client";
import { useState, useRef, useEffect } from "react";
import { Send, ImageIcon, Search } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { cn, getInitials, timeAgo } from "@/lib/utils";
import { seedTenants } from "@/utils/seed-data";
import { useAuthStore } from "@/store/auth.store";
import type { ChatMessage, User } from "@/types";

const dummyMessages: Record<string, ChatMessage[]> = {
  "1": [
    { id: "m1", senderId: "u1", receiverId: "admin", message: "Pak, AC kamar saya tidak dingin sudah 2 hari.", timestamp: "2026-05-14T09:00:00", read: true, image: undefined },
    { id: "m2", senderId: "admin", receiverId: "u1", message: "Baik, nanti saya kirim teknisi hari ini ya.", timestamp: "2026-05-14T09:05:00", read: true, image: undefined },
    { id: "m3", senderId: "u1", receiverId: "admin", message: "Terima kasih pak!", timestamp: "2026-05-14T09:06:00", read: true, image: undefined },
  ],
  "2": [
    { id: "m4", senderId: "u2", receiverId: "admin", message: "Pak, kapan tagihan bulan ini bisa dibayar?", timestamp: "2026-05-15T10:00:00", read: false, image: undefined },
  ],
  "3": [
    { id: "m5", senderId: "u3", receiverId: "admin", message: "Selamat pagi pak, ada yang ingin saya tanyakan.", timestamp: "2026-05-16T08:00:00", read: false, image: undefined },
  ],
};

export default function ChatPage() {
  const { user } = useAuthStore();
  const [selectedTenant, setSelectedTenant] = useState(seedTenants[0]);
  const [messages, setMessages] = useState<Record<string, ChatMessage[]>>(dummyMessages);
  const [input, setInput] = useState("");
  const [search, setSearch] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const activeTenants = seedTenants.filter(t => t.status === "active");
  const filteredTenants = activeTenants.filter(t =>
    t.user.name.toLowerCase().includes(search.toLowerCase())
  );

  const currentMessages = messages[selectedTenant?.id] || [];

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [currentMessages]);

  const sendMessage = () => {
    if (!input.trim() || !selectedTenant) return;
    const newMsg: ChatMessage = {
      id: Date.now().toString(),
      senderId: "admin",
      receiverId: selectedTenant.userId,
      message: input.trim(),
      timestamp: new Date().toISOString(),
      read: false,
    };
    setMessages(prev => ({
      ...prev,
      [selectedTenant.id]: [...(prev[selectedTenant.id] || []), newMsg],
    }));
    setInput("");
  };

  const getUnread = (tenantId: string) =>
    (messages[tenantId] || []).filter(m => m.senderId !== "admin" && !m.read).length;

  const getLastMessage = (tenantId: string) => {
    const msgs = messages[tenantId] || [];
    return msgs[msgs.length - 1];
  };

  return (
    <div className="space-y-4">
      <PageHeader title="Chat" description="Komunikasi realtime dengan penghuni" />

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
            {filteredTenants.map(tenant => {
              const lastMsg = getLastMessage(tenant.id);
              const unread = getUnread(tenant.id);
              const isSelected = selectedTenant?.id === tenant.id;
              return (
                <button key={tenant.id} onClick={() => setSelectedTenant(tenant)}
                  className={cn("w-full flex items-center gap-3 p-3 hover:bg-muted/50 transition-colors text-left", isSelected && "bg-muted")}>
                  <div className="relative">
                    <Avatar className="w-10 h-10">
                      <AvatarFallback className="bg-blue-100 text-blue-700 text-xs font-semibold">{getInitials(tenant.user.name)}</AvatarFallback>
                    </Avatar>
                    <div className="absolute bottom-0 right-0 w-3 h-3 bg-emerald-500 rounded-full border-2 border-background" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium truncate">{tenant.user.name}</p>
                      {lastMsg && <p className="text-xs text-muted-foreground shrink-0">{timeAgo(lastMsg.timestamp)}</p>}
                    </div>
                    <div className="flex items-center justify-between">
                      <p className="text-xs text-muted-foreground truncate">{lastMsg?.message || "Belum ada pesan"}</p>
                      {unread > 0 && (
                        <span className="w-5 h-5 bg-blue-600 text-white text-[10px] font-bold rounded-full flex items-center justify-center shrink-0">
                          {unread}
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
          {/* Header */}
          <div className="h-14 border-b flex items-center px-4 gap-3">
            <Avatar className="w-8 h-8">
              <AvatarFallback className="bg-blue-100 text-blue-700 text-xs">{getInitials(selectedTenant?.user.name || "")}</AvatarFallback>
            </Avatar>
            <div>
              <p className="font-medium text-sm">{selectedTenant?.user.name}</p>
              <p className="text-xs text-emerald-500">Online</p>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto p-4 space-y-3">
            {currentMessages.length === 0 && (
              <div className="flex items-center justify-center h-full text-muted-foreground text-sm">
                Belum ada pesan. Mulai percakapan!
              </div>
            )}
            {currentMessages.map(msg => {
              const isAdmin = msg.senderId === "admin";
              return (
                <div key={msg.id} className={cn("flex", isAdmin ? "justify-end" : "justify-start")}>
                  <div className={cn(
                    "max-w-[70%] rounded-2xl px-4 py-2.5 text-sm",
                    isAdmin ? "bg-blue-600 text-white rounded-br-sm" : "bg-muted rounded-bl-sm"
                  )}>
                    <p>{msg.message}</p>
                    <p className={cn("text-[10px] mt-1", isAdmin ? "text-blue-200" : "text-muted-foreground")}>
                      {timeAgo(msg.timestamp)}
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
              onKeyDown={e => e.key === "Enter" && sendMessage()}
              className="flex-1"
            />
            <Button onClick={sendMessage} disabled={!input.trim()} size="icon" className="shrink-0">
              <Send className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}