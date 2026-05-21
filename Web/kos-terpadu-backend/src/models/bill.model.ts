// ============================================
// BILL MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Bill } from '../types';

export class BillModel {
    // Create new bill
    static async create(data: {
        tenant_id: number;
        contract_id: number;
        bulan: string;
        tahun: number;
        jumlah: number;
        jatuh_tempo: Date;
        denda?: number;
        catatan?: string;
    }): Promise<Bill> {
        const query = `
      INSERT INTO bills (
        tenant_id, contract_id, bulan, tahun, jumlah,
        status, jatuh_tempo, denda, catatan
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;

        const values = [
            data.tenant_id,
            data.contract_id,
            data.bulan,
            data.tahun,
            data.jumlah,
            'belum_lunas',
            data.jatuh_tempo,
            data.denda || 0,
            data.catatan || null,
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find bill by ID
    static async findById(id: number): Promise<Bill | null> {
        const query = `
      SELECT b.*, 
        t.nama as tenant_name,
        r.nomor_kamar
      FROM bills b
      JOIN tenants t ON b.tenant_id = t.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      WHERE b.id = $1
    `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Get all bills with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        tenant_id?: number;
        status?: 'belum_lunas' | 'lunas' | 'terlambat';
        bulan?: string;
        tahun?: number;
        search?: string;
    }): Promise<{ bills: Bill[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.tenant_id) {
            whereClause += ` AND b.tenant_id = $${paramCount}`;
            values.push(options.tenant_id);
            paramCount++;
        }

        if (options.status) {
            whereClause += ` AND b.status = $${paramCount}`;
            values.push(options.status);
            paramCount++;
        }

        if (options.bulan) {
            whereClause += ` AND b.bulan = $${paramCount}`;
            values.push(options.bulan);
            paramCount++;
        }

        if (options.tahun) {
            whereClause += ` AND b.tahun = $${paramCount}`;
            values.push(options.tahun);
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
      FROM bills b
      JOIN tenants t ON b.tenant_id = t.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get bills
        const query = `
      SELECT b.*, 
        t.nama as tenant_name,
        t.email as tenant_email,
        r.nomor_kamar
      FROM bills b
      JOIN tenants t ON b.tenant_id = t.id
      LEFT JOIN rooms r ON t.kamar_id = r.id
      ${whereClause}
      ORDER BY b.tahun DESC, b.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { bills: result.rows, total };
    }

