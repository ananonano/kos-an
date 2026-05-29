import api from "@/lib/axios";
import type { Announcement, AnnouncementFormData, ApiResponse, PaginatedResponse } from "@/types";

export const announcementService = {
  getAll: async (params?: { page?: number; limit?: number }) => {
    const res = await api.get<PaginatedResponse<Announcement>>("/announcements", { params });
    return res.data;
  },
  create: async (data: AnnouncementFormData) => {
    const res = await api.post<ApiResponse<Announcement>>("/announcements", data);
    return res.data;
  },
  update: async (id: string, data: AnnouncementFormData) => {
    const res = await api.put<ApiResponse<Announcement>>(`/announcements/${id}`, data);
    return res.data;
  },
  delete: async (id: string) => {
    const res = await api.delete<ApiResponse<null>>(`/announcements/${id}`);
    return res.data;
  },
};