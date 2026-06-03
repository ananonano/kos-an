import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/announcement_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';

/// Announcement List View
/// Tampilan daftar pengumuman
class AnnouncementListView extends StatefulWidget {
  const AnnouncementListView({Key? key}) : super(key: key);

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }
  
  Future<void> _loadAnnouncements() async {
    final announcementController = context.read<AnnouncementController>();
    await announcementController.getAllAnnouncements();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<AnnouncementController>(
        builder: (context, announcementController, child) {
          if (announcementController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (announcementController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    announcementController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAnnouncements,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          final announcements = announcementController.announcements;
          
          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengumuman',
                    style: AppTheme.bodyText1.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadAnnouncements,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAnnouncementCard(announcement) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    
    Color priorityColor;
    IconData priorityIcon;
    String priorityBadge;
    
    switch (announcement.prioritas) {
      case 'urgent':
        priorityColor = Colors.red;
        priorityIcon = Icons.warning;
        priorityBadge = 'Urgent';
        break;
      case 'penting':
        priorityColor = Colors.orange;
        priorityIcon = Icons.priority_high;
        priorityBadge = 'Penting';
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = Icons.info;
        priorityBadge = 'Info';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.announcementDetail,
            arguments: announcement.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon & Badge
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.campaign, color: Colors.blue.shade700, size: 24),
                      ),
                      // Unread badge (dot indicator)
                      if (!announcement.isRead)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (announcement.prioritas == 'urgent' || announcement.prioritas == 'penting') ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  priorityBadge,
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (announcement.kategori != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  announcement.kategori!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(announcement.createdAt),
                          style: AppTheme.caption.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Judul with bold if unread
              Text(
                announcement.judul,
                style: AppTheme.heading3.copyWith(
                  fontSize: 16,
                  fontWeight: announcement.isRead ? FontWeight.normal : FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Konten
              Text(
                announcement.konten,
                style: AppTheme.bodyText2.copyWith(color: Colors.grey.shade700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Target (jika ada)
              if (announcement.target != null && announcement.target != 'semua') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Target: ${announcement.target}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Read more
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Baca selengkapnya',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
