import api from "@/lib/axios";
import type { MaintenanceReport, MaintenanceProgress, ApiResponse, PaginatedResponse } from "@/types";

export const maintenanceService = {
  getAll: async (params?: { page?: number; limit?: number; status?: string }) => {
    const res = await api.get<PaginatedResponse<MaintenanceReport>>("/maintenance", { params });
    return res.data;
  },
  getById: async (id: string) => {
    const res = await api.get<ApiResponse<MaintenanceReport>>(`/maintenance/${id}`);
    return res.data;
  },
  updateStatus: async (id: string, status: string) => {
    const res = await api.put<ApiResponse<MaintenanceReport>>(`/maintenance/${id}`, { status });
    return res.data;
  },
  addProgress: async (id: string, data: FormData) => {
    const res = await api.post<ApiResponse<MaintenanceProgress>>(`/maintenance/${id}/progress`, data, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
  },
};