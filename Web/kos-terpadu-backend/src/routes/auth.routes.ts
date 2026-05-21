import { Router } from "express";
import { login, logout, getProfile, updateProfile, changePassword, forgotPassword, resetPassword } from "../controllers/auth.controller";
import { authenticate, adminOnly } from "../middleware/auth.middleware";

const router = Router();
router.post("/login", login);
router.post("/logout", authenticate, logout);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.get("/profile", authenticate, adminOnly, getProfile);
router.put("/profile", authenticate, adminOnly, updateProfile);
router.put("/change-password", authenticate, adminOnly, changePassword);
export default router;