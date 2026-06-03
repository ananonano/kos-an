import { Request, Response } from 'express';
import { TenantModel, UserModel } from '../models';

export class TenantController {
  /**
   * Get all tenants with pagination and filters
   * Query params: page, limit, status, kamar_id, search
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, status, kamar_id, search } = req.query;

      const result = await TenantModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        status: status as any,
        kamar_id: kamar_id ? parseInt(kamar_id as string) : undefined,
        search: search as string
      });

      return res.json({
        success: true,
        data: result.tenants,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll tenants error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get tenant by ID
   * Returns single tenant with details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const tenant = await TenantModel.findById(parseInt(id));
      if (!tenant) {
        return res.status(404).json({
          success: false,
          message: 'Penyewa tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: tenant
      });
    } catch (error) {
      console.error('GetById tenant error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new tenant
   * Admin only
   */
  static async create(req: Request, res: Response) {
    try {
      const {
        user_id,
        kamar_id,
        nama,
        email,
        no_telepon,
        alamat_asal,
        pekerjaan,
        kontak_darurat,
        tanggal_masuk
      } = req.body;

      if (!user_id || !nama || !email || !no_telepon) {
        return res.status(400).json({
          success: false,
          message: 'User ID, nama, email, dan no telepon harus diisi'
        });
      }

      const tenant = await TenantModel.create({
        user_id,
        kamar_id,
        nama,
        email,
        no_telepon,
        alamat_asal,
        pekerjaan,
        kontak_darurat,
        tanggal_masuk: tanggal_masuk ? new Date(tanggal_masuk) : undefined
      });

      return res.status(201).json({
        success: true,
        message: 'Penyewa berhasil ditambahkan',
        data: tenant
      });
    } catch (error) {
      console.error('Create tenant error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update tenant by ID
   * Admin only
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const {
        kamar_id,
        nama,
        email,
        no_telepon,
        alamat_asal,
        pekerjaan,
        kontak_darurat,
        tanggal_masuk,
        tanggal_keluar,
        status
      } = req.body;

      const existingTenant = await TenantModel.findById(parseInt(id));
      if (!existingTenant) {
        return res.status(404).json({
          success: false,
          message: 'Penyewa tidak ditemukan'
        });
      }

      const tenant = await TenantModel.update(parseInt(id), {
        kamar_id,
        nama,
        email,
        no_telepon,
        alamat_asal,
        pekerjaan,
        kontak_darurat,
        tanggal_masuk: tanggal_masuk ? new Date(tanggal_masuk) : undefined,
        tanggal_keluar: tanggal_keluar ? new Date(tanggal_keluar) : undefined,
        status
      });

      return res.json({
        success: true,
        message: 'Penyewa berhasil diupdate',
        data: tenant
      });
    } catch (error) {
      console.error('Update tenant error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete tenant by ID
   * Admin only
   * Also deletes the associated user account (cascade delete)
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const tenant = await TenantModel.findById(parseInt(id));
      if (!tenant) {
        return res.status(404).json({
          success: false,
          message: 'Penyewa tidak ditemukan'
        });
      }

      // Delete tenant first
      await TenantModel.delete(parseInt(id));

      // Then delete associated user account
      if (tenant.user_id) {
        await UserModel.delete(tenant.user_id);
      }

      return res.json({
        success: true,
        message: 'Penyewa dan akun user berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete tenant error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Assign tenant to room
   * Admin only
   */
  static async assignToRoom(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { kamar_id } = req.body;

      if (!kamar_id) {
        return res.status(400).json({
          success: false,
          message: 'Kamar ID harus diisi'
        });
      }

      const tenant = await TenantModel.assignToRoom(parseInt(id), kamar_id);

      return res.json({
        success: true,
        message: 'Penyewa berhasil di-assign ke kamar',
        data: tenant
      });
    } catch (error) {
      console.error('Assign to room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Remove tenant from room
   * Admin only
   */
  static async removeFromRoom(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const tenant = await TenantModel.removeFromRoom(parseInt(id));

      return res.json({
        success: true,
        message: 'Penyewa berhasil dikeluarkan dari kamar',
        data: tenant
      });
    } catch (error) {
      console.error('Remove from room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get tenant statistics
   * Returns total, aktif, and tidak_aktif counts
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const stats = await TenantModel.getStatistics();

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

  /**
   * Get tenant by user_id
   * Returns tenant data for logged in user
   */
  static async getByUserId(req: Request, res: Response) {
    try {
      const { userId } = req.params;

      const tenant = await TenantModel.findByUserId(parseInt(userId));
      if (!tenant) {
        return res.status(404).json({
          success: false,
          message: 'Data tenant tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: tenant
      });
    } catch (error) {
      console.error('GetByUserId tenant error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
