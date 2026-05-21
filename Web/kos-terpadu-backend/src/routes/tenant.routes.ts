import { Router } from "express";
import { getTenants, createTenant, updateTenant, deleteTenant } from "../controllers/tenant.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.use(authenticate, adminOnly);
router.get("/", getTenants);
router.post("/", createTenant);
router.put("/:id", updateTenant);
router.delete("/:id", deleteTenant);
export default router;