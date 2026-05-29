// ============================================
// PAYMENT MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Payment } from '../types';

export class PaymentModel {
    // Create new payment
    static async create(data: {
        bill_id: number;
        tenant_id: number;
        jumlah: number;
        tanggal_bayar: Date;
        metode_pembayaran: string;
        bukti_pembayaran?: string;
        keterangan?: string;
    }): Promise<Payment> {
        const query = `
      INSERT INTO payments (
        bill_id, tenant_id, jumlah, tanggal_bayar,
        metode_pembayaran, bukti_pembayaran, status, keterangan
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `;

        const values = [
            data.bill_id,
            data.tenant_id,
            data.jumlah,
            data.tanggal_bayar,
            data.metode_pembayaran,
            data.bukti_pembayaran || null,
            'menunggu_verifikasi',
            data.keterangan || null,
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find payment by ID
    static async findById(id: number): Promise<Payment | null> {
        const query = `
      SELECT p.*, 
        t.nama as nama_tenant,
        t.email as tenant_email,
        r.nomor_kamar,
        b.bulan,
        b.tahun,
        b.jumlah as bill_amount,
        u.nama as verified_by_name
      FROM payments p
      JOIN tenants t ON p.tenant_id = t.id
      JOIN bills b ON p.bill_id = b.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      LEFT JOIN users u ON p.verified_by = u.id
      WHERE p.id = $1
    `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Get all payments with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        tenant_id?: number;
        bill_id?: number;
        status?: 'menunggu_verifikasi' | 'lunas' | 'ditolak';
        search?: string;
    }): Promise<{ payments: Payment[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.tenant_id) {
            whereClause += ` AND p.tenant_id = $${paramCount}`;
            values.push(options.tenant_id);
            paramCount++;
        }

        if (options.bill_id) {
            whereClause += ` AND p.bill_id = $${paramCount}`;
            values.push(options.bill_id);
            paramCount++;
        }

        if (options.status) {
            whereClause += ` AND p.status = $${paramCount}`;
            values.push(options.status);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (t.nama ILIKE $${paramCount} OR r.nomor_kamar ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        // Get total count
        const countQuery = `
      SELECT COUNT(*) 
      FROM payments p
      JOIN tenants t ON p.tenant_id = t.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get payments
        const query = `
      SELECT p.*, 
        t.nama as nama_tenant,
        t.email as tenant_email,
        r.nomor_kamar,
        b.bulan,
        b.tahun,
        b.jumlah as bill_amount,
        u.nama as verified_by_name
      FROM payments p
      JOIN tenants t ON p.tenant_id = t.id
      JOIN bills b ON p.bill_id = b.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      LEFT JOIN users u ON p.verified_by = u.id
      ${whereClause}
      ORDER BY p.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { payments: result.rows, total };
    }

    // Update payment
    static async update(id: number, data: {
        jumlah?: number;
        tanggal_bayar?: Date;
        metode_pembayaran?: string;
        bukti_pembayaran?: string;
        status?: 'menunggu_verifikasi' | 'lunas' | 'ditolak';
        keterangan?: string;
        verified_by?: number;
    }): Promise<Payment | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.jumlah !== undefined) {
            updates.push(`jumlah = $${paramCount}`);
            values.push(data.jumlah);
            paramCount++;
        }

        if (data.tanggal_bayar !== undefined) {
            updates.push(`tanggal_bayar = $${paramCount}`);
            values.push(data.tanggal_bayar);
            paramCount++;
        }

        if (data.metode_pembayaran !== undefined) {
            updates.push(`metode_pembayaran = $${paramCount}`);
            values.push(data.metode_pembayaran);
            paramCount++;
        }

        if (data.bukti_pembayaran !== undefined) {
            updates.push(`bukti_pembayaran = $${paramCount}`);
            values.push(data.bukti_pembayaran);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
            paramCount++;
        }

        if (data.keterangan !== undefined) {
            updates.push(`keterangan = $${paramCount}`);
            values.push(data.keterangan);
            paramCount++;
        }

        if (data.verified_by !== undefined) {
            updates.push(`verified_by = $${paramCount}`);
            values.push(data.verified_by);
            paramCount++;
            updates.push(`verified_at = NOW()`);
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE payments
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);
        return result.rows[0] || null;
    }

    // Delete payment
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM payments WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Verify payment (approve)
    static async verify(id: number, verifiedBy: number, keterangan?: string): Promise<Payment | null> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // Get payment info
            const getPaymentQuery = 'SELECT bill_id FROM payments WHERE id = $1';
            const paymentResult = await client.query(getPaymentQuery, [id]);

            if (paymentResult.rows.length === 0) {
                throw new Error('Payment not found');
            }

            const billId = paymentResult.rows[0].bill_id;

            // Update payment status
            const updatePaymentQuery = `
        UPDATE payments
        SET status = 'lunas',
            verified_by = $1,
            verified_at = NOW(),
            keterangan = $2,
            updated_at = NOW()
        WHERE id = $3
        RETURNING *
      `;
            const updatedPayment = await client.query(updatePaymentQuery, [
                verifiedBy,
                keterangan || 'Pembayaran telah diverifikasi',
                id,
            ]);

            // Update bill status to lunas
            const updateBillQuery = `
        UPDATE bills
        SET status = 'lunas', updated_at = NOW()
        WHERE id = $1
      `;
            await client.query(updateBillQuery, [billId]);

            await client.query('COMMIT');
            return updatedPayment.rows[0];
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    // Reject payment
    static async reject(id: number, verifiedBy: number, keterangan: string): Promise<Payment | null> {
        const query = `
      UPDATE payments
      SET status = 'ditolak',
          verified_by = $1,
          verified_at = NOW(),
          keterangan = $2,
          updated_at = NOW()
      WHERE id = $3
      RETURNING *
    `;

        const result = await pool.query(query, [verifiedBy, keterangan, id]);
        return result.rows[0] || null;
    }

    // Get payment statistics
    static async getStatistics(options?: {
        bulan?: string;
        tahun?: number;
    }): Promise<{
        total_payments: number;
        total_verified: number;
        total_pending: number;
        total_rejected: number;
        total_amount: number;
    }> {
        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options?.bulan || options?.tahun) {
            whereClause += ' AND p.bill_id IN (SELECT id FROM bills WHERE 1=1';

            if (options.bulan) {
                whereClause += ` AND bulan = $${paramCount}`;
                values.push(options.bulan);
                paramCount++;
            }

            if (options.tahun) {
                whereClause += ` AND tahun = $${paramCount}`;
                values.push(options.tahun);
                paramCount++;
            }

            whereClause += ')';
        }

        const query = `
      SELECT 
        COUNT(*) as total_payments,
        COUNT(*) FILTER (WHERE p.status = 'lunas') as total_verified,
        COUNT(*) FILTER (WHERE p.status = 'menunggu_verifikasi') as total_pending,
        COUNT(*) FILTER (WHERE p.status = 'ditolak') as total_rejected,
        COALESCE(SUM(p.jumlah) FILTER (WHERE p.status = 'lunas'), 0) as total_amount
      FROM payments p
      ${whereClause}
    `;

        const result = await pool.query(query, values);
        const stats = result.rows[0];

        return {
            total_payments: parseInt(stats.total_payments),
            total_verified: parseInt(stats.total_verified),
            total_pending: parseInt(stats.total_pending),
            total_rejected: parseInt(stats.total_rejected),
            total_amount: parseFloat(stats.total_amount),
        };
    }

    // Get pending payments (menunggu verifikasi)
    static async getPendingPayments(): Promise<Payment[]> {
        const query = `
      SELECT p.*, 
        t.nama as nama_tenant,
        r.nomor_kamar,
        b.bulan,
        b.tahun
      FROM payments p
      JOIN tenants t ON p.tenant_id = t.id
      JOIN bills b ON p.bill_id = b.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      WHERE p.status = 'menunggu_verifikasi'
      ORDER BY p.created_at ASC
    `;

        const result = await pool.query(query);
        return result.rows;
    }
}
