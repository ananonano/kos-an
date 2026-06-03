import { Router } from "express";
import { NotificationController } from "../controllers";
import { authenticate } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, NotificationController.getAll);
router.get("/unread-count", authenticate, NotificationController.getUnreadCount);
router.post("/:id/mark-read", authenticate, NotificationController.markAsRead);
router.post("/mark-all-read", authenticate, NotificationController.markAllAsRead);
router.delete("/:id", authenticate, NotificationController.delete);

export default router;
