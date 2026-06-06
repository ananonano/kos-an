import { Request, Response } from 'express';
import { MaintenanceModel, NotificationModel } from '../models';

export class MaintenanceController {
  /**
   * Get all maintenance requests with pagination and filters
   * Query params: page, limit, tenant_id, kamar_id, status, prioritas, kategori, search
   * AUTOMATIC FILTERING: If user is tenant, only return their maintenance
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, tenant_id, kamar_id, status, prioritas, kategori, search } = req.query;
      const user = (req as any).user; // From auth middleware

      let finalTenantId = tenant_id ? parseInt(tenant_id as string) : undefined;

      // 🔒 AUTO-FILTER: If user is tenant, override tenant_id with their own
      if (user && user.role === 'tenant') {
        // Get tenant_id from tenants table based on user_id
        const { pool } = await import('../config/database');
        const tenantResult = await pool.query(
          'SELECT id FROM tenants WHERE user_id = $1 LIMIT 1',
          [user.id]
        );
        
        if (tenantResult.rows.length > 0) {
          finalTenantId = tenantResult.rows[0].id;
          console.log(`🔒 [MaintenanceController] Auto-filtering for tenant user_id=${user.id} → tenant_id=${finalTenantId}`);
        } else {
          console.warn(`⚠️ [MaintenanceController] Tenant user_id=${user.id} not found in tenants table`);
          // Return empty result if tenant not found
          return res.json({
            success: true,
            data: [],
            pagination: {
              page: parseInt(page as string) || 1,
              limit: parseInt(limit as string) || 20,
              total: 0,
              totalPages: 0
            }
          });
        }
      }

      const result = await MaintenanceModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        tenant_id: finalTenantId,
        kamar_id: kamar_id ? parseInt(kamar_id as string) : undefined,
        status: status as any,
        prioritas: prioritas as any,
        kategori: kategori as string,
        search: search as string
      });

      return res.json({
        success: true,
        data: result.maintenance,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get maintenance request by ID
   * Returns single maintenance with tenant and room details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const maintenance = await MaintenanceModel.findById(parseInt(id));
      if (!maintenance) {
        return res.status(404).json({
          success: false,
          message: 'Laporan maintenance tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: maintenance
      });
    } catch (error) {
      console.error('GetById maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new maintenance request
   * Tenant submits complaint with photos
   */
  static async create(req: Request, res: Response) {
    try {
      const { tenant_id, kamar_id, judul, deskripsi, kategori, prioritas, foto } = req.body;

      if (!tenant_id || !kamar_id || !judul || !deskripsi || !kategori) {
        return res.status(400).json({
          success: false,
          message: 'Tenant ID, kamar ID, judul, deskripsi, dan kategori harus diisi'
        });
      }

      const maintenance = await MaintenanceModel.create({
        tenant_id: parseInt(tenant_id),
        kamar_id: parseInt(kamar_id),
        judul,
        deskripsi,
        kategori,
        prioritas,
        foto
      });

      // 🔔 Create notification for all ADMIN users
      const { pool } = await import('../config/database');
      
      // Get tenant name and room number
      const tenantResult = await pool.query(
        `SELECT t.nama, r.nomor_kamar 
         FROM tenants t 
         LEFT JOIN rooms r ON t.kamar_id = r.id 
         WHERE t.id = $1`,
        [tenant_id]
      );

      // Get all admin users
      const adminResult = await pool.query(
        "SELECT id FROM users WHERE role = 'admin'"
      );

      if (tenantResult.rows.length > 0 && adminResult.rows.length > 0) {
        const tenantName = tenantResult.rows[0].nama;
        const nomorKamar = tenantResult.rows[0].nomor_kamar || 'N/A';
        
        const priorityLabel = prioritas === 'urgent' ? '[URGENT]' : prioritas === 'tinggi' ? 'Tinggi' : prioritas === 'sedang' ? 'Sedang' : 'Rendah';

        // Create notification for each admin
        for (const admin of adminResult.rows) {
          await NotificationModel.create({
            user_id: admin.id,
            title: `Keluhan Baru: ${judul}`,
            message: `${tenantName} (Kamar ${nomorKamar}) melaporkan keluhan ${kategori}. Prioritas: ${priorityLabel}`,
            type: 'maintenance',
            related_id: maintenance.id
          });
        }

        console.log(`🔔 Created maintenance notifications for ${adminResult.rows.length} admin(s): ${judul}`);
      }

      return res.status(201).json({
        success: true,
        message: 'Laporan maintenance berhasil dibuat',
        data: maintenance
      });
    } catch (error) {
      console.error('Create maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update maintenance request by ID
   * Admin can update status, priority, comments, cost
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { judul, deskripsi, kategori, prioritas, status, foto, komentar_admin, biaya, tanggal_selesai } = req.body;

      const existingMaintenance = await MaintenanceModel.findById(parseInt(id));
      if (!existingMaintenance) {
        return res.status(404).json({
          success: false,
          message: 'Laporan maintenance tidak ditemukan'
        });
      }

      const oldStatus = existingMaintenance.status;
      const maintenance = await MaintenanceModel.update(parseInt(id), {
        judul,
        deskripsi,
        kategori,
        prioritas,
        status,
        foto,
        komentar_admin,
        biaya: biaya ? parseFloat(biaya) : undefined,
        tanggal_selesai: tanggal_selesai ? new Date(tanggal_selesai) : undefined
      });

      // 🔔 Create notification if status changed
      if (status && status !== oldStatus) {
        const { pool } = await import('../config/database');
        
        // Get tenant's user_id
        const tenantResult = await pool.query(
          'SELECT user_id FROM tenants WHERE id = $1',
          [existingMaintenance.tenant_id]
        );

        if (tenantResult.rows.length > 0) {
          const userId = tenantResult.rows[0].user_id;
          
          // Create status message
          let statusMessage = '';
          switch (status) {
            case 'baru':
              statusMessage = 'Laporan keluhan Anda telah diterima dan menunggu diproses';
              break;
            case 'diproses':
              statusMessage = 'Laporan keluhan Anda sedang diproses oleh admin';
              break;
            case 'selesai':
              statusMessage = 'Laporan keluhan Anda telah selesai ditangani';
              break;
            default:
              statusMessage = `Status laporan keluhan Anda diupdate: ${status}`;
          }

          // Create notification
          await NotificationModel.create({
            user_id: userId,
            title: `Keluhan: ${existingMaintenance.judul}`,
            message: statusMessage,
            type: 'maintenance',
            related_id: parseInt(id)
          });

          console.log(`🔔 Created maintenance notification for user_id=${userId}, status=${status}`);
        }
      }

      return res.json({
        success: true,
        message: 'Laporan maintenance berhasil diupdate',
        data: maintenance
      });
    } catch (error) {
      console.error('Update maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update maintenance status
   * Admin updates status: baru -> diproses -> selesai
   */
  static async updateStatus(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { status, komentar_admin, biaya } = req.body;

      if (!status) {
        return res.status(400).json({
          success: false,
          message: 'Status harus diisi'
        });
      }

      const existingMaintenance = await MaintenanceModel.findById(parseInt(id));
      if (!existingMaintenance) {
        return res.status(404).json({
          success: false,
          message: 'Laporan maintenance tidak ditemukan'
        });
      }

      const oldStatus = existingMaintenance.status;
      const maintenance = await MaintenanceModel.update(parseInt(id), {
        status,
        komentar_admin,
        biaya: biaya ? parseFloat(biaya) : undefined
      });

      // 🔔 Create notification if status changed
      if (status !== oldStatus) {
        const { pool } = await import('../config/database');
        
        // Get tenant's user_id
        const tenantResult = await pool.query(
          'SELECT user_id FROM tenants WHERE id = $1',
          [existingMaintenance.tenant_id]
        );

        if (tenantResult.rows.length > 0) {
          const userId = tenantResult.rows[0].user_id;
          
          // Create status message
          let statusMessage = '';
          switch (status) {
            case 'baru':
              statusMessage = 'Laporan keluhan Anda telah diterima dan menunggu diproses';
              break;
            case 'diproses':
              statusMessage = 'Laporan keluhan Anda sedang diproses oleh admin';
              break;
            case 'selesai':
              statusMessage = 'Laporan keluhan Anda telah selesai ditangani';
              break;
            default:
              statusMessage = `Status laporan keluhan Anda diupdate: ${status}`;
          }

          // Create notification
          await NotificationModel.create({
            user_id: userId,
            title: `Keluhan: ${existingMaintenance.judul}`,
            message: statusMessage,
            type: 'maintenance',
            related_id: parseInt(id)
          });

          console.log(`🔔 Created maintenance notification for user_id=${userId}, status=${status}`);
        }
      }

      return res.json({
        success: true,
        message: `Status berhasil diupdate ke ${status}`,
        data: maintenance
      });
    } catch (error) {
      console.error('Update status error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete maintenance request by ID
   * Admin only
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const maintenance = await MaintenanceModel.findById(parseInt(id));
      if (!maintenance) {
        return res.status(404).json({
          success: false,
          message: 'Laporan maintenance tidak ditemukan'
        });
      }

      await MaintenanceModel.delete(parseInt(id));

      return res.json({
        success: true,
        message: 'Laporan maintenance berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get maintenance statistics
   * Returns counts by status and priority
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const stats = await MaintenanceModel.getStatistics();

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
   * Get urgent maintenance requests
   * Returns maintenance with urgent or high priority
   */
  static async getUrgent(req: Request, res: Response) {
    try {
      const maintenance = await MaintenanceModel.getUrgentRequests();

      return res.json({
        success: true,
        data: maintenance
      });
    } catch (error) {
      console.error('Get urgent maintenance error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get maintenance by category
   * Returns count of maintenance grouped by category
   */
  static async getByCategory(req: Request, res: Response) {
    try {
      const categories = await MaintenanceModel.getByCategory();

      return res.json({
        success: true,
        data: categories
      });
    } catch (error) {
      console.error('Get by category error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
