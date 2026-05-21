import { Request, Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";
import { db } from "../config/firebase";

export const getPayments = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 10, status = "" } = req.query;
    const offset = (Number(page) - 1) * Number(limit);
    let where = "WHERE 1=1";
    const params: any[] = [];
    let idx = 1;
    if (status) { where += ` AND p.status = $${idx++}`; params.push(status); }
    const countRes = await query(`SELECT COUNT(*) FROM payments p ${where}`, params);
    const total = parseInt(countRes.rows[0].count);
    params.push(Number(limit), offset);
    const result = await query(`
      SELECT p.*, b.month, b.year, b.amount as bill_amount, b.due_date,
             u.name as tenant_name, r.room_number
      FROM payments p
      JOIN bills b ON p.bill_id = b.id
      JOIN tenants t ON b.tenant_id = t.id
      JOIN users u ON t.user_id = u.id
      JOIN rooms r ON t.room_id = r.id
      ${where} ORDER BY p.created_at DESC LIMIT $${idx} OFFSET $${idx+1}
    `, params);
    res.json({
      success: true,
      data: result.rows.map(r => ({
        id: r.id, billId: r.bill_id, amount: parseFloat(r.amount),
        proofImage: r.proof_image, status: r.status,
        paymentDate: r.payment_date, createdAt: r.created_at,
        bill: { month: r.month, year: r.year, amount: parseFloat(r.bill_amount), dueDate: r.due_date },
        tenant: { name: r.tenant_name, roomNumber: r.room_number },
      })),
      pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / Number(limit)) },
    });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const verifyPayment = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      "UPDATE payments SET status='verified' WHERE id=$1 AND status='pending' RETURNING *, bill_id",
      [req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Pembayaran tidak ditemukan atau sudah diproses" });
    // Update bill status
    await query("UPDATE bills SET status='paid' WHERE id=$1", [result.rows[0].bill_id]);
    // Firebase notification
    try {
      const billRes = await query("SELECT t.user_id FROM bills b JOIN tenants t ON b.tenant_id=t.id WHERE b.id=$1", [result.rows[0].bill_id]);
      if (billRes.rows.length) {
        await db.collection("realtime_notifications").add({
          userId: billRes.rows[0].user_id,
          title: "Pembayaran Diverifikasi",
          message: "Pembayaran Anda telah diverifikasi oleh admin.",
          type: "payment", isRead: false,
          createdAt: new Date(),
        });
      }
    } catch {}
    res.json({ success: true, message: "Pembayaran berhasil diverifikasi" });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};

export const rejectPayment = async (req: AuthRequest, res: Response) => {
  try {
    const { reason } = req.body;
    const result = await query(
      "UPDATE payments SET status='rejected', rejection_reason=$1 WHERE id=$2 AND status='pending' RETURNING *, bill_id",
      [reason || "Bukti pembayaran tidak valid", req.params.id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: "Pembayaran tidak ditemukan" });
    try {
      const billRes = await query("SELECT t.user_id FROM bills b JOIN tenants t ON b.tenant_id=t.id WHERE b.id=$1", [result.rows[0].bill_id]);
      if (billRes.rows.length) {
        await db.collection("realtime_notifications").add({
          userId: billRes.rows[0].user_id,
          title: "Pembayaran Ditolak",
          message: `Pembayaran Anda ditolak. Alasan: ${reason || "Bukti tidak valid"}`,
          type: "payment", isRead: false, createdAt: new Date(),
        });
      }
    } catch {}
    res.json({ success: true, message: "Pembayaran ditolak" });
  } catch { res.status(500).json({ success: false, message: "Server error" }); }
};