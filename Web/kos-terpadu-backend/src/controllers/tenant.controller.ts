import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";
import bcrypt from "bcryptjs";

const formatTenant = (r: any) => ({
  id: r.id, userId: r.user_id, roomId: r.room_id,
  startDate: r.start_date, endDate: r.end_date, status: r.status,
  createdAt: r.created_at,
  user: { id: r.user_id, name: r.user_name, email: r.user_email, phone: r.user_phone, role: "tenant", createdAt: r.user_created_at, updatedAt: r.user_updated_at },
  room: { id: r.room_id, roomNumber: r.room_number, price: parseFloat(r.room_price), status: r.room_status, facilities: r.room_facilities || [], images: [] },
});

export const getTenants = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10, search = "", status = "" } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    let where = "WHERE 1=1";
    const params: any[] = [];
    let idx = 1;
    if (search) { where += ` AND (u.name ILIKE $${idx++} OR u.email ILIKE $${idx - 1})`; params.push(`%${search}%`); }
    if (status) { where += ` AND t.status = $${idx++}`; params.push(status); }

    const countRes = await query(`SELECT COUNT(*) FROM tenants t JOIN users u ON t.user_id=u.id ${where}`, params);
    const total = parseInt(countRes.rows[0].count);

    params.push(Number(limit), offset);
    const result = await query(`
      SELECT t.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
             u.created_at as user_created_at, u.updated_at as user_updated_at,
             r.room_number, r.price as room_price, r.status as room_status, r.facilities as room_facilities
      FROM tenants t
      JOIN users u ON t.user_id = u.id
      JOIN rooms r ON t.room_id = r.id
      ${where} ORDER BY t.created_at DESC LIMIT $${idx} OFFSET $${idx + 1}
    `, params);

    res.json({
      success: true,
      data: result.rows.map(formatTenant),
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const createTenant = async (req: AuthRequest, res: Response) => {
  try {
    const { name, email, phone, roomId, startDate, endDate } = req.body;
    const client = await (await import("../config/database")).getClient();
    try {
      await client.query("BEGIN");
      const hashedPw = await bcrypt.hash("tenant123", 12);
      const userRes = await client.query(
        "INSERT INTO users (name, email, password, phone, role) VALUES ($1,$2,$3,$4,'tenant') RETURNING *",
        [name, email, hashedPw, phone]
      );
      const tenantRes = await client.query(
        "INSERT INTO tenants (user_id, room_id, start_date, end_date, status) VALUES ($1,$2,$3,$4,'active') RETURNING *",
        [userRes.rows[0].id, roomId, startDate, endDate || null]
      );
      await client.query("UPDATE rooms SET status='occupied', updated_at=NOW() WHERE id=$1", [roomId]);
      await client.query("COMMIT");
      res.status(201).json({ success: true, data: { id: tenantRes.rows[0].id, ...tenantRes.rows[0] } });
    } catch (err: any) {
      await client.query("ROLLBACK");
      if (err.code === "23505") return res.status(400).json({ success: false, message: "Email sudah terdaftar" });
      throw err;
    } finally { client.release(); }
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const updateTenant = async (req: AuthRequest, res: Response) => {
  try {
    const { name, phone, status, endDate } = req.body;
    const tenantRes = await query("SELECT user_id FROM tenants WHERE id=$1", [req.params.id]);
    if (!tenantRes.rows.length) return res.status(404).json({ success: false, message: "Penghuni tidak ditemukan" });
    await query("UPDATE users SET name=$1, phone=$2, updated_at=NOW() WHERE id=$3", [name, phone, tenantRes.rows[0].user_id]);
    await query("UPDATE tenants SET status=$1, end_date=$2, updated_at=NOW() WHERE id=$3", [status, endDate || null, req.params.id]);
    res.json({ success: true, message: "Data penghuni diperbarui" });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const deleteTenant = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query("DELETE FROM tenants WHERE id=$1 RETURNING room_id", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Penghuni tidak ditemukan" });
    await query("UPDATE rooms SET status='available', updated_at=NOW() WHERE id=$1", [result.rows[0].room_id]);
    res.json({ success: true, message: "Penghuni berhasil dihapus" });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};