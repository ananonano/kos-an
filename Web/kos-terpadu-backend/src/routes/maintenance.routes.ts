import { Router } from "express";
import { MaintenanceController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, MaintenanceController.getAll);
router.get("/urgent", authenticate, adminOnly, MaintenanceController.getUrgent);
router.get("/statistics", authenticate, adminOnly, MaintenanceController.getStatistics);
router.get("/by-category", authenticate, adminOnly, MaintenanceController.getByCategory);
router.get("/:id", authenticate, MaintenanceController.getById);
router.post("/", authenticate, MaintenanceController.create);
router.put("/:id", authenticate, MaintenanceController.update);
router.put("/:id/status", authenticate, adminOnly, MaintenanceController.updateStatus);
router.delete("/:id", authenticate, adminOnly, MaintenanceController.delete);

export default router;