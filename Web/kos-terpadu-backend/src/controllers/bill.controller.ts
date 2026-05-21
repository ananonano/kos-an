import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";
import { db } from "../config/firebase";

export const getBills = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10, status = "" } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    let where = "WHERE 1=1";
    const params: any[] = [];
    let idx = 1;
    if (status) { where += ` AND b.status = $${idx++}`; params.push(status); }
    const countRes = await query(`SELECT COUNT(*) FROM bills b ${where}`, params);
    const total = parseInt(countRes.rows[0].count);
    params.push(Number(limit), offset);
    const result = await query(`
      SELECT b.*, u.name as tenant_name, r.room_number
      FROM bills b
      JOIN tenants t ON b.tenant_id = t.id
      JOIN users u ON t.user_id = u.id
      JOIN rooms r ON t.room_id = r.id
      ${where} ORDER BY b.year DESC, b.month DESC LIMIT $${idx} OFFSET $${idx+1}
    `, params);
    res.json({
      success: true,
      data: result.rows.map(r => ({
        id: r.id, tenantId: r.tenant_id, month: r.month, year: r.year,
        amount: parseFloat(r.amount), dueDate: r.due_date, status: r.status,
        createdAt: r.created_at,
        tenant: { name: r.tenant_name, roomNumber: r.room_number },
      })),
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const generateBills = async (req: AuthRequest, res: Response) => {
  try {
    const { month, year } = req.body;
    if (!month || !year) return res.status(400).json({ success: false, message: "Bulan dan tahun wajib diisi" });
    // Get all active tenants with room price
    const tenants = await query(`
      SELECT t.id, r.price FROM tenants t
      JOIN rooms r ON t.room_id = r.id
      WHERE t.status = 'active'
    `);
    if (!tenants.rows.length) return res.status(400).json({ success: false, message: "Tidak ada penghuni aktif" });
    const dueDate = `${year}-${String(month).padStart(2,"0")}-10`;
    const created: any[] = [];
    for (const t of tenants.rows) {
      try {
        const res2 = await query(
          "INSERT INTO bills (tenant_id, month, year, amount, due_date) VALUES ($1,$2,$3,$4,$5) ON CONFLICT (tenant_id, month, year) DO NOTHING RETURNING *",
          [t.id, month, year, t.price, dueDate]
        );
        if (res2.rows.length) {
          created.push(res2.rows[0]);
          // Firebase notification
          const userRes = await query("SELECT user_id FROM tenants WHERE id=$1", [t.id]);
          if (userRes.rows.length) {
            await db.collection("realtime_notifications").add({
              userId: userRes.rows[0].user_id,
              title: "Tagihan Baru",
              message: `Tagihan bulan ${month}/${year} sebesar Rp ${t.price.toLocaleString()} telah diterbitkan.`,
              type: "bill", isRead: false, createdAt: new Date(),
            }).catch(() => {});
          }
        }
      } catch {}
    }
    res.status(201).json({ success: true, data: created, message: `${created.length} tagihan berhasil digenerate` });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};