import { Request, Response } from 'express';
import { RoomModel } from '../models';

// Transform database room to frontend format
const transformRoomToFrontend = (room: any) => {
  // Handle fasilitas - could be JSONB object, JSON string, or array
  let facilities = [];
  try {
    if (Array.isArray(room.fasilitas)) {
      facilities = room.fasilitas;
    } else if (typeof room.fasilitas === 'string') {
      facilities = JSON.parse(room.fasilitas);
    } else if (room.fasilitas && typeof room.fasilitas === 'object') {
      // JSONB returns as object, convert to array if needed
      facilities = Array.isArray(room.fasilitas) ? room.fasilitas : Object.values(room.fasilitas);
    }
  } catch (error) {
    console.error('Error parsing fasilitas:', error);
    facilities = [];
  }

  return {
    id: room.id.toString(),
    roomNumber: room.nomor_kamar || '',
    type: room.tipe || '',
    price: parseFloat(room.harga) || 0,
    status: room.status === 'kosong' ? 'available' : room.status === 'terisi' ? 'occupied' : 'maintenance',
    description: room.deskripsi || '',
    facilities: facilities,
    images: room.foto ? [room.foto] : [],
    createdAt: room.created_at,
    updatedAt: room.updated_at,
  };
};

// Transform frontend data to database format
const transformRoomToDatabase = (data: any) => {
  const dbData: any = {};

  if (data.roomNumber !== undefined) dbData.nomor_kamar = data.roomNumber;
  if (data.type !== undefined) dbData.tipe = data.type;
  if (data.price !== undefined) dbData.harga = parseFloat(data.price);
  if (data.status !== undefined) {
    dbData.status = data.status === 'available' ? 'kosong' : data.status === 'occupied' ? 'terisi' : 'kosong';
  }
  if (data.description !== undefined) dbData.deskripsi = data.description;
  if (data.facilities !== undefined) dbData.fasilitas = data.facilities;
  if (data.images !== undefined && data.images.length > 0) dbData.foto = data.images[0];

  return dbData;
};

export class RoomController {
  /**
   * Get all rooms with pagination and filters
   * Query params: page, limit, status, search
   */
  static async getAll(req: Request, res: Response) {
    try {
      const { page, limit, status, search } = req.query;

      // Transform frontend status to database status
      let dbStatus = status as string;
      if (status === 'available') dbStatus = 'kosong';
      else if (status === 'occupied') dbStatus = 'terisi';

      console.log('Fetching rooms with params:', { page, limit, status: dbStatus, search });

      const result = await RoomModel.findAll({
        page: page ? parseInt(page as string) : 1,
        limit: limit ? parseInt(limit as string) : 20,
        status: dbStatus as any,
        search: search as string
      });

      console.log(`Found ${result.total} rooms, transforming...`);

      // Transform rooms to frontend format
      const transformedRooms = result.rooms.map(transformRoomToFrontend);

      console.log('Transformation successful, returning data');

      return res.json({
        success: true,
        data: transformedRooms,
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
        data: transformRoomToFrontend(room)
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
      // Transform frontend data to database format
      const dbData = transformRoomToDatabase(req.body);

      if (!dbData.nomor_kamar || !dbData.tipe || !dbData.harga) {
        return res.status(400).json({
          success: false,
          message: 'Nomor kamar, tipe, dan harga harus diisi'
        });
      }

      const exists = await RoomModel.nomorKamarExists(dbData.nomor_kamar);
      if (exists) {
        return res.status(400).json({
          success: false,
          message: 'Nomor kamar sudah ada'
        });
      }

      const room = await RoomModel.create(dbData);

      return res.status(201).json({
        success: true,
        message: 'Kamar berhasil ditambahkan',
        data: transformRoomToFrontend(room)
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

      const existingRoom = await RoomModel.findById(parseInt(id));
      if (!existingRoom) {
        return res.status(404).json({
          success: false,
          message: 'Kamar tidak ditemukan'
        });
      }

      // Transform frontend data to database format
      const dbData = transformRoomToDatabase(req.body);

      if (dbData.nomor_kamar) {
        const exists = await RoomModel.nomorKamarExists(dbData.nomor_kamar, parseInt(id));
        if (exists) {
          return res.status(400).json({
            success: false,
            message: 'Nomor kamar sudah ada'
          });
        }
      }

      const room = await RoomModel.update(parseInt(id), dbData);

      return res.json({
        success: true,
        message: 'Kamar berhasil diupdate',
        data: transformRoomToFrontend(room!)
      });
    } catch (error) {
      console.error('Update room error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
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
