import { Router } from "express";
import { getMaintenance, updateMaintenance, addProgress } from "../controllers/maintenance.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";
import { upload } from "../middleware/upload.middleware";

const router = Router();
router.use(authenticate, adminOnly);
router.get("/", getMaintenance);
router.put("/:id", updateMaintenance);
router.post("/:id/progress", upload.single("image"), addProgress);
export default router;