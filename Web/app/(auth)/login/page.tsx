"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { motion } from "framer-motion";
import { Eye, EyeOff, Building2, Lock, Mail } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/hooks/useAuth";
import Link from "next/link";
import { useAuthStore } from "@/store/auth.store";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

const schema = z.object({
  email: z.string().email("Email tidak valid"),
  password: z.string().min(6, "Password minimal 6 karakter"),
});
type FormData = z.infer<typeof schema>;

export default function LoginPage() {
  const [showPassword, setShowPassword] = useState(false);
  const { login, isLoading, error } = useAuth();
  const { isAuthenticated } = useAuthStore();
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated) router.push("/dashboard");
  }, [isAuthenticated, router]);

  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = (data: FormData) => login(data);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className="w-full"
    >
      {/* Card */}
      <div className="bg-white/10 dark:bg-white/5 backdrop-blur-xl border border-white/20 rounded-[17px] p-8 shadow-2xl relative overflow-hidden">
        {/* Subtle accent */}
        <div className="absolute top-0 right-0 w-32 h-32 bg-[#F4B942]/10 rounded-full blur-2xl -mr-16 -mt-16"></div>
        
        {/* Logo */}
        <div className="flex flex-col items-center mb-8 relative z-10">
          <div className="w-14 h-14 rounded-[17px] bg-gradient-to-br from-[#A23900] to-[#8B3500] flex items-center justify-center shadow-lg shadow-[#A23900]/30 mb-4">
            <Building2 className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-white">Selamat Datang</h1>
          <p className="text-slate-400 text-sm mt-1">Login ke akun Anda</p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
          {/* Email */}
          <div className="space-y-2">
            <Label className="text-white text-sm">Email</Label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-white/70" />
              <Input
                {...register("email")}
                type="email"
                placeholder="admin@kosterpadu.com"
                className="pl-10 bg-white/10 border-white/20 text-white placeholder:text-white/50 focus-visible:ring-[#A23900]"
              />
            </div>
            {errors.email && <p className="text-red-400 text-xs">{errors.email.message}</p>}
          </div>

          {/* Password */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label className="text-white text-sm">Password</Label>
              <Link href="/forgot-password" className="text-xs text-[#FFB347] hover:text-[#F4B942] transition-colors">
                Lupa password?
              </Link>
            </div>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-white/70" />
              <Input
                {...register("password")}
                type={showPassword ? "text" : "password"}
                placeholder="••••••••"
                className="pl-10 pr-10 bg-white/10 border-white/20 text-white placeholder:text-white/50 focus-visible:ring-[#A23900]"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-white/70 hover:text-white transition-colors"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {errors.password && <p className="text-red-400 text-xs">{errors.password.message}</p>}
          </div>

          {/* Error */}
          {error && (
            <motion.div
              initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: "auto" }}
              className="bg-red-500/10 border border-red-500/30 rounded-lg px-4 py-3"
            >
              <p className="text-red-400 text-sm">{error}</p>
            </motion.div>
          )}

          {/* Demo hint */}
          <div className="bg-[#A23900]/10 border border-[#A23900]/20 rounded-lg px-4 py-3">
            <p className="text-[#FFB347] text-xs font-medium">Demo credentials:</p>
            <p className="text-[#F4B942] text-xs">admin@kosterpadu.com / admin123</p>
          </div>

          <Button type="submit" className="w-full bg-[#A23900] hover:bg-[#8B3500] text-white h-10" loading={isLoading}>
            {isLoading ? "Masuk..." : "Login"}
          </Button>
        </form>
      </div>

      <p className="text-center text-slate-500 text-xs mt-6">
         2026 KosTerpadu. Sistem Manajemen Kos Terpadu.
      </p>
    </motion.div>
  );
}