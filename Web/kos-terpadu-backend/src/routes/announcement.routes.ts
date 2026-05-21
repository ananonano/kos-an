import { Router } from "express";
import { getAnnouncements, createAnnouncement, updateAnnouncement, deleteAnnouncement } from "../controllers/announcement.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.get("/", getAnnouncements);
router.use(authenticate, adminOnly);
router.post("/", createAnnouncement);
router.put("/:id", updateAnnouncement);
router.delete("/:id", deleteAnnouncement);
export default router;