import { Request, Response } from 'express';
import { UserModel } from '../models';
import jwt from 'jsonwebtoken';

export class AuthController {
  /**
   * Login user with email and password
   * Returns JWT token and user data
   */
  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email dan password harus diisi'
        });
      }

      const user = await UserModel.findByEmail(email);
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Email atau password salah'
        });
      }

      const isValid = await UserModel.verifyPassword(password, user.password);
      if (!isValid) {
        return res.status(401).json({
          success: false,
          message: 'Email atau password salah'
        });
      }

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'default_secret_key',
        { expiresIn: '7d' }
      );

      const { password: _, ...userWithoutPassword } = user;

      // Transform nama to name for frontend compatibility
      const userResponse = {
        ...userWithoutPassword,
        name: userWithoutPassword.nama,
        phone: userWithoutPassword.no_telepon,
      };

      return res.json({
        success: true,
        message: 'Login berhasil',
        token,
        user: userResponse
      });
    } catch (error) {
      console.error('Login error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Register new user
   * Creates user account and returns JWT token
   */
  static async register(req: Request, res: Response) {
    try {
      const { email, password, nama, no_telepon, role } = req.body;

      if (!email || !password || !nama) {
        return res.status(400).json({
          success: false,
          message: 'Email, password, dan nama harus diisi'
        });
      }

      const exists = await UserModel.emailExists(email);
      if (exists) {
        return res.status(400).json({
          success: false,
          message: 'Email sudah terdaftar'
        });
      }

      const user = await UserModel.create({
        email,
        password,
        nama,
        no_telepon,
        role: role || 'tenant'
      });

      const token = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'default_secret_key',
        { expiresIn: '7d' }
      );

      const { password: _, ...userWithoutPassword } = user;

      return res.status(201).json({
        success: true,
        message: 'Register berhasil',
        token,
        user: userWithoutPassword
      });
    } catch (error) {
      console.error('Register error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get current authenticated user
   * Requires valid JWT token
   */
  static async getMe(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;

      const user = await UserModel.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User tidak ditemukan'
        });
      }

      const { password: _, ...userWithoutPassword } = user;

      return res.json({
        success: true,
        data: userWithoutPassword
      });
    } catch (error) {
      console.error('GetMe error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Logout user
   * Client should remove token from storage
   */
  static async logout(req: Request, res: Response) {
    return res.json({
      success: true,
      message: 'Logout berhasil'
    });
  }

  /**
   * Update user profile
   * Allows updating nama, email, no_telepon, and foto
   */
  static async updateProfile(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;

      // Handle both JSON and FormData
      const { nama, email, no_telepon, foto } = req.body;

      const updateData: any = {};

      if (nama !== undefined) updateData.nama = nama;
      if (email !== undefined) {
        // Check if email already exists for another user
        const emailExists = await UserModel.emailExists(email, userId);
        if (emailExists) {
          return res.status(400).json({
            success: false,
            message: 'Email sudah digunakan oleh user lain'
          });
        }
        updateData.email = email;
      }
      if (no_telepon !== undefined) updateData.no_telepon = no_telepon;
      if (foto !== undefined) updateData.foto = foto;

      const user = await UserModel.update(userId, updateData);

      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User tidak ditemukan'
        });
      }

      const { password: _, ...userWithoutPassword } = user;

      return res.json({
        success: true,
        message: 'Profile berhasil diupdate',
        data: userWithoutPassword
      });
    } catch (error) {
      console.error('Update profile error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Change user password
   * Requires current password verification
   */
  static async changePassword(req: Request, res: Response) {
    try {
      const userId = (req as any).user.id;
      const { currentPassword, newPassword } = req.body;

      if (!currentPassword || !newPassword) {
        return res.status(400).json({
          success: false,
          message: 'Password lama dan password baru harus diisi'
        });
      }

      if (newPassword.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'Password baru minimal 6 karakter'
        });
      }

      const user = await UserModel.findById(userId);
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User tidak ditemukan'
        });
      }

      const isValid = await UserModel.verifyPassword(currentPassword, user.password);
      if (!isValid) {
        return res.status(401).json({
          success: false,
          message: 'Password lama salah'
        });
      }

      await UserModel.update(userId, { password: newPassword });

      return res.json({
        success: true,
        message: 'Password berhasil diubah'
      });
    } catch (error) {
      console.error('Change password error:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
