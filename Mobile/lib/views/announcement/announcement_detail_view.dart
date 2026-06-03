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
  
  const AnnouncementDetailView({super.key, required this.announcementId});

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leadingWidth: 70,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFA23900), size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Detail Pengumuman',
          style: TextStyle(
            color: Color(0xFFA23900),
            fontSize: 23,
            fontWeight: FontWeight.w700,
            height: 1.30,
          ),
        ),
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
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
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
          
          // Priority colors based on new design
          Color priorityColor;
          String priorityText;
          
          switch (announcement.prioritas.toLowerCase()) {
            case 'urgent':
              priorityColor = const Color(0xFFE84C3D); // Coral Red
              priorityText = 'URGENT';
              break;
            case 'penting':
              priorityColor = const Color(0xFFFFB347); // Peach
              priorityText = 'PENTING';
              break;
            case 'info':
            default:
              priorityColor = AppTheme.successColor; // Mint
              priorityText = 'INFO';
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge Card - Full Width
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(37),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border.all(width: 1, color: AppTheme.borderColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                      bottomRight: Radius.circular(17),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon with background
                      Container(
                        width: 84,
                        height: 84,
                        margin: const EdgeInsets.only(bottom: 19),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA23900).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.campaign,
                          size: 40,
                          color: Color(0xFFA23900),
                        ),
                      ),
                      // Priority text
                      Text(
                        priorityText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFA23900),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.90,
                          height: 1.26,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                  
                  const SizedBox(height: 37),
                  
                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 11,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        dateFormat.format(announcement.createdAt),
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Title
                  Text(
                    announcement.judul,
                    style: AppTheme.displayText.copyWith(
                      fontSize: 37,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  
                  const SizedBox(height: 9),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: AppTheme.borderColor,
                  ),
                  
                  const SizedBox(height: 27),
                  
                  // Content Card with left strip
                  Container(
                    padding: const EdgeInsets.fromLTRB(27, 27, 19, 19),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: AppTheme.borderColor),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                        bottomRight: Radius.circular(17),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Left strip indicator
                        Positioned(
                          left: -26,
                          top: 10,
                          bottom: 10,
                          child: Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: priorityColor,
                            ),
                          ),
                        ),
                        // Content text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.isi,
                              style: AppTheme.bodyText1.copyWith(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 15,
                                height: 1.625,
                                letterSpacing: 0.38,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 37),
                  
                  // Info Section
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 11),
                      Text(
                        'Informasi Pengumuman',
                        style: AppTheme.heading3.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 19),
                  
                  // Info Cards
                  Column(
                    children: [
                      _buildInfoCard('Prioritas', priorityText, AppTheme.textPrimaryColor, showDot: false),
                      const SizedBox(height: 0),
                      _buildInfoCard('Dipublikasikan', dateFormat.format(announcement.createdAt), null),
                      const SizedBox(height: 0),
                      _buildInfoCard('Kategori', announcement.kategori ?? 'Umum', null),
                    ],
                  ),
                  
                  const SizedBox(height: 37),
                  
                  // Optional: Location Card (if announcement has location)
                  if (announcement.kategori?.toLowerCase().contains('kegiatan') ?? false)
                    Container(
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDBCE),
                        border: Border.all(width: 1, color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 11),
                            child: const Icon(
                              Icons.location_on,
                              size: 24,
                              color: Color(0xFF7F2B00),
                            ),
                          ),
                          const Text(
                            'Ruang Tengah, Lt. 1',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7F2B00),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              height: 1.27,
                              letterSpacing: 0.22,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Lokasi Rapat',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF7F2B00).withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.38,
                              letterSpacing: 0.13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 37),
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
  
  Widget _buildInfoCard(String label, String value, Color? valueColor, {bool showDot = false}) {
    return Container(
      padding: const EdgeInsets.all(19),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F1),
        border: Border.all(width: 1, color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyText1.copyWith(
              color: AppTheme.textSecondaryColor,
              fontSize: 15,
              height: 1.47,
            ),
          ),
          Row(
            children: [
              if (showDot && valueColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: valueColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                value,
                style: AppTheme.heading3.copyWith(
                  color: valueColor ?? AppTheme.textPrimaryColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
