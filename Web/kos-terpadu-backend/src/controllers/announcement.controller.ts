import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";
import { db } from "../config/firebase";

export const getAnnouncements = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    const countRes = await query("SELECT COUNT(*) FROM announcements");
    const total = parseInt(countRes.rows[0].count);
    const result = await query(
      "SELECT * FROM announcements ORDER BY created_at DESC LIMIT $1 OFFSET $2",
      [Number(limit), offset]
    );
    res.json({
      success: true,
      data: result.rows.map(r => ({ id: r.id, title: r.title, content: r.content, createdAt: r.created_at, updatedAt: r.updated_at })),
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const createAnnouncement = async (req: AuthRequest, res: Response) => {
  try {
    const { title, content } = req.body;
    const result = await query(
      "INSERT INTO announcements (title, content) VALUES ($1,$2) RETURNING *",
      [title, content]
    );
    // Push realtime notification to ALL tenants via Firebase
    try {
      const tenants = await query("SELECT user_id FROM tenants WHERE status='active'");
      const batch = db.batch();
      tenants.rows.forEach((t: any) => {
        const ref = db.collection("realtime_notifications").doc();
        batch.set(ref, {
          userId: t.user_id, title: `Pengumuman: ${title}`,
          message: content.substring(0, 100) + (content.length > 100 ? "..." : ""),
          type: "announcement", isRead: false, createdAt: new Date(),
        });
      });
      await batch.commit();
    } catch {}
    res.status(201).json({
      success: true,
      data: { id: result.rows[0].id, title: result.rows[0].title, content: result.rows[0].content, createdAt: result.rows[0].created_at },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const updateAnnouncement = async (req: AuthRequest, res: Response) => {
  try {
    const { title, content } = req.body;
    const result = await query(
      "UPDATE announcements SET title=$1, content=$2, updated_at=NOW() WHERE id=$3 RETURNING *",
      [title, content, req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Pengumuman tidak ditemukan" });
    res.json({ success: true, data: result.rows[0] });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const deleteAnnouncement = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query("DELETE FROM announcements WHERE id=$1 RETURNING id", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Pengumuman tidak ditemukan" });
    res.json({ success: true, message: "Pengumuman berhasil dihapus" });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};