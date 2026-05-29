import { Router } from "express";
import { RoomController } from "../controllers";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();

router.get("/", RoomController.getAll);
router.get("/statistics", authenticate, adminOnly, RoomController.getStatistics);
router.get("/:id", RoomController.getById);
router.post("/", authenticate, adminOnly, RoomController.create);
router.put("/:id", authenticate, adminOnly, RoomController.update);
router.delete("/:id", authenticate, adminOnly, RoomController.delete);

export default router;