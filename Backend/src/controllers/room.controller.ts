import { Request, Response } from 'express';
import { RoomModel } from '../models';

export class RoomController {
  /**
   * Get all rooms with pagination and filters
   * Query params: page, limit, status, search
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, status, search } = req.query;

      console.log('Fetching rooms with params:', { page, limit, status, search });

      const result = await RoomModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        status: status as any,
        search: search as string
      });

      console.log(`Found ${result.total} rooms`);

      return res.json({
        success: true,
        data: result.rooms,
        pagination: {
          page: parseInt(page as string) || 1,
          limit: parseInt(limit as string) || 20,
          total: result.total,
          totalPages: Math.ceil(result.total / (parseInt(limit as string) || 20))
        }
      });
    } catch (error: any) {
      console.error('GetAll rooms error:', error);
      console.error('Error stack:', error.stack);
      return res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * Get room by ID
   * Returns single room with details
   */
  static async getById(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const room = await RoomModel.findById(parseInt(id));
      if (!room) {
        return res.status(404).json({
          success: false,
          message: 'Kamar tidak ditemukan'
        });
      }

      return res.json({
        success: true,
        data: room
      });
    } catch (error) {
      console.error('GetById room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Create new room
   * Admin only
   */
  static async create(req: Request, res: Response) {
    try {
      const { nomor_kamar, tipe, harga, status, deskripsi, fasilitas, foto } = req.body;

      if (!nomor_kamar || !tipe || !harga) {
        return res.status(400).json({
          success: false,
          message: 'Nomor kamar, tipe, dan harga harus diisi'
        });
      }

      const exists = await RoomModel.nomorKamarExists(nomor_kamar);
      if (exists) {
        return res.status(400).json({
          success: false,
          message: 'Nomor kamar sudah ada'
        });
      }

      const room = await RoomModel.create({
        nomor_kamar,
        tipe,
        harga: parseFloat(harga),
        status: status || 'kosong',
        deskripsi,
        fasilitas,
        foto
      });

      return res.status(201).json({
        success: true,
        message: 'Kamar berhasil ditambahkan',
        data: room
      });
    } catch (error) {
      console.error('Create room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Update room by ID
   * Admin only
   */
  static async update(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { nomor_kamar, tipe, harga, status, deskripsi, fasilitas, foto } = req.body;

      console.log('=== UPDATE ROOM REQUEST ===');
      console.log('Room ID:', id);
      console.log('Request body:', req.body);

      const existingRoom = await RoomModel.findById(parseInt(id));
      if (!existingRoom) {
        return res.status(404).json({
          success: false,
          message: 'Kamar tidak ditemukan'
        });
      }

      console.log('Existing room:', existingRoom);

      if (nomor_kamar) {
        const exists = await RoomModel.nomorKamarExists(nomor_kamar, parseInt(id));
        if (exists) {
          return res.status(400).json({
            success: false,
            message: 'Nomor kamar sudah ada'
          });
        }
      }

      const updateData: any = {};
      if (nomor_kamar !== undefined) updateData.nomor_kamar = nomor_kamar;
      if (tipe !== undefined) updateData.tipe = tipe;
      if (harga !== undefined) updateData.harga = parseFloat(harga);
      if (status !== undefined) updateData.status = status;
      if (deskripsi !== undefined) updateData.deskripsi = deskripsi;
      if (fasilitas !== undefined) updateData.fasilitas = fasilitas;
      if (foto !== undefined) updateData.foto = foto;

      console.log('Update data:', updateData);

      const room = await RoomModel.update(parseInt(id), updateData);

      console.log('Updated room:', room);

      return res.json({
        success: true,
        message: 'Kamar berhasil diupdate',
        data: room
      });
    } catch (error: any) {
      console.error('Update room error:', error);
      console.error('Error stack:', error.stack);
      return res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  /**
   * Delete room by ID
   * Admin only
   */
  static async delete(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const room = await RoomModel.findById(parseInt(id));
      if (!room) {
        return res.status(404).json({
          success: false,
          message: 'Kamar tidak ditemukan'
        });
      }

      await RoomModel.delete(parseInt(id));

      return res.json({
        success: true,
        message: 'Kamar berhasil dihapus'
      });
    } catch (error) {
      console.error('Delete room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get room statistics
   * Returns total, kosong, terisi, and occupancy rate
   */
  static async getStatistics(req: Request, res: Response) {
    try {
      const stats = await RoomModel.getStatistics();

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
