import { Request, Response } from 'express';
import { BillModel } from '../models';

export class BillController {
  /**
   * Get all bills with pagination and filters
   * Query params: page, limit, tenant_id, status, bulan, tahun, search
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, tenant_id, status, bulan, tahun, search } = req.query;

      const result = await BillModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        tenant_id: tenant_id ? parseInt(tenant_id as string) : undefined,
        status: status as any,
        bulan: bulan as string,
        tahun: tahun ? parseInt(tahun as string) : undefined,
        search: search as string
      });

      return res.json({
        success: true,
        data: result.bills,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error) {
      console.error('GetAll bills error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get bill by ID
   * Returns single bill with tenant and room details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const bill = await BillModel.findById(parseInt(id));
      if (!bill) {
        return res.status(404).json({
          success: false,
          message: 'Tagihan tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: bill
      });
    } catch (error) {
      console.error('GetById bill error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new bill
   * Admin only
   */
  static async create(req: Request, res: Response) {
    try {
      const { tenant_id, contract_id, bulan, tahun, jumlah, jatuh_tempo, denda, catatan } = req.body;

      if (!tenant_id || !contract_id || !bulan || !tahun || !jumlah || !jatuh_tempo) {
        return res.status(400).json({
          success: false,
          message: 'Tenant ID, contract ID, bulan, tahun, jumlah, dan jatuh tempo harus diisi'
        });
      }

      const exists = await BillModel.existsForTenantMonth(
        parseInt(tenant_id),
        bulan,
        parseInt(tahun)
      );

      if (exists) {
        return res.status(400).json({
          success: false,
          message: 'Tagihan untuk tenant ini di bulan dan tahun tersebut sudah ada'
        });
      }

      const bill = await BillModel.create({
        tenant_id: parseInt(tenant_id),
        contract_id: parseInt(contract_id),
        bulan,
        tahun: parseInt(tahun),
        jumlah: parseFloat(jumlah),
        jatuh_tempo: new Date(jatuh_tempo),
        denda: denda ? parseFloat(denda) : undefined,
        catatan
      });

      return res.status(201).json({
        success: true,
        message: 'Tagihan berhasil dibuat',
        data: bill
      });
    } catch (error) {
      console.error('Create bill error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update bill by ID
   * Admin only
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { jumlah, status, jatuh_tempo, denda, catatan } = req.body;

      const existingBill = await BillModel.findById(parseInt(id));
      if (!existingBill) {
        return res.status(404).json({
          success: false,
          message: 'Tagihan tidak ditemukan'
        });
      }

      const bill = await BillModel.update(parseInt(id), {
        jumlah: jumlah ? parseFloat(jumlah) : undefined,
        status,
        jatuh_tempo: jatuh_tempo ? new Date(jatuh_tempo) : undefined,
        denda: denda !== undefined ? parseFloat(denda) : undefined,
        catatan
      });

      return res.json({
        success: true,
        message: 'Tagihan berhasil diupdate',
        data: bill
      });
    } catch (error) {
      console.error('Update bill error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Delete bill by ID
   * Admin only
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const bill = await BillModel.findById(parseInt(id));
      if (!bill) {
        return res.status(404).json({
          success: false,
          message: 'Tagihan tidak ditemukan'
        });
      }

      await BillModel.delete(parseInt(id));

      return res.json({
        success: true,
        message: 'Tagihan berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete bill error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get bill statistics
   * Query params: bulan, tahun
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const { bulan, tahun } = req.query;

      const stats = await BillModel.getStatistics({
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
   * Update overdue bills to terlambat status
   * Admin only - typically run as cron job
   */
  static async updateOverdue(req: Request, res: Response) {
    try {
      const count = await BillModel.updateOverdueBills();

      return res.json({
        success: true,
        message: `${count} tagihan berhasil diupdate ke status terlambat`,
        data: { updated_count: count }
      });
    } catch (error) {
      console.error('Update overdue error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Generate monthly bills for all active tenants
   * Admin only
   */
  static async generateMonthly(req: Request, res: Response) {
    try {
      const { bulan, tahun } = req.body;

      if (!bulan || !tahun) {
        return res.status(400).json({
          success: false,
          message: 'Bulan dan tahun harus diisi'
        });
      }

      const bills = await BillModel.generateMonthlyBills(bulan, parseInt(tahun));

      return res.status(201).json({
        success: true,
        message: `${bills.length} tagihan berhasil dibuat`,
        data: bills
      });
    } catch (error) {
      console.error('Generate monthly bills error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
