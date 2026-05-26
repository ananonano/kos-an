"use client";
import { useState } from "react";
import { ChevronLeft, ChevronRight, Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";

interface Column<T> {
  key: string;
  header: string;
  render?: (row: T) => React.ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  isLoading?: boolean;
  searchable?: boolean;
  searchPlaceholder?: string;
  onSearch?: (value: string) => void;
  pagination?: { page: number; totalPages: number; onPageChange: (p: number) => void };
  actions?: React.ReactNode;
  emptyMessage?: string;
}

export function DataTable<T extends { id: string }>({
  data, columns, isLoading, searchable, searchPlaceholder = "Cari...",
  onSearch, pagination, actions, emptyMessage = "Tidak ada data"
}: DataTableProps<T>) {
  const [search, setSearch] = useState("");

  const handleSearch = (v: string) => {
    setSearch(v);
    onSearch?.(v);
  };

  return (
    <div className="space-y-4">
      {(searchable || actions) && (
        <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center justify-between">
          {searchable && (
            <div className="relative w-full sm:w-72">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder={searchPlaceholder}
                value={search}
                onChange={(e) => handleSearch(e.target.value)}
                className="pl-9"
              />
            </div>
          )}
          {actions && <div className="flex gap-2 shrink-0">{actions}</div>}
        </div>
      )}

      <div className="rounded-xl border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-muted/50">
                {columns.map((col) => (
                  <th key={col.key} className={cn("px-4 py-3 text-left font-semibold text-muted-foreground whitespace-nowrap", col.className)}>
                    {col.header}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i} className="border-b">
                    {columns.map((col) => (
                      <td key={col.key} className="px-4 py-3">
                        <Skeleton className="h-4 w-full" />
                      </td>
                    ))}
                  </tr>
                ))
              ) : data.length === 0 ? (
                <tr>
                  <td colSpan={columns.length} className="px-4 py-12 text-center text-muted-foreground">
                    <div className="flex flex-col items-center gap-2">
                      <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center">
                        <Search className="w-5 h-5 text-muted-foreground" />
                      </div>
                      <p>{emptyMessage}</p>
                    </div>
                  </td>
                </tr>
              ) : (
                data.map((row, i) => (
                  <tr key={row.id} className={cn("border-b transition-colors hover:bg-muted/30", i % 2 === 0 ? "" : "bg-muted/10")}>
                    {columns.map((col) => (
                      <td key={col.key} className={cn("px-4 py-3", col.className)}>
                        {col.render ? col.render(row) : String((row as any)[col.key] ?? "-")}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {pagination && pagination.totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-muted-foreground">
            Halaman {pagination.page} dari {pagination.totalPages}
          </p>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={() => pagination.onPageChange(pagination.page - 1)} disabled={pagination.page <= 1}>
              <ChevronLeft className="w-4 h-4" />
            </Button>
            <Button variant="outline" size="sm" onClick={() => pagination.onPageChange(pagination.page + 1)} disabled={pagination.page >= pagination.totalPages}>
              <ChevronRight className="w-4 h-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}