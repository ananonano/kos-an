// ============================================
// TENANT MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Tenant } from '../types';

export class TenantModel {
    // Create new tenant
    static async create(data: {
        user_id: number;
        kamar_id?: number;
        nama: string;
        email: string;
        no_telepon: string;
        alamat_asal?: string;
        pekerjaan?: string;
        kontak_darurat?: string;
        tanggal_masuk?: Date;
    }): Promise<Tenant> {
        const query = `
      INSERT INTO tenants (
        user_id, kamar_id, nama, email, no_telepon,
        alamat_asal, pekerjaan, kontak_darurat, tanggal_masuk, status
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *
    `;

        const values = [
            data.user_id,
            data.kamar_id || null,
            data.nama,
            data.email,
            data.no_telepon,
            data.alamat_asal || null,
            data.pekerjaan || null,
            data.kontak_darurat || null,
            data.tanggal_masuk || new Date(),
            'aktif',
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find tenant by ID
    static async findById(id: number): Promise<Tenant | null> {
        const query = `
      SELECT t.*, r.nomor_kamar, u.email as user_email
      FROM tenants t
      LEFT JOIN rooms r ON t.kamar_id = r.id
      LEFT JOIN users u ON t.user_id = u.id
      WHERE t.id = $1
    `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Find tenant by user_id
    static async findByUserId(userId: number): Promise<Tenant | null> {
        const query = `
      SELECT t.*, r.nomor_kamar
      FROM tenants t
      LEFT JOIN rooms r ON t.kamar_id = r.id
      WHERE t.user_id = $1
    `;
        const result = await pool.query(query, [userId]);
        return result.rows[0] || null;
    }

    // Find tenant by kamar_id
    static async findByKamarId(kamarId: number): Promise<Tenant | null> {
        const query = `
      SELECT t.*, r.nomor_kamar
      FROM tenants t
      LEFT JOIN rooms r ON t.kamar_id = r.id
      WHERE t.kamar_id = $1 AND t.status = 'aktif'
    `;
        const result = await pool.query(query, [kamarId]);
        return result.rows[0] || null;
    }

    // Get all tenants with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        status?: 'aktif' | 'tidak_aktif';
        kamar_id?: number;
        search?: string;
    }): Promise<{ tenants: Tenant[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.status) {
            whereClause += ` AND t.status = $${paramCount}`;
            values.push(options.status);
            paramCount++;
        }

        if (options.kamar_id) {
            whereClause += ` AND t.kamar_id = $${paramCount}`;
            values.push(options.kamar_id);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (t.nama ILIKE $${paramCount} OR t.email ILIKE $${paramCount} OR r.nomor_kamar ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        // Get total count
        const countQuery = `
      SELECT COUNT(*) 
      FROM tenants t
      LEFT JOIN rooms r ON t.kamar_id = r.id
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get tenants
        const query = `
      SELECT t.*, r.nomor_kamar, r.tipe as tipe_kamar, r.harga as harga_kamar
      FROM tenants t
      LEFT JOIN rooms r ON t.kamar_id = r.id
      ${whereClause}
      ORDER BY t.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { tenants: result.rows, total };
    }

    // Update tenant
    static async update(id: number, data: {
        kamar_id?: number | null;
        nama?: string;
        email?: string;
        no_telepon?: string;
        alamat_asal?: string;
        pekerjaan?: string;
        kontak_darurat?: string;
        tanggal_masuk?: Date;
        tanggal_keluar?: Date | null;
        status?: 'aktif' | 'tidak_aktif';
    }): Promise<Tenant | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.kamar_id !== undefined) {
            updates.push(`kamar_id = $${paramCount}`);
            values.push(data.kamar_id);
            paramCount++;
        }

        if (data.nama !== undefined) {
            updates.push(`nama = $${paramCount}`);
            values.push(data.nama);
            paramCount++;
        }

        if (data.email !== undefined) {
            updates.push(`email = $${paramCount}`);
            values.push(data.email);
            paramCount++;
        }

        if (data.no_telepon !== undefined) {
            updates.push(`no_telepon = $${paramCount}`);
            values.push(data.no_telepon);
            paramCount++;
        }

        if (data.alamat_asal !== undefined) {
            updates.push(`alamat_asal = $${paramCount}`);
            values.push(data.alamat_asal);
            paramCount++;
        }

        if (data.pekerjaan !== undefined) {
            updates.push(`pekerjaan = $${paramCount}`);
            values.push(data.pekerjaan);
            paramCount++;
        }

        if (data.kontak_darurat !== undefined) {
            updates.push(`kontak_darurat = $${paramCount}`);
            values.push(data.kontak_darurat);
            paramCount++;
        }

        if (data.tanggal_masuk !== undefined) {
            updates.push(`tanggal_masuk = $${paramCount}`);
            values.push(data.tanggal_masuk);
            paramCount++;
        }

        if (data.tanggal_keluar !== undefined) {
            updates.push(`tanggal_keluar = $${paramCount}`);
            values.push(data.tanggal_keluar);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE tenants
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);
        return result.rows[0] || null;
    }

    // Delete tenant
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM tenants WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Get tenant statistics
    static async getStatistics(): Promise<{
        total: number;
        aktif: number;
        tidak_aktif: number;
    }> {
        const query = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'aktif') as aktif,
        COUNT(*) FILTER (WHERE status = 'tidak_aktif') as tidak_aktif
      FROM tenants
    `;

        const result = await pool.query(query);
        const stats = result.rows[0];

        return {
            total: parseInt(stats.total),
            aktif: parseInt(stats.aktif),
            tidak_aktif: parseInt(stats.tidak_aktif),
        };
    }

    // Assign tenant to room
    static async assignToRoom(tenantId: number, kamarId: number): Promise<Tenant | null> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // Update tenant
            const updateTenantQuery = `
        UPDATE tenants
        SET kamar_id = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING *
      `;
            const tenantResult = await client.query(updateTenantQuery, [kamarId, tenantId]);

            // Update room status to terisi
            const updateRoomQuery = `
        UPDATE rooms
        SET status = 'terisi', updated_at = NOW()
        WHERE id = $1
      `;
            await client.query(updateRoomQuery, [kamarId]);

            await client.query('COMMIT');
            return tenantResult.rows[0];
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    // Remove tenant from room
    static async removeFromRoom(tenantId: number): Promise<Tenant | null> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            // Get current kamar_id
            const getTenantQuery = 'SELECT kamar_id FROM tenants WHERE id = $1';
            const tenantResult = await client.query(getTenantQuery, [tenantId]);
            const kamarId = tenantResult.rows[0]?.kamar_id;

            // Update tenant
            const updateTenantQuery = `
        UPDATE tenants
        SET kamar_id = NULL, status = 'tidak_aktif', tanggal_keluar = NOW(), updated_at = NOW()
        WHERE id = $1
        RETURNING *
      `;
            const updatedTenant = await client.query(updateTenantQuery, [tenantId]);

            // Update room status to kosong if there was a room
            if (kamarId) {
                const updateRoomQuery = `
          UPDATE rooms
          SET status = 'kosong', updated_at = NOW()
          WHERE id = $1
        `;
                await client.query(updateRoomQuery, [kamarId]);
            }

            await client.query('COMMIT');
            return updatedTenant.rows[0];
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }
}
