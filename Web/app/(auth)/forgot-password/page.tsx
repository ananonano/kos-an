"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { motion } from "framer-motion";
import { Mail, Building2, ArrowLeft, CheckCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { authService } from "@/services/auth.service";
import Link from "next/link";

const schema = z.object({ email: z.string().email("Email tidak valid") });
type FormData = z.infer<typeof schema>;

export default function ForgotPasswordPage() {
  const [sent, setSent] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    setIsLoading(true);
    try {
      await authService.forgotPassword(data.email);
      setSent(true);
    } catch {} finally { setIsLoading(false); }
  };

  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.5 }}>
      <div className="bg-white/10 backdrop-blur-xl border border-white/20 rounded-2xl p-8 shadow-2xl">
        <div className="flex flex-col items-center mb-8">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center shadow-lg mb-4">
            <Building2 className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-white">Lupa Password</h1>
          <p className="text-slate-400 text-sm mt-1 text-center">Masukkan email Anda untuk reset password</p>
        </div>

        {sent ? (
          <div className="text-center space-y-4">
            <div className="w-16 h-16 rounded-full bg-emerald-500/20 flex items-center justify-center mx-auto">
              <CheckCircle className="w-8 h-8 text-emerald-400" />
            </div>
            <p className="text-white font-medium">Email terkirim!</p>
            <p className="text-slate-400 text-sm">Cek inbox email Anda untuk link reset password.</p>
          </div>
        ) : (
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
            <div className="space-y-2">
              <Label className="text-slate-300 text-sm">Email</Label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                <Input {...register("email")} type="email" placeholder="admin@kosterpadu.com"
                  className="pl-10 bg-white/10 border-white/20 text-white placeholder:text-slate-500" />
              </div>
              {errors.email && <p className="text-red-400 text-xs">{errors.email.message}</p>}
            </div>
            <Button type="submit" className="w-full bg-[#A23900] hover:bg-[#8B3500] text-white" loading={isLoading}>
              Kirim Link Reset
            </Button>
          </form>
        )}

        <div className="mt-6 text-center">
          <Link href="/login" className="text-blue-400 hover:text-blue-300 text-sm flex items-center justify-center gap-1">
            <ArrowLeft className="w-4 h-4" /> Kembali ke Login
          </Link>
        </div>
      </div>
    </motion.div>
  );
}