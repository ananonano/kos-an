// ============================================
// ROOM MODEL - Database Operations
// ============================================

import { pool } from '../config/database';
import { Room } from '../types';

export class RoomModel {
    // Create new room
    static async create(data: {
        nomor_kamar: string;
        tipe: string;
        harga: number;
        deskripsi?: string;
        fasilitas?: string[];
        foto?: string;
    }): Promise<Room> {
        const query = `
      INSERT INTO rooms (nomor_kamar, tipe, harga, status, deskripsi, fasilitas, foto)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

        const values = [
            data.nomor_kamar,
            data.tipe,
            data.harga,
            'kosong',
            data.deskripsi || null,
            data.fasilitas ? JSON.stringify(data.fasilitas) : null,
            data.foto || null,
        ];

        const result = await pool.query(query, values);
        const room = result.rows[0];

        // Parse JSON fasilitas
        if (room.fasilitas) {
            room.fasilitas = JSON.parse(room.fasilitas);
        }

        return room;
    }

    // Find room by ID
    static async findById(id: number): Promise<Room | null> {
        const query = 'SELECT * FROM rooms WHERE id = $1';
        const result = await pool.query(query, [id]);

        if (result.rows.length === 0) return null;

        const room = result.rows[0];
        if (room.fasilitas) {
            try {
                if (typeof room.fasilitas === 'string') {
                    room.fasilitas = JSON.parse(room.fasilitas);
                }
                if (!Array.isArray(room.fasilitas)) {
                    room.fasilitas = [];
                }
            } catch (error) {
                console.error('Error parsing fasilitas for room', room.id, error);
                room.fasilitas = [];
            }
        } else {
            room.fasilitas = [];
        }

        return room;
    }

    // Find room by nomor_kamar
    static async findByNomorKamar(nomorKamar: string): Promise<Room | null> {
        const query = 'SELECT * FROM rooms WHERE nomor_kamar = $1';
        const result = await pool.query(query, [nomorKamar]);

        if (result.rows.length === 0) return null;

        const room = result.rows[0];
        if (room.fasilitas) {
            room.fasilitas = JSON.parse(room.fasilitas);
        }

        return room;
    }

    // Get all rooms with pagination and filters
    static async findAll(options: {
        page?: number;
        limit?: number;
        status?: 'kosong' | 'terisi';
        tipe?: string;
        search?: string;
        minHarga?: number;
        maxHarga?: number;
    }): Promise<{ rooms: Room[]; total: number }> {
        const page = options.page || 1;
        const limit = options.limit || 20;
        const offset = (page - 1) * limit;

        let whereClause = 'WHERE 1=1';
        const values: any[] = [];
        let paramCount = 1;

        if (options.status) {
            whereClause += ` AND status = $${paramCount}`;
            values.push(options.status);
            paramCount++;
        }

        if (options.tipe) {
            whereClause += ` AND tipe = $${paramCount}`;
            values.push(options.tipe);
            paramCount++;
        }

        if (options.search) {
            whereClause += ` AND (nomor_kamar ILIKE $${paramCount} OR deskripsi ILIKE $${paramCount})`;
            values.push(`%${options.search}%`);
            paramCount++;
        }

        if (options.minHarga !== undefined) {
            whereClause += ` AND harga >= $${paramCount}`;
            values.push(options.minHarga);
            paramCount++;
        }

        if (options.maxHarga !== undefined) {
            whereClause += ` AND harga <= $${paramCount}`;
            values.push(options.maxHarga);
            paramCount++;
        }

        // Get total count
        const countQuery = `SELECT COUNT(*) FROM rooms ${whereClause}`;
        const countResult = await pool.query(countQuery, values);
        const total = parseInt(countResult.rows[0].count);

        // Get rooms
        const query = `
      SELECT * FROM rooms
      ${whereClause}
      ORDER BY nomor_kamar ASC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

        values.push(limit, offset);
        const result = await pool.query(query, values);

        // Parse JSON fasilitas for each room
        const rooms = result.rows.map(room => {
            if (room.fasilitas) {
                try {
                    // If it's already an object/array (JSONB), keep it
                    if (typeof room.fasilitas === 'string') {
                        room.fasilitas = JSON.parse(room.fasilitas);
                    }
                    // Ensure it's an array
                    if (!Array.isArray(room.fasilitas)) {
                        room.fasilitas = [];
                    }
                } catch (error) {
                    console.error('Error parsing fasilitas for room', room.id, error);
                    room.fasilitas = [];
                }
            } else {
                room.fasilitas = [];
            }
            return room;
        });

        return { rooms, total };
    }

