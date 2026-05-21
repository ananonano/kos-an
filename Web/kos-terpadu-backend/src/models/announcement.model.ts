// ============================================
// ANNOUNCEMENT MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Announcement } from '../types';

export class AnnouncementModel {
    // Create new announcement
    static async create(data: {
        judul: string;
        konten: string;
        kategori: string;
        prioritas?: 'info' | 'penting' | 'urgent';
        target?: 'semua' | 'tenant' | 'admin';
        created_by: number;
    }): Promise<Announcement> {
        const query = `
      INSERT INTO announcements (
        judul, konten, kategori, prioritas, target, created_by, is_active
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

        const values = [
            data.judul,
            data.konten,
            data.kategori,
            data.prioritas || 'info',
            data.target || 'semua',
            data.created_by,
            true,
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find announcement by ID
    static async findById(id: number): Promise<Announcement | null> {
        const query = `
      SELECT a.*, 
        u.nama as created_by_name,
        u.email as created_by_email
      FROM announcements a
      JOIN users u ON a.created_by = u.id
      WHERE a.id = $1
    `;
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Get all announcements with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        kategori?: string;
        prioritas?: 'info' | 'penting' | 'urgent';
        target?: 'semua' | 'tenant' | 'admin';
        is_active?: boolean;
        search?: string;
    }): Promise<{ announcements: Announcement[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.kategori) {
            whereClause += ` AND a.kategori = $${paramCount}`;
            values.push(options.kategori);
            paramCount++;
        }

        if (options.prioritas) {
            whereClause += ` AND a.prioritas = $${paramCount}`;
            values.push(options.prioritas);
            paramCount++;
        }

        if (options.target) {
            whereClause += ` AND a.target = $${paramCount}`;
            values.push(options.target);
            paramCount++;
        }

        if (options.is_active !== undefined) {
            whereClause += ` AND a.is_active = $${paramCount}`;
            values.push(options.is_active);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (a.judul ILIKE $${paramCount} OR a.konten ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        // Get total count
        const countQuery = `
      SELECT COUNT(*) 
      FROM announcements a
      ${whereClause}
    `;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get announcements
        const query = `
      SELECT a.*, 
        u.nama as created_by_name
      FROM announcements a
      JOIN users u ON a.created_by = u.id
      ${whereClause}
      ORDER BY 
        CASE a.prioritas
          WHEN 'urgent' THEN 1
          WHEN 'penting' THEN 2
          WHEN 'info' THEN 3
        END,
        a.created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { announcements: result.rows, total };
    }

    // Get active announcements for specific target
    static async getActiveByTarget(target: 'semua' | 'tenant' | 'admin'): Promise<Announcement[]> {
        const query = `
      SELECT a.*, 
        u.nama as created_by_name
      FROM announcements a
      JOIN users u ON a.created_by = u.id
      WHERE a.is_active = true 
        AND (a.target = $1 OR a.target = 'semua')
      ORDER BY 
        CASE a.prioritas
          WHEN 'urgent' THEN 1
          WHEN 'penting' THEN 2
          WHEN 'info' THEN 3
        END,
        a.created_at DESC
    `;

        const result = await pool.query(query, [target]);
        return result.rows;
    }

    // Update announcement
    static async update(id: number, data: {
        judul?: string;
        konten?: string;
        kategori?: string;
        prioritas?: 'info' | 'penting' | 'urgent';
        target?: 'semua' | 'tenant' | 'admin';
        is_active?: boolean;
    }): Promise<Announcement | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.judul !== undefined) {
            updates.push(`judul = $${paramCount}`);
            values.push(data.judul);
            paramCount++;
        }

        if (data.konten !== undefined) {
            updates.push(`konten = $${paramCount}`);
            values.push(data.konten);
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

        if (data.target !== undefined) {
            updates.push(`target = $${paramCount}`);
            values.push(data.target);
            paramCount++;
        }

        if (data.is_active !== undefined) {
            updates.push(`is_active = $${paramCount}`);
            values.push(data.is_active);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE announcements
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);
        return result.rows[0] || null;
    }

    // Delete announcement
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM announcements WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Deactivate announcement
    static async deactivate(id: number): Promise<Announcement | null> {
        const query = `
      UPDATE announcements
      SET is_active = false, updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `;

        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Activate announcement
    static async activate(id: number): Promise<Announcement | null> {
        const query = `
      UPDATE announcements
      SET is_active = true, updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `;

        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Get announcement statistics
    static async getStatistics(): Promise<{
        total: number;
        active: number;
        inactive: number;
        urgent: number;
        penting: number;
        info: number;
    }> {
        const query = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE is_active = true) as active,
        COUNT(*) FILTER (WHERE is_active = false) as inactive,
        COUNT(*) FILTER (WHERE prioritas = 'urgent') as urgent,
        COUNT(*) FILTER (WHERE prioritas = 'penting') as penting,
        COUNT(*) FILTER (WHERE prioritas = 'info') as info
      FROM announcements
    `;

        const result = await pool.query(query);
        const stats = result.rows[0];

        return {
            total: parseInt(stats.total),
            active: parseInt(stats.active),
            inactive: parseInt(stats.inactive),
            urgent: parseInt(stats.urgent),
            penting: parseInt(stats.penting),
            info: parseInt(stats.info),
        };
    }
}
