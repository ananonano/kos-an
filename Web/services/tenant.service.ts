import api from "@/lib/axios";
import type { Tenant, TenantFormData, ApiResponse, PaginatedResponse, TenantFilterParams } from "@/types";

export const tenantService = {
  getAll: async (params?: TenantFilterParams) => {
    const res = await api.get<PaginatedResponse<Tenant>>("/tenants", { params });
    return res.data;
  },
  getById: async (id: string) => {
    const res = await api.get<ApiResponse<Tenant>>(`/tenants/${id}`);
    return res.data;
  },
  create: async (data: TenantFormData) => {
    const res = await api.post<ApiResponse<Tenant>>("/tenants", data);
    return res.data;
  },
  update: async (id: string, data: Partial<TenantFormData>) => {
    const res = await api.put<ApiResponse<Tenant>>(`/tenants/${id}`, data);
    return res.data;
  },
  delete: async (id: string) => {
    const res = await api.delete<ApiResponse<null>>(`/tenants/${id}`);
    return res.data;
  },
};