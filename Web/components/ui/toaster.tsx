"use client";
import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

interface Toast {
  id: string;
  title: string;
  description?: string;
  variant?: "default" | "destructive" | "success";
}

let toastListeners: ((toast: Toast) => void)[] = [];

export function toast(t: Omit<Toast, "id">) {
  const id = Math.random().toString(36).slice(2);
  toastListeners.forEach((l) => l({ ...t, id }));
}

export function Toaster() {
  const [toasts, setToasts] = useState<Toast[]>([]);

  useEffect(() => {
    const listener = (t: Toast) => {
      setToasts((prev) => [...prev, t]);
      setTimeout(() => setToasts((prev) => prev.filter((x) => x.id !== t.id)), 4000);
    };
    toastListeners.push(listener);
    return () => { toastListeners = toastListeners.filter((l) => l !== listener); };
  }, []);

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2 max-w-sm w-full">
      {toasts.map((t) => (
        <div key={t.id} className={cn(
          "rounded-xl border p-4 shadow-lg backdrop-blur-sm animate-fade-in",
          t.variant === "destructive" && "bg-red-50 border-red-200 dark:bg-red-950 dark:border-red-800",
          t.variant === "success" && "bg-emerald-50 border-emerald-200 dark:bg-emerald-950 dark:border-emerald-800",
          (!t.variant || t.variant === "default") && "bg-white border-border dark:bg-card"
        )}>
          <p className="font-semibold text-sm">{t.title}</p>
          {t.description && <p className="text-xs text-muted-foreground mt-1">{t.description}</p>}
        </div>
      ))}
    </div>
  );
}