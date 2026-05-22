import { Router } from "express";
import { DashboardController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/admin", authenticate, adminOnly, DashboardController.getAdminOverview);
router.get("/tenant/:tenantId", authenticate, DashboardController.getTenantOverview);
router.get("/financial", authenticate, adminOnly, DashboardController.getFinancialSummary);
router.get("/activities", authenticate, adminOnly, DashboardController.getRecentActivities);
router.get("/pending-tasks", authenticate, adminOnly, DashboardController.getPendingTasks);

export default router;