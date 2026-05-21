import { Router } from "express";
import { getBills, generateBills } from "../controllers/bill.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.use(authenticate, adminOnly);
router.get("/", getBills);
router.post("/generate", generateBills);
export default router;