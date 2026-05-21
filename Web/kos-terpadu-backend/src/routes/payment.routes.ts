import { Router } from "express";
import { getPayments, verifyPayment, rejectPayment } from "../controllers/payment.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.use(authenticate, adminOnly);
router.get("/", getPayments);
router.put("/:id/verify", verifyPayment);
router.put("/:id/reject", rejectPayment);
export default router;