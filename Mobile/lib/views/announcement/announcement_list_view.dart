import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/announcement_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

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
      ),
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
    
    switch (announcement.prioritas) {
      case 'tinggi':
        priorityColor = Colors.red;
        priorityIcon = Icons.warning;
        break;
      case 'sedang':
        priorityColor = Colors.orange;
        priorityIcon = Icons.priority_high;
        break;
      default:
        priorityColor = Colors.blue;
        priorityIcon = Icons.info;
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(priorityIcon, color: priorityColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                announcement.prioritasLabel,
                                style: TextStyle(
                                  color: priorityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
              Text(
                announcement.judul,
                style: AppTheme.heading3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                announcement.isi,
                style: AppTheme.bodyText2.copyWith(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
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
