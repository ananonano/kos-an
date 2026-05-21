import api from "@/lib/axios";
import type { ApiResponse, DashboardStats, MonthlyIncome, RecentActivity } from "@/types";

export const dashboardService = {
  getStats: async () => {
    const res = await api.get<ApiResponse<DashboardStats>>("/dashboard/stats");
    return res.data;
  },
  getMonthlyIncome: async (year?: number) => {
    const res = await api.get<ApiResponse<MonthlyIncome[]>>("/dashboard/monthly-income", {
      params: { year },
    });
    return res.data;
  },
  getRecentActivity: async () => {
    const res = await api.get<ApiResponse<RecentActivity[]>>("/dashboard/activity");
    return res.data;
  },
};