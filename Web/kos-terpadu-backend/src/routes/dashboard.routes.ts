import { Router } from "express";
import { getStats, getMonthlyIncome, getRecentActivity } from "../controllers/dashboard.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.use(authenticate, adminOnly);
router.get("/stats", getStats);
router.get("/monthly-income", getMonthlyIncome);
router.get("/activity", getRecentActivity);
export default router;