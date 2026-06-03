"use client";
import { motion } from "framer-motion";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface StatsCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: LucideIcon;
  trend?: { value: number; label: string };
  color?: "blue" | "emerald" | "amber" | "red" | "purple" | "indigo" | "orange";
  index?: number;
}

const colorMap = {
  blue:    { bg: "bg-blue-50 dark:bg-blue-950/30",    icon: "bg-blue-100 dark:bg-blue-900/50 text-blue-600 dark:text-blue-400",    badge: "text-blue-600" },
  emerald: { bg: "bg-emerald-50 dark:bg-emerald-950/30", icon: "bg-emerald-100 dark:bg-emerald-900/50 text-emerald-600 dark:text-emerald-400", badge: "text-emerald-600" },
  amber:   { bg: "bg-[#FFF8F0]", icon: "bg-[#FFB347] text-white", badge: "text-amber-600" },
  red:     { bg: "bg-red-50 dark:bg-red-950/30",      icon: "bg-red-100 dark:bg-red-900/50 text-red-600 dark:text-red-400",          badge: "text-red-600" },
  purple:  { bg: "bg-purple-50 dark:bg-purple-950/30",icon: "bg-purple-100 dark:bg-purple-900/50 text-purple-600 dark:text-purple-400",badge: "text-purple-600" },
  indigo:  { bg: "bg-indigo-50 dark:bg-indigo-950/30",icon: "bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-400",badge: "text-indigo-600" },
  orange:  { bg: "bg-[#FFF8F0]", icon: "bg-[#A23900] text-white", badge: "text-[#A23900]" },
};

export function StatsCard({ title, value, subtitle, icon: Icon, trend, color = "blue", index = 0 }: StatsCardProps) {
  const colors = colorMap[color];
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05, duration: 0.4 }}
      className={cn("rounded-[17px] border border-[#E8DED2] p-5 shadow-sm hover:shadow-md transition-shadow", colors.bg)}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          <p className="text-2xl font-bold mt-1 tracking-tight">{value}</p>
          {subtitle && <p className="text-xs text-muted-foreground mt-1">{subtitle}</p>}
          {trend && (
            <p className={cn("text-xs font-medium mt-2", trend.value >= 0 ? "text-emerald-600" : "text-red-500")}>
              {trend.value >= 0 ? "" : ""} {Math.abs(trend.value)}% {trend.label}
            </p>
          )}
        </div>
        <div className={cn("w-11 h-11 rounded-[11px] flex items-center justify-center shrink-0", colors.icon)}>
          <Icon className="w-5 h-5" />
        </div>
      </div>
    </motion.div>
  );
}