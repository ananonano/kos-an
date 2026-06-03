"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import {
  LayoutDashboard, BedDouble, Users, CreditCard, FileText,
  Wrench, MessageSquare, Bell, Megaphone, Settings, User,
  ChevronLeft, ChevronRight, Building2, X
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useUIStore } from "@/store/ui.store";
import { useAuthStore } from "@/store/auth.store";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { getInitials } from "@/lib/utils";

const navItems = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/rooms", label: "Kamar", icon: BedDouble },
  { href: "/tenants", label: "Penghuni", icon: Users },
  { href: "/payments", label: "Pembayaran", icon: CreditCard },
  { href: "/bills", label: "Tagihan", icon: FileText },
  { href: "/maintenance", label: "Keluhan", icon: Wrench },
  { href: "/chat", label: "Chat", icon: MessageSquare },
  { href: "/announcements", label: "Pengumuman", icon: Megaphone },
  { href: "/notifications", label: "Notifikasi", icon: Bell },
];

const bottomItems = [
  { href: "/profile", label: "Profil", icon: User },
  { href: "/settings", label: "Pengaturan", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const { sidebarOpen, sidebarCollapsed, toggleCollapse, setSidebarOpen } = useUIStore();
  const { user } = useAuthStore();

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + "/");

  return (
    <>
      {/* Mobile overlay */}
      <AnimatePresence>
        {sidebarOpen && (
          <motion.div
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/50 lg:hidden"
            onClick={() => setSidebarOpen(false)}
          />
        )}
      </AnimatePresence>

      {/* Sidebar */}
      <motion.aside
        initial={false}
        animate={{ width: sidebarCollapsed ? 64 : 256 }}
        transition={{ duration: 0.3, ease: "easeInOut" }}
        className={cn(
          "fixed left-0 top-0 z-50 h-full bg-[#7A2E00] dark:bg-[#5A2200] flex flex-col border-r border-[#8B3500] overflow-hidden",
          "lg:translate-x-0 transition-transform duration-300",
          sidebarOpen ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
        )}
      >
        {/* Logo */}
        <div className="flex items-center justify-between h-16 px-4 border-b border-[#8B3500] shrink-0">
          <AnimatePresence mode="wait">
            {!sidebarCollapsed && (
              <motion.div
                initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}
                className="flex items-center gap-2"
              >
                <div className="w-8 h-8 rounded-lg bg-[#A23900] flex items-center justify-center shrink-0">
                  <Building2 className="w-4 h-4 text-white" />
                </div>
                <div>
                  <p className="text-white font-bold text-sm leading-none">KosTerpadu</p>
                  <p className="text-orange-200 text-xs">Admin Panel</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
          {sidebarCollapsed && (
            <div className="w-8 h-8 rounded-lg bg-[#A23900] flex items-center justify-center mx-auto">
              <Building2 className="w-4 h-4 text-white" />
            </div>
          )}
          <button
            onClick={() => { toggleCollapse(); setSidebarOpen(false); }}
            className="hidden lg:flex items-center justify-center w-6 h-6 rounded-md text-orange-200 hover:text-white hover:bg-[#8B3500] transition-colors"
          >
            {sidebarCollapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </button>
          <button onClick={() => setSidebarOpen(false)} className="lg:hidden text-orange-200 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Nav */}
        <nav className="flex-1 overflow-y-auto py-4 px-2 space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);
            return (
              <Link key={item.href} href={item.href} onClick={() => setSidebarOpen(false)}>
                <motion.div
                  whileHover={{ x: 2 }}
                  className={cn(
                    "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 group",
                    active
                      ? "bg-[#A23900] text-white shadow-lg shadow-[#A23900]/20"
                      : "text-orange-200 hover:text-white hover:bg-[#8B3500]"
                  )}
                >
                  <Icon className={cn("w-5 h-5 shrink-0", active ? "text-white" : "text-orange-200 group-hover:text-white")} />
                  <AnimatePresence mode="wait">
                    {!sidebarCollapsed && (
                      <motion.span
                        initial={{ opacity: 0, width: 0 }} animate={{ opacity: 1, width: "auto" }}
                        exit={{ opacity: 0, width: 0 }} transition={{ duration: 0.2 }}
                        className="whitespace-nowrap overflow-hidden"
                      >
                        {item.label}
                      </motion.span>
                    )}
                  </AnimatePresence>
                </motion.div>
              </Link>
            );
          })}

          <div className="my-2 border-t border-[#8B3500]" />

          {bottomItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);
            return (
              <Link key={item.href} href={item.href} onClick={() => setSidebarOpen(false)}>
                <motion.div
                  whileHover={{ x: 2 }}
                  className={cn(
                    "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-200 group",
                    active ? "bg-[#A23900] text-white" : "text-orange-200 hover:text-white hover:bg-[#8B3500]"
                  )}
                >
                  <Icon className="w-5 h-5 shrink-0" />
                  {!sidebarCollapsed && <span className="whitespace-nowrap">{item.label}</span>}
                </motion.div>
              </Link>
            );
          })}
        </nav>

        {/* User */}
        {!sidebarCollapsed && user && (
          <div className="p-4 border-t border-[#8B3500]">
            <div className="flex items-center gap-3">
              <Avatar className="w-8 h-8 shrink-0">
                <AvatarImage src={user.avatar} />
                <AvatarFallback className="bg-[#A23900] text-white text-xs">{getInitials(user.name)}</AvatarFallback>
              </Avatar>
              <div className="flex-1 min-w-0">
                <p className="text-white text-sm font-medium truncate">{user.name}</p>
                <p className="text-orange-200 text-xs truncate">{user.email}</p>
              </div>
            </div>
          </div>
        )}
      </motion.aside>
    </>
  );
}