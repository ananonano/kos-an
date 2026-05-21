import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";
import { db } from "../config/firebase";

export const getMaintenance = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10, status = "" } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    let where = "WHERE 1=1";
    const params: any[] = [];
    let idx = 1;
    if (status) { where += ` AND mr.status = $${idx++}`; params.push(status); }
    const countRes = await query(`SELECT COUNT(*) FROM maintenance_reports mr ${where}`, params);
    const total = parseInt(countRes.rows[0].count);
    params.push(Number(limit), offset);
    const result = await query(`
      SELECT mr.*, u.name as tenant_name, r.room_number
      FROM maintenance_reports mr
      JOIN tenants t ON mr.tenant_id = t.id
      JOIN users u ON t.user_id = u.id
      JOIN rooms r ON t.room_id = r.id
      ${where} ORDER BY mr.created_at DESC LIMIT $${idx} OFFSET $${idx+1}
    `, params);
    // Get progress for each report
    const reports = await Promise.all(result.rows.map(async (row: any) => {
      const progress = await query(
        "SELECT * FROM maintenance_progress WHERE report_id=$1 ORDER BY created_at ASC",
        [row.id]
      );
      return {
        id: row.id, tenantId: row.tenant_id, title: row.title,
        description: row.description, status: row.status, createdAt: row.created_at,
        tenant: { name: row.tenant_name, roomNumber: row.room_number },
        progress: progress.rows.map((p: any) => ({
          id: p.id, reportId: p.report_id, description: p.description,
          image: p.image, createdAt: p.created_at,
        })),
      };
    }));
    res.json({
      success: true, data: reports,
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const updateMaintenance = async (req: AuthRequest, res: Response) => {
  try {
    const { status } = req.body;
    const result = await query(
      "UPDATE maintenance_reports SET status=$1, updated_at=NOW() WHERE id=$2 RETURNING *, tenant_id",
      [status, req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Laporan tidak ditemukan" });
    // Notify tenant via Firebase
    try {
      const userRes = await query("SELECT user_id FROM tenants WHERE id=$1", [result.rows[0].tenant_id]);
      if (userRes.rows.length) {
        const statusLabel = status === "in_progress" ? "sedang diproses" : status === "completed" ? "telah selesai" : "pending";
        await db.collection("realtime_notifications").add({
          userId: userRes.rows[0].user_id,
          title: "Update Keluhan",
          message: `Keluhan "${result.rows[0].title}" ${statusLabel}.`,
          type: "maintenance", isRead: false, createdAt: new Date(),
        });
        // Update Firestore realtime status
        await db.collection("maintenance_status").doc(req.params.id).set({
          status, updatedAt: new Date(), reportId: req.params.id,
        }, { merge: true });
      }
    } catch {}
    res.json({ success: true, message: "Status keluhan diperbarui" });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const addProgress = async (req: AuthRequest, res: Response) => {
  try {
    const { description } = req.body;
    const imageUrl = req.file ? (req as any).fileUrl : null;
    const result = await query(
      "INSERT INTO maintenance_progress (report_id, description, image) VALUES ($1,$2,$3) RETURNING *",
      [req.params.id, description, imageUrl]
    );
    // Auto update status to in_progress
    await query(
      "UPDATE maintenance_reports SET status='in_progress', updated_at=NOW() WHERE id=$1 AND status='pending'",
      [req.params.id]
    );
    // Firestore realtime update
    try {
      await db.collection("maintenance_status").doc(req.params.id).set({
        status: "in_progress", lastProgress: description, updatedAt: new Date(),
      }, { merge: true });
    } catch {}
    res.status(201).json({
      success: true,
      data: { id: result.rows[0].id, reportId: result.rows[0].report_id, description: result.rows[0].description, image: result.rows[0].image, createdAt: result.rows[0].created_at },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};