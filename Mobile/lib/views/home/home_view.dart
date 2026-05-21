import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/menu_card.dart';

/// Home View
/// Tampilan halaman utama dengan menu navigasi
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kos Terpadu'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nama ?? 'User',
                            style: AppTheme.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: AppTheme.bodyText2,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAdmin 
                                  ? AppTheme.primaryColor 
                                  : AppTheme.successColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isAdmin ? 'Admin' : 'Penghuni',
                              style: AppTheme.caption.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Menu Utama',
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 16),
            // Menu Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                MenuCard(
                  icon: Icons.meeting_room,
                  title: 'Kamar',
                  subtitle: 'Lihat daftar kamar',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.kamarList);
                  },
                ),
                if (!isAdmin)
                  MenuCard(
                    icon: Icons.report_problem,
                    title: 'Keluhan',
                    subtitle: 'Buat keluhan',
                    color: AppTheme.warningColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.keluhanList);
                    },
                  ),
                if (isAdmin)
                  MenuCard(
                    icon: Icons.report_problem,
                    title: 'Keluhan',
                    subtitle: 'Kelola keluhan',
                    color: AppTheme.warningColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.keluhanList);
                    },
                  ),
                MenuCard(
                  icon: Icons.chat,
                  title: 'Chat',
                  subtitle: 'Pesan realtime',
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.chatList);
                  },
                ),
                if (!isAdmin)
                  MenuCard(
                    icon: Icons.payment,
                    title: 'Pembayaran',
                    subtitle: 'Riwayat bayar',
                    color: AppTheme.accentColor,
                    onTap: () {
                      // TODO: Navigate to pembayaran
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
