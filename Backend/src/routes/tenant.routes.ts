import { Router } from "express";
import { TenantController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, adminOnly, TenantController.getAll);
router.get("/statistics", authenticate, adminOnly, TenantController.getStatistics);
router.get("/:id", authenticate, adminOnly, TenantController.getById);
router.post("/", authenticate, adminOnly, TenantController.create);
router.put("/:id", authenticate, adminOnly, TenantController.update);
router.delete("/:id", authenticate, adminOnly, TenantController.delete);

export default router;