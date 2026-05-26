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
      // Real API call
      const { authService } = await import("@/services/auth.service");
      const res = await authService.login(credentials);
      if (res.success && res.token && res.user) {
        // Backend returns { success, token, user } directly
        setAuth(res.user, res.token);
        router.push("/dashboard");
      } else {
        setError("Login gagal. Response tidak valid.");
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