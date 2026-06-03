import { Request, Response } from 'express';
import { PaymentModel } from '../models';

export class PaymentController {
  /**
   * Get all payments with pagination and filters
   * Query params: page, limit, tenant_id, bill_id, status, search
   * AUTOMATIC FILTERING: If user is tenant, only return their payments
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, tenant_id, bill_id, status, search } = req.query;
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
          console.log(`🔒 [PaymentController] Auto-filtering for tenant user_id=${user.id} → tenant_id=${finalTenantId}`);
        } else {
          console.warn(`⚠️ [PaymentController] Tenant user_id=${user.id} not found in tenants table`);
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

      const result = await PaymentModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        tenant_id: finalTenantId,
        bill_id: bill_id ? parseInt(bill_id as string) : undefined,
        status: status as any,
        search: search as string
      });

      return res.json({
        success: true,
        data: result.payments,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll payments error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get payment by ID
   * Returns single payment with tenant, bill, and room details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const payment = await PaymentModel.findById(parseInt(id));
      if (!payment) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: payment
      });
    } catch (error) {
      console.error('GetById payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new payment
   * Tenant submits payment proof
   */
  static async create(req: Request, res: Response) {
    try {
      const { bill_id, tenant_id, jumlah, tanggal_bayar, metode_pembayaran, bukti_pembayaran, keterangan } = req.body;

      if (!bill_id || !tenant_id || !jumlah || !tanggal_bayar || !metode_pembayaran) {
        return res.status(400).json({
          success: false,
          message: 'Bill ID, tenant ID, jumlah, tanggal bayar, dan metode pembayaran harus diisi'
        });
      }

      const payment = await PaymentModel.create({
        bill_id: parseInt(bill_id),
        tenant_id: parseInt(tenant_id),
        jumlah: parseFloat(jumlah),
        tanggal_bayar: new Date(tanggal_bayar),
        metode_pembayaran,
        bukti_pembayaran,
        keterangan
      });

      return res.status(201).json({
        success: true,
        message: 'Pembayaran berhasil disubmit, menunggu verifikasi',
        data: payment
      });
    } catch (error) {
      console.error('Create payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update payment by ID
   * Tenant can update before verification
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { jumlah, tanggal_bayar, metode_pembayaran, bukti_pembayaran, keterangan } = req.body;

      const existingPayment = await PaymentModel.findById(parseInt(id));
      if (!existingPayment) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      if (existingPayment.status !== 'menunggu_verifikasi') {
        return res.status(400).json({
          success: false,
          message: 'Pembayaran sudah diverifikasi, tidak bisa diupdate'
        });
      }

      const payment = await PaymentModel.update(parseInt(id), {
        jumlah: jumlah ? parseFloat(jumlah) : undefined,
        tanggal_bayar: tanggal_bayar ? new Date(tanggal_bayar) : undefined,
        metode_pembayaran,
        bukti_pembayaran,
        keterangan
      });

      return res.json({
        success: true,
        message: 'Pembayaran berhasil diupdate',
        data: payment
      });
    } catch (error) {
      console.error('Update payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete payment by ID
   * Admin only or tenant before verification
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const payment = await PaymentModel.findById(parseInt(id));
      if (!payment) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      await PaymentModel.delete(parseInt(id));

      return res.json({
        success: true,
        message: 'Pembayaran berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Verify payment (approve)
   * Admin only - updates payment and bill status to lunas
   */
  static async verify(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { keterangan } = req.body;
      const verifiedBy = (req as any).user.id;

      const existingPayment = await PaymentModel.findById(parseInt(id));
      if (!existingPayment) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      if (existingPayment.status !== 'menunggu_verifikasi') {
        return res.status(400).json({
          success: false,
          message: 'Pembayaran sudah diverifikasi sebelumnya'
        });
      }

      const payment = await PaymentModel.verify(parseInt(id), verifiedBy, keterangan);

      // 🔔 Create notification for tenant
      const { NotificationModel } = await import('../models');
      const { pool } = await import('../config/database');
      
      // Get tenant's user_id
      const tenantResult = await pool.query(
        'SELECT user_id FROM tenants WHERE id = $1',
        [existingPayment.tenant_id]
      );

      if (tenantResult.rows.length > 0) {
        const userId = tenantResult.rows[0].user_id;
        const formattedAmount = new Intl.NumberFormat('id-ID', {
          style: 'currency',
          currency: 'IDR',
          minimumFractionDigits: 0
        }).format(existingPayment.jumlah);

        await NotificationModel.create({
          user_id: userId,
          type: 'payment',
          title: 'Pembayaran Diverifikasi',
          message: `Pembayaran Anda sebesar ${formattedAmount} telah diverifikasi oleh admin.`,
          related_id: parseInt(id)
        });
        console.log(`✅ [PaymentController] Notification created for payment verified: user_id=${userId}`);
      }

      return res.json({
        success: true,
        message: 'Pembayaran berhasil diverifikasi',
        data: payment
      });
    } catch (error) {
      console.error('Verify payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Reject payment
   * Admin only - rejects payment with reason
   */
  static async reject(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { keterangan } = req.body;
      const verifiedBy = (req as any).user.id;

      if (!keterangan) {
        return res.status(400).json({
          success: false,
          message: 'Keterangan penolakan harus diisi'
        });
      }

      const existingPayment = await PaymentModel.findById(parseInt(id));
      if (!existingPayment) {
        return res.status(404).json({
          success: false,
          message: 'Pembayaran tidak ditemukan'
        });
      }

      if (existingPayment.status !== 'menunggu_verifikasi') {
        return res.status(400).json({
          success: false,
          message: 'Pembayaran sudah diverifikasi sebelumnya'
        });
      }

      const payment = await PaymentModel.reject(parseInt(id), verifiedBy, keterangan);

      // 🔔 Create notification for tenant
      const { NotificationModel } = await import('../models');
      const { pool } = await import('../config/database');
      
      // Get tenant's user_id
      const tenantResult = await pool.query(
        'SELECT user_id FROM tenants WHERE id = $1',
        [existingPayment.tenant_id]
      );

      if (tenantResult.rows.length > 0) {
        const userId = tenantResult.rows[0].user_id;
        const formattedAmount = new Intl.NumberFormat('id-ID', {
          style: 'currency',
          currency: 'IDR',
          minimumFractionDigits: 0
        }).format(existingPayment.jumlah);

        await NotificationModel.create({
          user_id: userId,
          type: 'payment',
          title: 'Pembayaran Ditolak',
          message: `Pembayaran sebesar ${formattedAmount} ditolak. Alasan: ${keterangan}`,
          related_id: parseInt(id)
        });
        console.log(`✅ [PaymentController] Notification created for payment rejected: user_id=${userId}`);
      }

      return res.json({
        success: true,
        message: 'Pembayaran ditolak',
        data: payment
      });
    } catch (error) {
      console.error('Reject payment error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get payment statistics
   * Query params: bulan, tahun
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const { bulan, tahun } = req.query;

      const stats = await PaymentModel.getStatistics({
        bulan: bulan as string,
        tahun: tahun ? parseInt(tahun as string) : undefined
      });

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
   * Get pending payments
   * Admin only - returns all payments waiting for verification
   */
  static async getPending(req: Request, res: Response) {
    try {
      const payments = await PaymentModel.getPendingPayments();

      return res.json({
        success: true,
        data: payments
      });
    } catch (error) {
      console.error('Get pending payments error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
