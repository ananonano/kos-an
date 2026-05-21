import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";

export const getRooms = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10, search = "", status = "" } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    let whereClause = "WHERE 1=1";
    const params: any[] = [];
    let paramIdx = 1;
    if (search) { whereClause += ` AND room_number ILIKE $${paramIdx++}`; params.push(`%${search}%`); }
    if (status) { whereClause += ` AND status = $${paramIdx++}`; params.push(status); }

    const countResult = await query(`SELECT COUNT(*) FROM rooms ${whereClause}`, params);
    const total = parseInt(countResult.rows[0].count);

    params.push(Number(limit), offset);
    const result = await query(
      `SELECT * FROM rooms ${whereClause} ORDER BY room_number LIMIT $${paramIdx} OFFSET $${paramIdx + 1}`,
      params
    );

    res.json({
      success: true,
      data: result.rows.map(formatRoom),
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getRoomById = async (req: Request, res: Response) => {
  try {
    const result = await query("SELECT * FROM rooms WHERE id = $1", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Kamar tidak ditemukan" });
    res.json({ success: true, data: formatRoom(result.rows[0]) });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const createRoom = async (req: AuthRequest, res: Response) => {
  try {
    const { roomNumber, price, status, description, facilities } = req.body;
    const result = await query(
      "INSERT INTO rooms (room_number, price, status, description, facilities) VALUES ($1,$2,$3,$4,$5) RETURNING *",
      [roomNumber, price, status || "available", description, facilities || []]
    );
    res.status(201).json({ success: true, data: formatRoom(result.rows[0]) });
  } catch (err: any) {
    if (err.code === "23505") return res.status(400).json({ success: false, message: "Nomor kamar sudah ada" });
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const updateRoom = async (req: AuthRequest, res: Response) => {
  try {
    const { roomNumber, price, status, description, facilities } = req.body;
    const result = await query(
      "UPDATE rooms SET room_number=$1, price=$2, status=$3, description=$4, facilities=$5, updated_at=NOW() WHERE id=$6 RETURNING *",
      [roomNumber, price, status, description, facilities, req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Kamar tidak ditemukan" });
    res.json({ success: true, data: formatRoom(result.rows[0]) });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const deleteRoom = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query("DELETE FROM rooms WHERE id=$1 RETURNING id", [req.params.id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Kamar tidak ditemukan" });
    res.json({ success: true, message: "Kamar berhasil dihapus" });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

const formatRoom = (r: any) => ({
  id: r.id, roomNumber: r.room_number, price: parseFloat(r.price),
  status: r.status, description: r.description, facilities: r.facilities || [],
  images: r.images || [], createdAt: r.created_at, updatedAt: r.updated_at,
});