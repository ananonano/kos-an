import { Badge } from "@/components/ui/badge";
import { ROOM_STATUS, PAYMENT_STATUS, BILL_STATUS, MAINTENANCE_STATUS, TENANT_STATUS } from "@/lib/constants";
import type { RoomStatus, PaymentStatus, BillStatus, MaintenanceStatus, TenantStatus } from "@/types";

export function RoomStatusBadge({ status }: { status: RoomStatus }) {
  const s = ROOM_STATUS[status];
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${s.color}`}>{s.label}</span>;
}

export function PaymentStatusBadge({ status }: { status: PaymentStatus }) {
  const s = PAYMENT_STATUS[status];
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${s.color}`}>{s.label}</span>;
}

export function BillStatusBadge({ status }: { status: BillStatus }) {
  const s = BILL_STATUS[status];
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${s.color}`}>{s.label}</span>;
}

export function MaintenanceStatusBadge({ status }: { status: MaintenanceStatus }) {
  const s = MAINTENANCE_STATUS[status];
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${s.color}`}>{s.label}</span>;
}

export function TenantStatusBadge({ status }: { status: TenantStatus }) {
  const s = TENANT_STATUS[status];
  return <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold ${s.color}`}>{s.label}</span>;
}