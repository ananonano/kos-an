import { Request, Response } from 'express';
import { RoomModel, TenantModel, BillModel, PaymentModel, MaintenanceModel } from '../models';

export class DashboardController {
  /**
   * Get dashboard overview for admin
   * Returns summary statistics for all entities
   */
  static async getAdminOverview(req: Request, res: Response) {
    try {
      const roomStats = await RoomModel.getStatistics();
      const tenantStats = await TenantModel.getStatistics();
      const billStats = await BillModel.getStatistics();
      const paymentStats = await PaymentModel.getStatistics();
      const maintenanceStats = await MaintenanceModel.getStatistics();

      const overview = {
        rooms: roomStats,
        tenants: tenantStats,
        bills: billStats,
        payments: paymentStats,
        maintenance: maintenanceStats
      };

      return res.json({
        success: true,
        data: overview
      });
    } catch (error) {
      console.error('Get admin overview error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get dashboard overview for tenant
   * Returns tenant-specific data
   */
  static async getTenantOverview(req: Request, res: Response) {
    try {
      const tenantId = parseInt(req.params.tenantId);

      const tenant = await TenantModel.findById(tenantId);
      if (!tenant) {
        return res.status(404).json({
          success: false,
          message: 'Tenant tidak ditemukan'
        });
      }

      const billsResult = await BillModel.findAll({
        tenant_id: tenantId,
        limit: 5
      });

      const paymentsResult = await PaymentModel.findAll({
        tenant_id: tenantId,
        limit: 5
      });

      const maintenanceResult = await MaintenanceModel.findAll({
        tenant_id: tenantId,
        limit: 5
      });

      const overview = {
        tenant,
        recent_bills: billsResult.bills,
        recent_payments: paymentsResult.payments,
        recent_maintenance: maintenanceResult.maintenance
      };

      return res.json({
        success: true,
        data: overview
      });
    } catch (error) {
      console.error('Get tenant overview error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get financial summary
   * Returns income, expenses, and revenue data
   */
  static async getFinancialSummary(req: Request, res: Response) {
    try {
      const { bulan, tahun } = req.query;

      const billStats = await BillModel.getStatistics({
        bulan: bulan as string,
        tahun: tahun ? parseInt(tahun as string) : undefined
      });

      const paymentStats = await PaymentModel.getStatistics({
        bulan: bulan as string,
        tahun: tahun ? parseInt(tahun as string) : undefined
      });

      const summary = {
        total_pendapatan: paymentStats.total_amount,
        total_tagihan: billStats.total_pendapatan,
        total_tunggakan: billStats.total_tunggakan,
        tagihan_lunas: billStats.total_lunas,
        tagihan_belum_lunas: billStats.total_belum_lunas,
        tagihan_terlambat: billStats.total_terlambat,
        pembayaran_verified: paymentStats.total_verified,
        pembayaran_pending: paymentStats.total_pending,
        pembayaran_rejected: paymentStats.total_rejected
      };

      return res.json({
        success: true,
        data: summary
      });
    } catch (error) {
      console.error('Get financial summary error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get recent activities
   * Returns latest bills, payments, and maintenance requests
   */
  static async getRecentActivities(req: Request, res: Response) {
    try {
      const limit = req.query.limit ? parseInt(req.query.limit as string) : 10;

      const billsResult = await BillModel.findAll({ limit });
      const paymentsResult = await PaymentModel.findAll({ limit });
      const maintenanceResult = await MaintenanceModel.findAll({ limit });

      const activities = {
        recent_bills: billsResult.bills,
        recent_payments: paymentsResult.payments,
        recent_maintenance: maintenanceResult.maintenance
      };

      return res.json({
        success: true,
        data: activities
      });
    } catch (error) {
      console.error('Get recent activities error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get pending tasks
   * Returns items that need admin attention
   */
  static async getPendingTasks(req: Request, res: Response) {
    try {
      const pendingPayments = await PaymentModel.getPendingPayments();
      const urgentMaintenance = await MaintenanceModel.getUrgentRequests();

      const tasks = {
        pending_payments: pendingPayments,
        urgent_maintenance: urgentMaintenance,
        total_pending: pendingPayments.length + urgentMaintenance.length
      };

      return res.json({
        success: true,
        data: tasks
      });
    } catch (error) {
      console.error('Get pending tasks error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
