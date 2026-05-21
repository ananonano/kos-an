import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: "Email dan password wajib diisi" });
    }
    const result = await query("SELECT * FROM users WHERE email = $1 AND role = 'admin'", [email]);
    if (result.rows.length === 0) {
      return res.status(401).json({ success: false, message: "Email atau password salah" });
    }
    const user = result.rows[0];
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ success: false, message: "Email atau password salah" });
    }
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET!,
      { expiresIn: process.env.JWT_EXPIRES_IN || "7d" } as any
    );
    const { password: _, ...userWithoutPassword } = user;
    res.json({
      success: true,
      data: {
        user: { ...userWithoutPassword, createdAt: user.created_at, updatedAt: user.updated_at },
        token,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const logout = async (req: AuthRequest, res: Response) => {
  res.json({ success: true, message: "Logout berhasil" });
};

export const getProfile = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      "SELECT id, name, email, phone, role, avatar, created_at, updated_at FROM users WHERE id = $1",
      [req.user!.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "User tidak ditemukan" });
    }
    const u = result.rows[0];
    res.json({ success: true, data: { ...u, createdAt: u.created_at, updatedAt: u.updated_at } });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const updateProfile = async (req: AuthRequest, res: Response) => {
  try {
    const { name, phone } = req.body;
    const result = await query(
      "UPDATE users SET name=$1, phone=$2, updated_at=NOW() WHERE id=$3 RETURNING id,name,email,phone,role,avatar,created_at,updated_at",
      [name, phone, req.user!.id]
    );
    const u = result.rows[0];
    res.json({ success: true, data: { ...u, createdAt: u.created_at, updatedAt: u.updated_at } });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const changePassword = async (req: AuthRequest, res: Response) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const result = await query("SELECT password FROM users WHERE id=$1", [req.user!.id]);
    const isValid = await bcrypt.compare(currentPassword, result.rows[0].password);
    if (!isValid) {
      return res.status(400).json({ success: false, message: "Password saat ini salah" });
    }
    const hashed = await bcrypt.hash(newPassword, 12);
    await query("UPDATE users SET password=$1, updated_at=NOW() WHERE id=$2", [hashed, req.user!.id]);
    res.json({ success: true, message: "Password berhasil diubah" });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const forgotPassword = async (req: Request, res: Response) => {
  // In production: generate reset token, send email
  res.json({ success: true, message: "Link reset password telah dikirim ke email Anda" });
};

export const resetPassword = async (req: Request, res: Response) => {
  // In production: verify token, update password
  res.json({ success: true, message: "Password berhasil direset" });
};