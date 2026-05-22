import { Request, Response } from 'express';
import { AnnouncementModel } from '../models';

export class AnnouncementController {
  /**
   * Get all announcements with pagination and filters
   * Query params: page, limit, kategori, prioritas, target, is_active, search
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, kategori, prioritas, target, is_active, search } = req.query;

      const result = await AnnouncementModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        kategori: kategori as string,
        prioritas: prioritas as any,
        target: target as any,
        is_active: is_active === 'true' ? true : is_active === 'false' ? false : undefined,
        search: search as string
      });

      return res.json({
        success: true,
        data: result.announcements,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll announcements error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get announcement by ID
   * Returns single announcement with creator details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const announcement = await AnnouncementModel.findById(parseInt(id));
      if (!announcement) {
        return res.status(404).json({
          success: false,
          message: 'Pengumuman tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: announcement
      });
    } catch (error) {
      console.error('GetById announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get active announcements by target
   * Returns announcements for specific user role
   */
  static async getActiveByTarget(req: Request, res: Response) {
    try {
      const { target } = req.params;

      if (!['semua', 'tenant', 'admin'].includes(target)) {
        return res.status(400).json({
          success: false,
          message: 'Target harus semua, tenant, atau admin'
        });
      }

      const announcements = await AnnouncementModel.getActiveByTarget(target as any);

      return res.json({
        success: true,
        data: announcements
      });
    } catch (error) {
      console.error('Get active by target error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new announcement
   * Admin only
   */
  static async create(req: Request, res: Response) {
    try {
      const { judul, konten, kategori, prioritas, target } = req.body;
      const createdBy = (req as any).user.id;

      if (!judul || !konten || !kategori) {
        return res.status(400).json({
          success: false,
          message: 'Judul, konten, dan kategori harus diisi'
        });
      }

      const announcement = await AnnouncementModel.create({
        judul,
        konten,
        kategori,
        prioritas,
        target,
        created_by: createdBy
      });

      return res.status(201).json({
        success: true,
        message: 'Pengumuman berhasil dibuat',
        data: announcement
      });
    } catch (error) {
      console.error('Create announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update announcement by ID
   * Admin only
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { judul, konten, kategori, prioritas, target, is_active } = req.body;

      const existingAnnouncement = await AnnouncementModel.findById(parseInt(id));
      if (!existingAnnouncement) {
        return res.status(404).json({
          success: false,
          message: 'Pengumuman tidak ditemukan'
        });
      }

      const announcement = await AnnouncementModel.update(parseInt(id), {
        judul,
        konten,
        kategori,
        prioritas,
        target,
        is_active
      });

      return res.json({
        success: true,
        message: 'Pengumuman berhasil diupdate',
        data: announcement
      });
    } catch (error) {
      console.error('Update announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete announcement by ID
   * Admin only
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const announcement = await AnnouncementModel.findById(parseInt(id));
      if (!announcement) {
        return res.status(404).json({
          success: false,
          message: 'Pengumuman tidak ditemukan'
        });
      }

      await AnnouncementModel.delete(parseInt(id));

      return res.json({
        success: true,
        message: 'Pengumuman berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Deactivate announcement
   * Admin only - sets is_active to false
   */
  static async deactivate(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const existingAnnouncement = await AnnouncementModel.findById(parseInt(id));
      if (!existingAnnouncement) {
        return res.status(404).json({
          success: false,
          message: 'Pengumuman tidak ditemukan'
        });
      }

      const announcement = await AnnouncementModel.deactivate(parseInt(id));

      return res.json({
        success: true,
        message: 'Pengumuman berhasil dinonaktifkan',
        data: announcement
      });
    } catch (error) {
      console.error('Deactivate announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Activate announcement
   * Admin only - sets is_active to true
   */
  static async activate(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const existingAnnouncement = await AnnouncementModel.findById(parseInt(id));
      if (!existingAnnouncement) {
        return res.status(404).json({
          success: false,
          message: 'Pengumuman tidak ditemukan'
        });
      }

      const announcement = await AnnouncementModel.activate(parseInt(id));

      return res.json({
        success: true,
        message: 'Pengumuman berhasil diaktifkan',
        data: announcement
      });
    } catch (error) {
      console.error('Activate announcement error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get announcement statistics
   * Returns counts by status and priority
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const stats = await AnnouncementModel.getStatistics();

      return res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Get statistics error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
