import { Router } from "express";
import authRoutes from "./auth.routes";
import dashboardRoutes from "./dashboard.routes";
import roomRoutes from "./room.routes";
import tenantRoutes from "./tenant.routes";
import paymentRoutes from "./payment.routes";
import billRoutes from "./bill.routes";
import maintenanceRoutes from "./maintenance.routes";
import announcementRoutes from "./announcement.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/dashboard", dashboardRoutes);
router.use("/rooms", roomRoutes);
router.use("/tenants", tenantRoutes);
router.use("/payments", paymentRoutes);
router.use("/bills", billRoutes);
router.use("/maintenance", maintenanceRoutes);
router.use("/announcements", announcementRoutes);

export default router;