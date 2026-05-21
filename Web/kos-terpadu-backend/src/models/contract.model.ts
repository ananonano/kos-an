// ============================================
// CONTRACT MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Contract } from '../types';

export class ContractModel {
    // Create new contract
    static async create(data: {
        tenant_id: number;
        kamar_id: number;
        tanggal_mulai: Date;
        tanggal_selesai?: Date;
        harga_per_bulan: number;
        deposit: number;
        catatan?: string;
    }): Promise<Contract> {
        const query = `
      INSERT INTO contracts (
        tenant_id, kamar_id, tanggal_mulai, tanggal_selesai,
        harga_per_bulan, deposit, status, catatan
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `;

        const values = [
            data.tenant_id,
            data.kamar_id,
            data.tanggal_mulai,
            data.tanggal_selesai || null,
            data.harga_per_bulan,
            data.deposit,
            'aktif',
            data.catatan || null,
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find contract by ID
    static async findById(id: number): Promise<Contract | null> {
        const query = `
      SELECT c.*, 
        t.nama as tenant_name,
        t.email as tenant_email,
        r.nomor_kamar,
        r.tipe as tipe_kamar
      FROM contracts c
      JOIN tenants t ON c.tenant_id = t.id
      JOIN rooms r ON c.kamar_id = r.id
      WHERE c.id = $1
    `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Find active contract by tenant_id
    static async findActiveByTenantId(tenantId: number): Promise<Contract | null> {
        const query = `
      SELECT c.*, 
        t.nama as tenant_name,
        r.nomor_kamar
      FROM contracts c
      JOIN tenants t ON c.tenant_id = t.id
      JOIN rooms r ON c.kamar_id = r.id
      WHERE c.tenant_id = $1 AND c.status = 'aktif'
      ORDER BY c.created_at DESC
      LIMIT 1
    `;
        const result = await pool.query(query, [tenantId]);
        return result.rows[0] || null;
    }

    // Find active contract by kamar_id
    static async findActiveByKamarId(kamarId: number): Promise<Contract | null> {
        const query = `
      SELECT c.*, 
        t.nama as tenant_name,
        t.email as tenant_email
      FROM contracts c
      JOIN tenants t ON c.tenant_id = t.id
      WHERE c.kamar_id = $1 AND c.status = 'aktif'
      ORDER BY c.created_at DESC
      LIMIT 1
    `;
        const result = await pool.query(query, [kamarId]);
        return result.rows[0] || null;
    }

    // Get all contracts with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        tenant_id?: number;
        kamar_id?: number;
        status?: 'aktif' | 'selesai' | 'dibatalkan';
        search?: string;
    }): Promise<{ contracts: Contract[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.tenant_id) {
            whereClause += ` AND c.tenant_id = $${paramCount}`;
            values.push(options.tenant_id);
            paramCount++;
        }

        if (options.kamar_id) {
            whereClause += ` AND c.kamar_id = $${paramCount}`;
            values.push(options.kamar_id);
            paramCount++;
        }

        if (options.status) {
            whereClause += ` AND c.status = $${paramCount}`;
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
      FROM contracts c
      JOIN tenants t ON c.tenant_id = t.id
      JOIN rooms r ON c.kamar_id = r.id
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get contracts
        const query = `
      SELECT c.*, 
        t.nama as tenant_name,
        t.email as tenant_email,
        r.nomor_kamar,
        r.tipe as tipe_kamar
      FROM contracts c
      JOIN tenants t ON c.tenant_id = t.id
      JOIN rooms r ON c.kamar_id = r.id
      ${whereClause}
      ORDER BY c.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { contracts: result.rows, total };
    }

    // Update contract
    static async update(id: number, data: {
        tanggal_mulai?: Date;
        tanggal_selesai?: Date | null;
        harga_per_bulan?: number;
        deposit?: number;
        status?: 'aktif' | 'selesai' | 'dibatalkan';
        catatan?: string;
    }): Promise<Contract | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.tanggal_mulai !== undefined) {
            updates.push(`tanggal_mulai = $${paramCount}`);
            values.push(data.tanggal_mulai);
            paramCount++;
        }

        if (data.tanggal_selesai !== undefined) {
            updates.push(`tanggal_selesai = $${paramCount}`);
            values.push(data.tanggal_selesai);
            paramCount++;
        }

        if (data.harga_per_bulan !== undefined) {
            updates.push(`harga_per_bulan = $${paramCount}`);
            values.push(data.harga_per_bulan);
            paramCount++;
        }

        if (data.deposit !== undefined) {
            updates.push(`deposit = $${paramCount}`);
            values.push(data.deposit);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
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
      UPDATE contracts
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);
        return result.rows[0] || null;
    }

    // Delete contract
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM contracts WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // End contract (set status to selesai)
    static async endContract(id: number, tanggalSelesai?: Date): Promise<Contract | null> {
        const query = `
      UPDATE contracts
      SET status = 'selesai',
          tanggal_selesai = $1,
          updated_at = NOW()
      WHERE id = $2
      RETURNING *
    `;

        const result = await pool.query(query, [tanggalSelesai || new Date(), id]);
        return result.rows[0] || null;
    }

    // Cancel contract
    static async cancelContract(id: number, catatan?: string): Promise<Contract | null> {
        const query = `
      UPDATE contracts
      SET status = 'dibatalkan',
          catatan = $1,
          updated_at = NOW()
      WHERE id = $2
      RETURNING *
    `;

        const result = await pool.query(query, [catatan || 'Kontrak dibatalkan', id]);
        return result.rows[0] || null;
    }

    // Get contract statistics
    static async getStatistics(): Promise<{
        total: number;
        aktif: number;
        selesai: number;
        dibatalkan: number;
    }> {
        const query = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'aktif') as aktif,
        COUNT(*) FILTER (WHERE status = 'selesai') as selesai,
        COUNT(*) FILTER (WHERE status = 'dibatalkan') as dibatalkan
      FROM contracts
    `;

        const result = await pool.query(query);
        const stats = result.rows[0];

        return {
            total: parseInt(stats.total),
            aktif: parseInt(stats.aktif),
            selesai: parseInt(stats.selesai),
            dibatalkan: parseInt(stats.dibatalkan),
        };
    }

    // Check if tenant has active contract
    static async hasActiveContract(tenantId: number): Promise<boolean> {
        const query = `
      SELECT id FROM contracts 
      WHERE tenant_id = $1 AND status = 'aktif'
      LIMIT 1
    `;
        const result = await pool.query(query, [tenantId]);
        return result.rows.length > 0;
    }

    // Check if room has active contract
    static async roomHasActiveContract(kamarId: number): Promise<boolean> {
        const query = `
      SELECT id FROM contracts 
      WHERE kamar_id = $1 AND status = 'aktif'
      LIMIT 1
    `;
        const result = await pool.query(query, [kamarId]);
        return result.rows.length > 0;
    }
}
