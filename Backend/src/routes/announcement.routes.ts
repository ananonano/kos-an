import { Router } from "express";
import { AnnouncementController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", authenticate, AnnouncementController.getAll);
router.get("/active/:target", authenticate, AnnouncementController.getActiveByTarget);
router.get("/statistics", authenticate, adminOnly, AnnouncementController.getStatistics);
router.get("/:id", authenticate, AnnouncementController.getById);
router.post("/", authenticate, adminOnly, AnnouncementController.create);
router.put("/:id", authenticate, adminOnly, AnnouncementController.update);
router.delete("/:id", authenticate, adminOnly, AnnouncementController.delete);
router.post("/:id/activate", authenticate, adminOnly, AnnouncementController.activate);
router.post("/:id/deactivate", authenticate, adminOnly, AnnouncementController.deactivate);

export default router;