    // Update bill
    static async update(id: number, data: {
        jumlah?: number;
        status?: 'belum_lunas' | 'lunas' | 'terlambat';
        jatuh_tempo?: Date;
        denda?: number;
        catatan?: string;
    }): Promise<Bill | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.jumlah !== undefined) {
            updates.push(`jumlah = $${paramCount}`);
            values.push(data.jumlah);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
            paramCount++;
        }

        if (data.jatuh_tempo !== undefined) {
            updates.push(`jatuh_tempo = $${paramCount}`);
            values.push(data.jatuh_tempo);
            paramCount++;
        }

        if (data.denda !== undefined) {
            updates.push(`denda = $${paramCount}`);
            values.push(data.denda);
            paramCount++;
        }

        if (data.catatan !== undefined) {
            updates.push(`catatan = $${paramCount}`);
            values.push(data.catatan);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE bills
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);
        return result.rows[0] || null;
    }

    // Delete bill
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM bills WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Check if bill exists for tenant in specific month/year
    static async existsForTenantMonth(
        tenantId: number,
        bulan: string,
        tahun: number,
        excludeId?: number
    ): Promise<boolean> {
        let query = `
      SELECT id FROM bills 
      WHERE tenant_id = $1 AND bulan = $2 AND tahun = $3
    `;
        const values: any[] = [tenantId, bulan, tahun];

        if (excludeId) {
            query += ' AND id != $4';
            values.push(excludeId);
        }

        const result = await pool.query(query, values);
        return result.rows.length > 0;
    }

    // Get bill statistics
    static async getStatistics(options?: {
        bulan?: string;
        tahun?: number;
    }): Promise<{
        total_tagihan: number;
        total_lunas: number;
        total_belum_lunas: number;
        total_terlambat: number;
        total_pendapatan: number;
        total_tunggakan: number;
    }> {
        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options?.bulan) {
            whereClause += ` AND bulan = $${paramCount}`;
            values.push(options.bulan);
            paramCount++;
        }

        if (options?.tahun) {
            whereClause += ` AND tahun = $${paramCount}`;
            values.push(options.tahun);
            paramCount++;
        }

        const query = `
      SELECT 
        COUNT(*) as total_tagihan,
        COUNT(*) FILTER (WHERE status = 'lunas') as total_lunas,
        COUNT(*) FILTER (WHERE status = 'belum_lunas') as total_belum_lunas,
        COUNT(*) FILTER (WHERE status = 'terlambat') as total_terlambat,
        COALESCE(SUM(jumlah) FILTER (WHERE status = 'lunas'), 0) as total_pendapatan,
        COALESCE(SUM(jumlah + denda) FILTER (WHERE status IN ('belum_lunas', 'terlambat')), 0) as total_tunggakan
      FROM bills
      ${whereClause}
    `;

        const result = await pool.query(query, values);
        const stats = result.rows[0];

        return {
            total_tagihan: parseInt(stats.total_tagihan),
            total_lunas: parseInt(stats.total_lunas),
            total_belum_lunas: parseInt(stats.total_belum_lunas),
            total_terlambat: parseInt(stats.total_terlambat),
            total_pendapatan: parseFloat(stats.total_pendapatan),
            total_tunggakan: parseFloat(stats.total_tunggakan),
        };
    }

    // Update overdue bills to 'terlambat' status
    static async updateOverdueBills(): Promise<number> {
        const query = `
      UPDATE bills
      SET status = 'terlambat', updated_at = NOW()
      WHERE status = 'belum_lunas' 
        AND jatuh_tempo < CURRENT_DATE
      RETURNING id
    `;

        const result = await pool.query(query);
        return result.rowCount || 0;
    }

    // Generate bills for all active tenants
    static async generateMonthlyBills(bulan: string, tahun: number): Promise<Bill[]> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // Get all active tenants with contracts
            const getTenantsQuery = `
        SELECT DISTINCT ON (t.id)
          t.id as tenant_id,
          c.id as contract_id,
          c.harga_per_bulan as jumlah
        FROM tenants t
        JOIN contracts c ON t.id = c.tenant_id
        WHERE t.status = 'aktif' 
          AND c.status = 'aktif'
          AND t.kamar_id IS NOT NULL
        ORDER BY t.id, c.created_at DESC
      `;

            const tenantsResult = await client.query(getTenantsQuery);
            const tenants = tenantsResult.rows;

            const bills: Bill[] = [];

            // Calculate jatuh_tempo (10th of the month)
            const jatuhTempo = new Date(tahun, this.getMonthNumber(bulan) - 1, 10);

            for (const tenant of tenants) {
                // Check if bill already exists
                const checkQuery = `
          SELECT id FROM bills 
          WHERE tenant_id = $1 AND bulan = $2 AND tahun = $3
        `;
                const checkResult = await client.query(checkQuery, [tenant.tenant_id, bulan, tahun]);

                if (checkResult.rows.length === 0) {
                    // Create bill
                    const insertQuery = `
            INSERT INTO bills (
              tenant_id, contract_id, bulan, tahun, jumlah,
              status, jatuh_tempo, denda
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            RETURNING *
          `;

                    const insertValues = [
                        tenant.tenant_id,
                        tenant.contract_id,
                        bulan,
                        tahun,
                        tenant.jumlah,
                        'belum_lunas',
                        jatuhTempo,
                        0,
                    ];

                    const billResult = await client.query(insertQuery, insertValues);
                    bills.push(billResult.rows[0]);
                }
            }

            await client.query('COMMIT');
            return bills;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    // Helper: Convert month name to number
    private static getMonthNumber(bulan: string): number {
        const months: { [key: string]: number } = {
            'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4,
            'Mei': 5, 'Juni': 6, 'Juli': 7, 'Agustus': 8,
            'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
        };
        return months[bulan] || 1;
    }
}
