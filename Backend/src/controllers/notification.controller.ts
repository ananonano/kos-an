import { Request, Response } from 'express';
import { NotificationModel } from '../models/notification.model';

export class NotificationController {
  /**
   * Get all notifications for current user
   * Query params: page, limit, is_read, type
   */
  static async getAll(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;
      const { page, limit, is_read, type } = req.query;

      const result = await NotificationModel.findByUserId(userId, {
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        is_read: is_read === 'true' ? true : is_read === 'false' ? false : undefined,
        type: type as string,
      });

      return res.json({
        success: true,
        data: result.notifications,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll notifications error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get unread notification count for current user
   */
  static async getUnreadCount(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;

      const count = await NotificationModel.getUnreadCount(userId);

      return res.json({
        success: true,
        data: { unread_count: count }
      });
    } catch (error) {
      console.error('Get unread count error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Mark notification as read
   */
  static async markAsRead(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const userId = (req as any).user.id;

      const notification = await NotificationModel.markAsRead(parseInt(id), userId);

      if (!notification) {
        return res.status(404).json({
          success: false,
          message: 'Notifikasi tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        message: 'Notifikasi ditandai telah dibaca',
        data: notification
      });
    } catch (error) {
      console.error('Mark as read error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Mark all notifications as read for current user
   */
  static async markAllAsRead(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;

      await NotificationModel.markAllAsRead(userId);

      return res.json({
        success: true,
        message: 'Semua notifikasi ditandai telah dibaca'
      });
    } catch (error) {
      console.error('Mark all as read error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete notification
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const userId = (req as any).user.id;

      const success = await NotificationModel.delete(parseInt(id), userId);

      if (!success) {
        return res.status(404).json({
          success: false,
          message: 'Notifikasi tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        message: 'Notifikasi berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete notification error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
