import { Router } from "express";
import { getRooms, getRoomById, createRoom, updateRoom, deleteRoom } from "../controllers/room.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.get("/", getRooms);
router.get("/:id", getRoomById);
router.use(authenticate, adminOnly);
router.post("/", createRoom);
router.put("/:id", updateRoom);
router.delete("/:id", deleteRoom);
export default router;