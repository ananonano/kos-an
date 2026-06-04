import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../services/announcement_service.dart';
import '../services/notification_service.dart';

/// App Drawer Widget
/// Drawer yang digunakan di semua halaman dengan hamburger menu
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _unreadAnnouncementCount = 0;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCounts();
  }

  Future<void> _loadUnreadCounts() async {
    final announcementCount = await AnnouncementService.getUnreadCount();
    final notificationCount = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadAnnouncementCount = announcementCount;
        _unreadNotificationCount = notificationCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header - Custom Design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nama
                Text(
                  user?.nama ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Email
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Penghuni',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dashboard Menu Item
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
          ),

          // Notifikasi Menu Item
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifikasi'),
            trailing: _unreadNotificationCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _unreadNotificationCount > 99 ? '99+' : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.notificationList);
            },
          ),

          const Divider(),

          // Tenant Menu Items - Personal
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.orange),
            title: const Text('Tagihan Saya'),
            subtitle: const Text('Tagihan bulanan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.billList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: Colors.green),
            title: const Text('Pembayaran Saya'),
            subtitle: const Text('Riwayat bayar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.paymentHistory);
            },
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.red),
            title: const Text('Keluhan Saya'),
            subtitle: const Text('Lapor masalah kamar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.maintenanceList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.purple),
            title: const Text('Pengumuman'),
            subtitle: const Text('Info penting'),
            trailing: _unreadAnnouncementCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _unreadAnnouncementCount > 99 ? '99+' : _unreadAnnouncementCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.announcementList);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.teal),
            title: const Text('Chat Admin'),
            subtitle: const Text('Hubungi admin'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.chatList);
            },
          ),

          const Divider(),

          // Profile Menu Item
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          // Logout Menu Item
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthController>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
