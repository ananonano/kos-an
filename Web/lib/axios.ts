import axios from "axios";

// Hardcode backend URL for production
const BACKEND_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 
                    process.env.NEXT_PUBLIC_API_URL || 
                    "https://kosan-backend-670153358279.asia-southeast2.run.app/api";

const api = axios.create({
  baseURL: BACKEND_URL,
  headers: { "Content-Type": "application/json" },
  timeout: 15000,
});

api.interceptors.request.use(
  (config) => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("kos_token");
      if (token) config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      if (typeof window !== "undefined") {
        localStorage.removeItem("kos_token");
        localStorage.removeItem("kos_user");
        window.location.href = "/login";
      }
    }
    return Promise.reject(error);
  }
);

export default api;