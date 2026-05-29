import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/announcement_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/menu_card.dart';

/// Home View
/// Tampilan halaman utama dengan dashboard lengkap
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authController = context.read<AuthController>();
    
    if (!authController.isAdmin) {
      // Load data untuk tenant
      context.read<BillController>().getAllBills();
      context.read<PaymentController>().getPaymentHistory();
      context.read<AnnouncementController>().getAllAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kos Terpadu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryColor,
                        child: const Icon(
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

              // Dashboard Summary untuk Tenant
              if (!isAdmin) ...[
                Text(
                  'Ringkasan',
                  style: AppTheme.heading2,
                ),
                const SizedBox(height: 12),
                _buildSummaryCards(context),
                const SizedBox(height: 24),
              ],

              // Menu Utama
              Text(
                'Menu Utama',
                style: AppTheme.heading2,
              ),
              const SizedBox(height: 16),
              _buildMenuGrid(context, isAdmin),

              // Recent Announcements untuk Tenant
              if (!isAdmin) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengumuman Terbaru',
                      style: AppTheme.heading2,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.announcementList);
                      },
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecentAnnouncements(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final billController = context.watch<BillController>();
    final paymentController = context.watch<PaymentController>();
    final announcementController = context.watch<AnnouncementController>();

    final unpaidBills = billController.unpaidBills.length;
    final pendingPayments = paymentController.pendingPayments.length;
    final urgentAnnouncements = announcementController.urgentAnnouncements.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Tagihan Belum Lunas',
            unpaidBills.toString(),
            Icons.receipt_long,
            AppTheme.errorColor,
            () => Navigator.pushNamed(context, AppRoutes.billList),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Pembayaran Pending',
            pendingPayments.toString(),
            Icons.pending_actions,
            AppTheme.warningColor,
            () => Navigator.pushNamed(context, AppRoutes.paymentHistory),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Pengumuman Penting',
            urgentAnnouncements.toString(),
            Icons.campaign,
            AppTheme.accentColor,
            () => Navigator.pushNamed(context, AppRoutes.announcementList),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTheme.heading1.copyWith(
                  color: color,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, bool isAdmin) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        if (!isAdmin) ...[
          // Menu untuk Tenant
          MenuCard(
            icon: Icons.receipt_long,
            title: 'Tagihan',
            subtitle: 'Lihat tagihan',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.billList);
            },
          ),
          MenuCard(
            icon: Icons.payment,
            title: 'Pembayaran',
            subtitle: 'Riwayat bayar',
            color: AppTheme.accentColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.paymentHistory);
            },
          ),
          MenuCard(
            icon: Icons.campaign,
            title: 'Pengumuman',
            subtitle: 'Info penting',
            color: AppTheme.successColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.announcementList);
            },
          ),
          MenuCard(
            icon: Icons.build,
            title: 'Keluhan',
            subtitle: 'Lapor masalah',
            color: AppTheme.warningColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.keluhanList);
            },
          ),
          MenuCard(
            icon: Icons.meeting_room,
            title: 'Kamar',
            subtitle: 'Info kamar',
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.kamarList);
            },
          ),
          MenuCard(
            icon: Icons.chat,
            title: 'Chat',
            subtitle: 'Hubungi admin',
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.chatList);
            },
          ),
        ] else ...[
          // Menu untuk Admin
          MenuCard(
            icon: Icons.meeting_room,
            title: 'Kamar',
            subtitle: 'Kelola kamar',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.kamarList);
            },
          ),
          MenuCard(
            icon: Icons.build,
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
            subtitle: 'Pesan penghuni',
            color: AppTheme.successColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.chatList);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRecentAnnouncements(BuildContext context) {
    final announcementController = context.watch<AnnouncementController>();

    if (announcementController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (announcementController.announcements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada pengumuman',
                  style: AppTheme.bodyText2.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recentAnnouncements = announcementController.announcements.take(3).toList();

    return Column(
      children: recentAnnouncements.map((announcement) {
        Color priorityColor;
        switch (announcement.prioritas) {
          case 'tinggi':
            priorityColor = AppTheme.errorColor;
            break;
          case 'sedang':
            priorityColor = AppTheme.warningColor;
            break;
          default:
            priorityColor = AppTheme.successColor;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: priorityColor.withOpacity(0.2),
              child: Icon(
                Icons.campaign,
                color: priorityColor,
              ),
            ),
            title: Text(
              announcement.judul,
              style: AppTheme.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              announcement.isi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.announcementDetail,
                arguments: announcement.id,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
