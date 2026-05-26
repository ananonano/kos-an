import api from "@/lib/axios";
import type { Payment, Bill, ApiResponse, PaginatedResponse, PaymentFilterParams } from "@/types";

export const paymentService = {
  getAll: async (params?: PaymentFilterParams) => {
    const res = await api.get<PaginatedResponse<Payment>>("/payments", { params });
    return res.data;
  },
  verify: async (id: string) => {
    const res = await api.post<ApiResponse<Payment>>(`/payments/${id}/verify`);
    return res.data;
  },
  reject: async (id: string, reason?: string) => {
    const res = await api.post<ApiResponse<Payment>>(`/payments/${id}/reject`, { reason });
    return res.data;
  },
};

export const billService = {
  getAll: async (params?: { page?: number; limit?: number; status?: string }) => {
    const res = await api.get<PaginatedResponse<Bill>>("/bills", { params });
    return res.data;
  },
  generate: async (data: { month: number; year: number }) => {
    const res = await api.post<ApiResponse<Bill[]>>("/bills/generate", data);
    return res.data;
  },
};