    // Update room
    static async update(id: number, data: {
        nomor_kamar?: string;
        tipe?: string;
        harga?: number;
        status?: 'kosong' | 'terisi';
        deskripsi?: string;
        fasilitas?: string[];
        foto?: string;
    }): Promise<Room | null> {
        const updates: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (data.nomor_kamar !== undefined) {
            updates.push(`nomor_kamar = $${paramCount}`);
            values.push(data.nomor_kamar);
            paramCount++;
        }

        if (data.tipe !== undefined) {
            updates.push(`tipe = $${paramCount}`);
            values.push(data.tipe);
            paramCount++;
        }

        if (data.harga !== undefined) {
            updates.push(`harga = $${paramCount}`);
            values.push(data.harga);
            paramCount++;
        }

        if (data.status !== undefined) {
            updates.push(`status = $${paramCount}`);
            values.push(data.status);
            paramCount++;
        }

        if (data.deskripsi !== undefined) {
            updates.push(`deskripsi = $${paramCount}`);
            values.push(data.deskripsi);
            paramCount++;
        }

        if (data.fasilitas !== undefined) {
            updates.push(`fasilitas = $${paramCount}`);
            values.push(JSON.stringify(data.fasilitas));
            paramCount++;
        }

        if (data.foto !== undefined) {
            updates.push(`foto = $${paramCount}`);
            values.push(data.foto);
            paramCount++;
        }

        if (updates.length === 0) {
            return this.findById(id);
        }

        updates.push(`updated_at = NOW()`);
        values.push(id);

        const query = `
      UPDATE rooms
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

        const result = await pool.query(query, values);

        if (result.rows.length === 0) return null;

        const room = result.rows[0];
        if (room.fasilitas) {
            room.fasilitas = JSON.parse(room.fasilitas);
        }

        return room;
    }

    // Delete room
    static async delete(id: number): Promise<boolean> {
        const query = 'DELETE FROM rooms WHERE id = $1';
        const result = await pool.query(query, [id]);
        return result.rowCount ? result.rowCount > 0 : false;
    }

    // Check if nomor_kamar exists
    static async nomorKamarExists(nomorKamar: string, excludeId?: number): Promise<boolean> {
        let query = 'SELECT id FROM rooms WHERE nomor_kamar = $1';
        const values: any[] = [nomorKamar];

        if (excludeId) {
            query += ' AND id != $2';
            values.push(excludeId);
        }

        const result = await pool.query(query, values);
        return result.rows.length > 0;
    }

    // Get room statistics
    static async getStatistics(): Promise<{
        total: number;
        kosong: number;
        terisi: number;
        tingkat_okupansi: number;
    }> {
        const query = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'kosong') as kosong,
        COUNT(*) FILTER (WHERE status = 'terisi') as terisi
      FROM rooms
    `;

        const result = await pool.query(query);
        const stats = result.rows[0];

        const total = parseInt(stats.total);
        const kosong = parseInt(stats.kosong);
        const terisi = parseInt(stats.terisi);
        const tingkat_okupansi = total > 0 ? (terisi / total) * 100 : 0;

        return { total, kosong, terisi, tingkat_okupansi };
    }

    // Get available rooms (kosong)
    static async getAvailableRooms(): Promise<Room[]> {
        const query = `
      SELECT * FROM rooms
      WHERE status = 'kosong'
      ORDER BY nomor_kamar ASC
    `;

        const result = await pool.query(query);

        return result.rows.map(room => {
            if (room.fasilitas) {
                room.fasilitas = JSON.parse(room.fasilitas);
            }
            return room;
        });
    }
}
