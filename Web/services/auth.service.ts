import api from "@/lib/axios";
import type { LoginCredentials, ApiResponse, User } from "@/types";

// Backend returns token and user directly, not wrapped in data
interface LoginResponse {
  success: boolean;
  token: string;
  user: User;
  message?: string;
}

export const authService = {
  login: async (credentials: LoginCredentials): Promise<LoginResponse> => {
    const res = await api.post<LoginResponse>("/auth/login", credentials);
    return res.data;
  },
  logout: async () => {
    const res = await api.post("/auth/logout");
    return res.data;
  },
  forgotPassword: async (email: string) => {
    const res = await api.post("/auth/forgot-password", { email });
    return res.data;
  },
  resetPassword: async (token: string, password: string) => {
    const res = await api.post("/auth/reset-password", { token, password });
    return res.data;
  },
  getProfile: async () => {
    const res = await api.get("/auth/profile");
    return res.data;
  },
  updateProfile: async (data: { nama: string; email?: string; no_telepon?: string; foto?: string }) => {
    const res = await api.put("/auth/profile", data);
    return res.data;
  },
  changePassword: async (data: { currentPassword: string; newPassword: string }) => {
    const res = await api.put("/auth/change-password", data);
    return res.data;
  },
};