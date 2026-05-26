// ============================================
// MAINTENANCE MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Maintenance } from '../types';

export class MaintenanceModel {
    // Create new maintenance request
    static async create(data: {
        tenant_id: number;
        kamar_id: number;
        judul: string;
        deskripsi: string;
        kategori: string;
        prioritas?: 'rendah' | 'sedang' | 'tinggi' | 'urgent';
        foto?: string[];
    }): Promise<Maintenance> {
        const query = `
      INSERT INTO maintenance (
        tenant_id, kamar_id, judul, deskripsi, kategori,
        prioritas, status, foto, tanggal_lapor
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `;

        const values = [
            data.tenant_id,
            data.kamar_id,
            data.judul,
            data.deskripsi,
            data.kategori,
            data.prioritas || 'sedang',
            'baru',
            data.foto ? JSON.stringify(data.foto) : null,
            new Date(),
        ];

        const result = await pool.query(query, values);
        const maintenance = result.rows[0];

        // Parse JSON foto
        if (maintenance.foto) {
            maintenance.foto = JSON.parse(maintenance.foto);
        }

        return maintenance;
    }

    // Find maintenance by ID
    static async findById(id: number): Promise<Maintenance | null> {
        const query = `
      SELECT m.*, 
        t.nama as nama_tenant,
        t.email as tenant_email,
        t.no_telepon as tenant_phone,
        r.nomor_kamar,
        r.tipe as tipe_kamar
      FROM maintenance m
      JOIN tenants t ON m.tenant_id = t.id
      JOIN rooms r ON m.kamar_id = r.id
      WHERE m.id = $1
    `;
        const result = await pool.query(query, [id]);

        if (result.rows.length === 0) return null;

        const maintenance = result.rows[0];
        if (maintenance.foto) {
            maintenance.foto = JSON.parse(maintenance.foto);
        }

        return maintenance;
    }

