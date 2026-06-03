import { Router } from "express";
import { BillController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, BillController.getAll);
router.get("/statistics", authenticate, adminOnly, BillController.getStatistics);
router.get("/:id", authenticate, BillController.getById);
router.post("/", authenticate, adminOnly, BillController.create);
router.put("/:id", authenticate, adminOnly, BillController.update);
router.delete("/:id", authenticate, adminOnly, BillController.delete);
router.post("/generate-monthly", authenticate, adminOnly, BillController.generateMonthly);
router.post("/generate-all", authenticate, adminOnly, BillController.generateForAllTenants); // ✅ New: Generate for all tenants based on tanggal_masuk
router.post("/generate/:tenantId", authenticate, adminOnly, BillController.generateForTenant); // ✅ New: Generate for specific tenant
router.post("/update-overdue", authenticate, adminOnly, BillController.updateOverdue);

export default router;