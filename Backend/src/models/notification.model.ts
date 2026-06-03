// ============================================
// NOTIFICATION MODEL - Database Operations
// ============================================

import { pool } from '../config/database';

export interface Notification {
  id: number;
  user_id: number;
  title: string;
  message: string;
  type: 'announcement' | 'payment' | 'bill' | 'maintenance' | 'system';
  related_id?: number;
  is_read: boolean;
  created_at: Date;
  updated_at: Date;
}

export class NotificationModel {
  // Create notification for specific user
  static async create(data: {
    user_id: number;
    title: string;
    message: string;
    type: 'announcement' | 'payment' | 'bill' | 'maintenance' | 'system';
    related_id?: number;
  }): Promise<Notification> {
    const query = `
      INSERT INTO notifications (user_id, title, message, type, related_id, is_read)
      VALUES ($1, $2, $3, $4, $5, false)
      RETURNING *
    `;

    const values = [
      data.user_id,
      data.title,
      data.message,
      data.type,
      data.related_id || null,
    ];

    const result = await pool.query(query, values);
    return result.rows[0];
  }

  // Create notifications for multiple users (broadcast)
  static async createForMultipleUsers(
    userIds: number[],
    data: {
      title: string;
      message: string;
      type: 'announcement' | 'payment' | 'bill' | 'maintenance' | 'system';
      related_id?: number;
    }
  ): Promise<void> {
    if (userIds.length === 0) return;

    const values: any[] = [];
    const valuePlaceholders: string[] = [];
    
    userIds.forEach((userId, index) => {
      const baseIndex = index * 5;
      valuePlaceholders.push(
        `($${baseIndex + 1}, $${baseIndex + 2}, $${baseIndex + 3}, $${baseIndex + 4}, $${baseIndex + 5}, false)`
      );
      values.push(
        userId,
        data.title,
        data.message,
        data.type,
        data.related_id || null
      );
    });

    const query = `
      INSERT INTO notifications (user_id, title, message, type, related_id, is_read)
      VALUES ${valuePlaceholders.join(', ')}
    `;

    await pool.query(query, values);
  }

  // Get notifications for user with pagination
  static async findByUserId(
    userId: number,
    options: {
      page?: number;
      limit?: number;
      is_read?: boolean;
      type?: string;
    }
  ): Promise<{ notifications: Notification[]; total: number }> {
    const page = options.page || 1;
    const limit = options.limit || 20;
    const offset = (page - 1) * limit;

    let whereClause = 'WHERE user_id = $1';
    const values: any[] = [userId];
    let paramCount = 2;

    if (options.is_read !== undefined) {
      whereClause += ` AND is_read = $${paramCount}`;
      values.push(options.is_read);
      paramCount++;
    }

    if (options.type) {
      whereClause += ` AND type = $${paramCount}`;
      values.push(options.type);
      paramCount++;
    }

    // Get total count
    const countQuery = `SELECT COUNT(*) FROM notifications ${whereClause}`;
    const countResult = await pool.query(countQuery, values);
    const total = parseInt(countResult.rows[0].count);

    // Get notifications
    const query = `
      SELECT *
      FROM notifications
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${paramCount} OFFSET $${paramCount + 1}
    `;

    values.push(limit, offset);
    const result = await pool.query(query, values);

    return { notifications: result.rows, total };
  }

  // Get unread count for user
  static async getUnreadCount(userId: number): Promise<number> {
    const query = `
      SELECT COUNT(*) 
      FROM notifications 
      WHERE user_id = $1 AND is_read = false
    `;
    const result = await pool.query(query, [userId]);
    return parseInt(result.rows[0].count);
  }

  // Mark notification as read
  static async markAsRead(id: number, userId: number): Promise<Notification | null> {
    const query = `
      UPDATE notifications
      SET is_read = true, updated_at = NOW()
      WHERE id = $1 AND user_id = $2
      RETURNING *
    `;

    const result = await pool.query(query, [id, userId]);
    return result.rows[0] || null;
  }

  // Mark all notifications as read for user
  static async markAllAsRead(userId: number): Promise<void> {
    const query = `
      UPDATE notifications
      SET is_read = true, updated_at = NOW()
      WHERE user_id = $1 AND is_read = false
    `;

    await pool.query(query, [userId]);
  }

  // Delete notification
  static async delete(id: number, userId: number): Promise<boolean> {
    const query = 'DELETE FROM notifications WHERE id = $1 AND user_id = $2';
    const result = await pool.query(query, [id, userId]);
    return result.rowCount ? result.rowCount > 0 : false;
  }

  // Get all tenant user IDs
  static async getAllTenantUserIds(): Promise<number[]> {
    const query = `
      SELECT id FROM users WHERE role = 'tenant'
    `;
    const result = await pool.query(query);
    return result.rows.map(row => row.id);
  }
}
