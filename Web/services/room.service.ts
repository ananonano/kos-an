import api from "@/lib/axios";
import type { Room, RoomFormData, ApiResponse, PaginatedResponse, RoomFilterParams } from "@/types";

export const roomService = {
  getAll: async (params?: RoomFilterParams) => {
    const res = await api.get<PaginatedResponse<Room>>("/rooms", { params });
    return res.data;
  },
  getById: async (id: string) => {
    const res = await api.get<ApiResponse<Room>>(`/rooms/${id}`);
    return res.data;
  },
  create: async (data: FormData) => {
    const res = await api.post<ApiResponse<Room>>("/rooms", data, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
  },
  update: async (id: string, data: FormData) => {
    const res = await api.put<ApiResponse<Room>>(`/rooms/${id}`, data, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
  },
  delete: async (id: string) => {
    const res = await api.delete<ApiResponse<null>>(`/rooms/${id}`);
    return res.data;
  },
};