import { Response } from "express";
import { query } from "../config/database";
import { AuthRequest } from "../middleware/auth.middleware";

export const getStats = async (req: AuthRequest, res: Response) => {
  try {
    const [rooms, tenants, bills, payments, maintenance] = await Promise.all([
      query("SELECT status, COUNT(*) as count FROM rooms GROUP BY status"),
      query("SELECT COUNT(*) as count FROM tenants WHERE status = 'active'"),
      query("SELECT COUNT(*) as count FROM bills WHERE status = 'pending'"),
      query("SELECT COALESCE(SUM(amount),0) as total FROM payments WHERE status = 'verified' AND DATE_TRUNC('month', payment_date) = DATE_TRUNC('month', NOW())"),
      query("SELECT COUNT(*) as count FROM maintenance_reports WHERE status != 'completed'"),
    ]);

    const roomMap: Record<string, number> = {};
    rooms.rows.forEach((r: any) => { roomMap[r.status] = parseInt(r.count); });
    const totalRooms = Object.values(roomMap).reduce((a, b) => a + b, 0);

    res.json({
      success: true,
      data: {
        totalRooms,
        availableRooms: roomMap["available"] || 0,
        occupiedRooms: roomMap["occupied"] || 0,
        maintenanceRooms: roomMap["maintenance"] || 0,
        totalTenants: parseInt(tenants.rows[0].count),
        unpaidBills: parseInt(bills.rows[0].count),
        totalIncome: parseFloat(payments.rows[0].total),
        pendingPayments: 0,
        pendingMaintenance: parseInt(maintenance.rows[0].count),
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getMonthlyIncome = async (req: AuthRequest, res: Response) => {
  try {
    const year = req.query.year || new Date().getFullYear();
    const result = await query(`
      SELECT
        EXTRACT(MONTH FROM payment_date) as month,
        COALESCE(SUM(amount), 0) as income
      FROM payments
      WHERE status = 'verified'
        AND EXTRACT(YEAR FROM payment_date) = $1
      GROUP BY EXTRACT(MONTH FROM payment_date)
      ORDER BY month
    `, [year]);

    const months = ["Jan","Feb","Mar","Apr","Mei","Jun","Jul","Agu","Sep","Okt","Nov","Des"];
    const data = months.map((m, i) => {
      const found = result.rows.find((r: any) => parseInt(r.month) === i + 1);
      return { month: m, income: found ? parseFloat(found.income) : 0 };
    });

    res.json({ success: true, data });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};

export const getRecentActivity = async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(`
      SELECT id, user_id, activity, created_at
      FROM activity_logs
      ORDER BY created_at DESC
      LIMIT 10
    `);
    res.json({
      success: true,
      data: result.rows.map((r: any) => ({
        id: r.id, type: "activity", description: r.activity, createdAt: r.created_at,
      })),
    });
  } catch {
    res.status(500).json({ success: false, message: "Server error" });
  }
};