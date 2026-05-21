import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { query } from "../config/database";

export interface AuthRequest extends Request {
  user?: { id: string; email: string; role: string; name: string };
}

export const authenticate = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({ success: false, message: "Token tidak ditemukan" });
    }
    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    const result = await query("SELECT id, email, role, name FROM users WHERE id = $1", [decoded.id]);
    if (result.rows.length === 0) {
      return res.status(401).json({ success: false, message: "User tidak ditemukan" });
    }
    req.user = result.rows[0];
    next();
  } catch {
    return res.status(401).json({ success: false, message: "Token tidak valid" });
  }
};

export const adminOnly = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (req.user?.role !== "admin") {
    return res.status(403).json({ success: false, message: "Akses ditolak. Admin only." });
  }
  next();
};