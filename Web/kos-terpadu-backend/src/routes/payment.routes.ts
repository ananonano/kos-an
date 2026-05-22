import { Router } from "express";
import { PaymentController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, PaymentController.getAll);
router.get("/pending", authenticate, adminOnly, PaymentController.getPending);
router.get("/statistics", authenticate, adminOnly, PaymentController.getStatistics);
router.get("/:id", authenticate, PaymentController.getById);
router.post("/", authenticate, PaymentController.create);
router.put("/:id", authenticate, PaymentController.update);
router.delete("/:id", authenticate, PaymentController.delete);
router.post("/:id/verify", authenticate, adminOnly, PaymentController.verify);
router.post("/:id/reject", authenticate, adminOnly, PaymentController.reject);

export default router;