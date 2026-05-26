// ============================================
// USER MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { User } from '../types';
import bcrypt from 'bcryptjs';

export class UserModel {
    // Create new user
    static async create(data: {
        email: string;
        password: string;
        nama: string;
        role?: 'admin' | 'tenant';
        no_telepon?: string;
    }): Promise<User> {
        const hashedPassword = await bcrypt.hash(data.password, 10);

        const query = `
      INSERT INTO users (email, password, nama, role, no_telepon)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `;

        const values = [
            data.email,
            hashedPassword,
            data.nama,
            data.role || 'tenant',
            data.no_telepon || null,
        ];

        const result = await pool.query(query, values);
        return result.rows[0];
    }

    // Find user by email
    static async findByEmail(email: string): Promise<User | null> {
        const query = 'SELECT * FROM users WHERE email = $1';
        const result = await pool.query(query, [email]);
        return result.rows[0] || null;
    }

    // Find user by ID
    static async findById(id: number): Promise<User | null> {
        const query = 'SELECT * FROM users WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rows[0] || null;
    }

    // Get all users with pagination
    static async findAll(options: {
        page?: number;
        limit?: number;
        role?: 'admin' | 'tenant';
        search?: string;
    }): Promise<{ users: User[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.role) {
            whereClause += ` AND role = $${paramCount}`;
            values.push(options.role);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (nama ILIKE $${paramCount} OR email ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        // Get total count
        const countQuery = `SELECT COUNT(*) FROM users ${whereClause}`;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get users
        const query = `
      SELECT id, email, nama, role, no_telepon, foto, created_at, updated_at
      FROM users
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        return { users: result.rows, total };
    }

    // Update user
    static async update(id: number, data: {
        nama?: string;
        email?: string;
        no_telepon?: string;
        foto?: string;
        password?: string;
    }): Promise<User | null> {
        console.log('=== USER MODEL UPDATE ===');
        console.log('ID:', id);
        console.log('Data:', data);

        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

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

        if (data.foto !== undefined) {
            updates.push(`foto = $${paramCount}`);
            values.push(data.foto);
            paramCount++;
        }

        if (data.password) {
            const hashedPassword = await bcrypt.hash(data.password, 10);
            updates.push(`password = $${paramCount}`);
            values.push(hashedPassword);
            paramCount++;
        }

        if (updates.length === 0) {
            console.log('No updates to perform');
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE users
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        console.log('SQL Query:', query);
        console.log('SQL Values:', values);

        const result = await pool.query(query, values);

        console.log('Update result:', result.rows[0]);

        return result.rows[0] || null;
    }

    // Delete user
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM users WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Verify password
    static async verifyPassword(plainPassword: string, hashedPassword: string): Promise<boolean> {
        return bcrypt.compare(plainPassword, hashedPassword);
    }

    // Check if email exists
    static async emailExists(email: string, excludeId?: number): Promise<boolean> {
        let query = 'SELECT id FROM users WHERE email = $1';
        const values: any[] = [email];

        if (excludeId) {
            query += ' AND id != $2';
            values.push(excludeId);
        }

        const result = await pool.query(query, values);
        return result.rows.length > 0;
    }
}
