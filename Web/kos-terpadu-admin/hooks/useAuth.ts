"use client";
import { useAuthStore } from "@/store/auth.store";
import { useRouter } from "next/navigation";
import { useState } from "react";
import type { LoginCredentials } from "@/types";

export function useAuth() {
  const { user, token, isAuthenticated, setAuth, logout: storeLogout } = useAuthStore();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const login = async (credentials: LoginCredentials) => {
    setIsLoading(true);
    setError(null);
    try {
      // Demo login - bypass API for development
      if (credentials.email === "admin@kosterpadu.com" && credentials.password === "admin123") {
        const demoUser = {
          id: "admin-1",
          name: "Admin KosTerpadu",
          email: "admin@kosterpadu.com",
          phone: "081234567890",
          role: "admin" as const,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };
        setAuth(demoUser, "demo-token-12345");
        router.push("/dashboard");
        return;
      }
      // Real API call
      const { authService } = await import("@/services/auth.service");
      const res = await authService.login(credentials);
      if (res.success) {
        setAuth(res.data.user, res.data.token);
        router.push("/dashboard");
      }
    } catch (err: any) {
      setError(err.response?.data?.message || "Login gagal. Periksa email dan password.");
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    storeLogout();
    router.push("/login");
  };

  return { user, token, isAuthenticated, isLoading, error, login, logout };
}