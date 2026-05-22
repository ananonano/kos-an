import { Router } from "express";
import { AuthController } from "../controllers";
import { authenticate } from "../middleware/auth.middleware";

const router = Router();

router.post("/register", AuthController.register);
router.post("/login", AuthController.login);
router.get("/me", authenticate, AuthController.getMe);
router.post("/logout", authenticate, AuthController.logout);
router.put("/profile", authenticate, AuthController.updateProfile);
router.put("/change-password", authenticate, AuthController.changePassword);

export default router;