    // Get all maintenance requests with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        tenant_id?: number;
        kamar_id?: number;
        status?: 'baru' | 'diproses' | 'selesai' | 'ditolak';
        prioritas?: 'rendah' | 'sedang' | 'tinggi' | 'urgent';
        kategori?: string;
        search?: string;
    }): Promise<{ maintenance: Maintenance[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.tenant_id) {
            whereClause += ` AND m.tenant_id = $${paramCount}`;
            values.push(options.tenant_id);
            paramCount++;
        }

        if (options.kamar_id) {
            whereClause += ` AND m.kamar_id = $${paramCount}`;
            values.push(options.kamar_id);
            paramCount++;
        }

        if (options.status) {
            whereClause += ` AND m.status = $${paramCount}`;
            values.push(options.status);
            paramCount++;
        }

        if (options.prioritas) {
            whereClause += ` AND m.prioritas = $${paramCount}`;
            values.push(options.prioritas);
            paramCount++;
        }

        if (options.kategori) {
            whereClause += ` AND m.kategori = $${paramCount}`;
            values.push(options.kategori);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (m.judul ILIKE $${paramCount} OR m.deskripsi ILIKE $${paramCount} OR t.nama ILIKE $${paramCount} OR r.nomor_kamar ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        // Get total count
        const countQuery = `
      SELECT COUNT(*) 
      FROM maintenance m
      JOIN tenants t ON m.tenant_id = t.id
      JOIN rooms r ON m.kamar_id = r.id
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get maintenance requests
        const query = `
      SELECT m.*, 
        t.nama as nama_tenant,
        t.email as tenant_email,
        r.nomor_kamar,
        r.tipe as tipe_kamar
      FROM maintenance m
      JOIN tenants t ON m.tenant_id = t.id
      JOIN rooms r ON m.kamar_id = r.id
      ${whereClause}
      ORDER BY 
        CASE m.prioritas
          WHEN 'urgent' THEN 1
          WHEN 'tinggi' THEN 2
          WHEN 'sedang' THEN 3
          WHEN 'rendah' THEN 4
        END,
        m.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        // Parse JSON foto for each maintenance
        const maintenance = result.rows.map(m => {
            if (m.foto) {
                m.foto = JSON.parse(m.foto);
            }
            return m;
        });

        return { maintenance, total };
    }

    // Update maintenance
    static async update(id: number, data: {
        judul?: string;
        deskripsi?: string;
        kategori?: string;
        prioritas?: 'rendah' | 'sedang' | 'tinggi' | 'urgent';
        status?: 'baru' | 'diproses' | 'selesai' | 'ditolak';
        foto?: string[];
        komentar_admin?: string;
        biaya?: number;
        tanggal_selesai?: Date;
    }): Promise<Maintenance | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.judul !== undefined) {
            updates.push(`judul = $${paramCount}`);
            values.push(data.judul);
            paramCount++;
        }

        if (data.deskripsi !== undefined) {
            updates.push(`deskripsi = $${paramCount}`);
            values.push(data.deskripsi);
            paramCount++;
        }

        if (data.kategori !== undefined) {
            updates.push(`kategori = $${paramCount}`);
            values.push(data.kategori);
            paramCount++;
        }

        if (data.prioritas !== undefined) {
            updates.push(`prioritas = $${paramCount}`);
            values.push(data.prioritas);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
            paramCount++;

            // If status is selesai, set tanggal_selesai
            if (data.status === 'selesai' && !data.tanggal_selesai) {
                updates.push(`tanggal_selesai = NOW()`);
            }
        }

        if (data.foto !== undefined) {
            updates.push(`foto = $${paramCount}`);
            values.push(JSON.stringify(data.foto));
            paramCount++;
        }

        if (data.komentar_admin !== undefined) {
            updates.push(`komentar_admin = $${paramCount}`);
            values.push(data.komentar_admin);
            paramCount++;
        }

        if (data.biaya !== undefined) {
            updates.push(`biaya = $${paramCount}`);
            values.push(data.biaya);
            paramCount++;
        }

        if (data.tanggal_selesai !== undefined) {
            updates.push(`tanggal_selesai = $${paramCount}`);
            values.push(data.tanggal_selesai);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE maintenance
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);

        if (result.rows.length === 0) return null;

        const maintenance = result.rows[0];
        if (maintenance.foto) {
            maintenance.foto = JSON.parse(maintenance.foto);
        }

        return maintenance;
    }

    // Delete maintenance
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM maintenance WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Get maintenance statistics
    static async getStatistics(): Promise<{
        total: number;
        baru: number;
        diproses: number;
        selesai: number;
        ditolak: number;
        urgent: number;
        tinggi: number;
        sedang: number;
        rendah: number;
    }> {
        const query = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'baru') as baru,
        COUNT(*) FILTER (WHERE status = 'diproses') as diproses,
        COUNT(*) FILTER (WHERE status = 'selesai') as selesai,
        COUNT(*) FILTER (WHERE status = 'ditolak') as ditolak,
        COUNT(*) FILTER (WHERE prioritas = 'urgent') as urgent,
        COUNT(*) FILTER (WHERE prioritas = 'tinggi') as tinggi,
        COUNT(*) FILTER (WHERE prioritas = 'sedang') as sedang,
        COUNT(*) FILTER (WHERE prioritas = 'rendah') as rendah
      FROM maintenance
    `;

        const result = await pool.query(query);
        const stats = result.rows[0];

        return {
            total: parseInt(stats.total),
            baru: parseInt(stats.baru),
            diproses: parseInt(stats.diproses),
            selesai: parseInt(stats.selesai),
            ditolak: parseInt(stats.ditolak),
            urgent: parseInt(stats.urgent),
            tinggi: parseInt(stats.tinggi),
            sedang: parseInt(stats.sedang),
            rendah: parseInt(stats.rendah),
        };
    }

    // Get urgent maintenance requests
    static async getUrgentRequests(): Promise<Maintenance[]> {
        const query = `
      SELECT m.*, 
        t.nama as nama_tenant,
        r.nomor_kamar
      FROM maintenance m
      JOIN tenants t ON m.tenant_id = t.id
      JOIN rooms r ON m.kamar_id = r.id
      WHERE m.prioritas IN ('urgent', 'tinggi')
        AND m.status IN ('baru', 'diproses')
      ORDER BY 
        CASE m.prioritas
          WHEN 'urgent' THEN 1
          WHEN 'tinggi' THEN 2
        END,
        m.created_at ASC
    `;

        const result = await pool.query(query);

        return result.rows.map(m => {
            if (m.foto) {
                m.foto = JSON.parse(m.foto);
            }
            return m;
        });
    }

    // Get maintenance by category
    static async getByCategory(): Promise<{ kategori: string; count: number }[]> {
        const query = `
      SELECT kategori, COUNT(*) as count
      FROM maintenance
      GROUP BY kategori
      ORDER BY count DESC
    `;

        const result = await pool.query(query);
        return result.rows.map(row => ({
            kategori: row.kategori,
            count: parseInt(row.count),
        }));
    }
}
