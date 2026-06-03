import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/announcement_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../services/announcement_service.dart';

/// Announcement Detail View
/// Tampilan detail pengumuman
class AnnouncementDetailView extends StatefulWidget {
  final String announcementId;
  
  const AnnouncementDetailView({Key? key, required this.announcementId}) : super(key: key);

  @override
  State<AnnouncementDetailView> createState() => _AnnouncementDetailViewState();
}

class _AnnouncementDetailViewState extends State<AnnouncementDetailView> {
  @override
  void initState() {
    super.initState();
    _loadAnnouncementDetail();
    // Mark as read when opening detail
    _markAsRead();
  }
  
  Future<void> _loadAnnouncementDetail() async {
    final announcementController = context.read<AnnouncementController>();
    await announcementController.getAnnouncementDetail(widget.announcementId);
  }
  
  Future<void> _markAsRead() async {
    // Mark announcement as read
    await AnnouncementService.markAsRead(widget.announcementId);
    // Refresh list to update badge
    if (mounted) {
      final announcementController = context.read<AnnouncementController>();
      await announcementController.getAllAnnouncements();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
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
                    onPressed: _loadAnnouncementDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          final announcement = announcementController.selectedAnnouncement;
          
          if (announcement == null) {
            return const Center(child: Text('Pengumuman tidak ditemukan'));
          }
          
          final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
          
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
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan prioritas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(priorityIcon, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        announcement.prioritasLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        announcement.judul,
                        style: AppTheme.heading1.copyWith(fontSize: 24),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Tanggal
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(announcement.createdAt),
                            style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Divider(),
                      
                      const SizedBox(height: 24),
                      
                      // Konten
                      Text(
                        announcement.isi,
                        style: AppTheme.bodyText1.copyWith(
                          height: 1.6,
                          fontSize: 16,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Info tambahan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 20, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Informasi Pengumuman',
                                  style: AppTheme.bodyText1.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Prioritas', announcement.prioritasLabel),
                            _buildInfoRow(
                              'Dipublikasikan', 
                              dateFormat.format(announcement.createdAt),
                            ),
                            if (announcement.updatedAt != announcement.createdAt)
                              _buildInfoRow(
                                'Terakhir diupdate', 
                                dateFormat.format(announcement.updatedAt),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
