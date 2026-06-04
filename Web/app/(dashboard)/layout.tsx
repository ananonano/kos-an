"use client";
import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/auth.store";
import { Sidebar } from "@/components/layout/Sidebar";
import { Navbar } from "@/components/layout/Navbar";
import { useUIStore } from "@/store/ui.store";
import { cn } from "@/lib/utils";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user, logout } = useAuthStore();
  const { sidebarCollapsed } = useUIStore();
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