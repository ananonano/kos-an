import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/announcement_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';

class AnnouncementListView extends StatefulWidget {
  const AnnouncementListView({super.key});

  @override
  State<AnnouncementListView> createState() => _AnnouncementListViewState();
}

class _AnnouncementListViewState extends State<AnnouncementListView> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final announcementController = context.read<AnnouncementController>();
      if (!announcementController.isLoadingMore && announcementController.hasMore) {
        announcementController.loadMoreAnnouncements();
      }
    }
  }
  
  Future<void> _loadAnnouncements() async {
    final announcementController = context.read<AnnouncementController>();
    await announcementController.getAllAnnouncements(refresh: true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pengumuman'),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadAnnouncements,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(27),
              itemCount: announcements.length + (announcementController.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom
                if (index == announcements.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: announcementController.isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  );
                }
                
                final announcement = announcements[index];
                return _buildCard(announcement);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCard(dynamic announcement) {
    final dateFormat = DateFormat('MMM dd, hh:mm a', 'en_US');
    
    Color borderColor;
    double borderWidth;
    Color bgColor;
    Color iconBgColor;
    IconData icon;
    
    switch (announcement.prioritas.toLowerCase()) {
      case 'urgent':
        borderColor = const Color(0xFFE86A33);
        borderWidth = 5;
        bgColor = const Color(0xFFFFE5E5);
        iconBgColor = const Color(0x19A23900);
        icon = Icons.warning_amber_rounded;
        break;
      case 'penting':
        borderColor = const Color(0xFFFFB347);
        borderWidth = 5;
        bgColor = const Color(0xFFFFF4E5);
        iconBgColor = const Color(0x197C5800);
        icon = Icons.priority_high_rounded;
        break;
      default: // info
        borderColor = const Color(0xFFE8DED2);
        borderWidth = 5;
        bgColor = Colors.white;
        iconBgColor = const Color(0x1900C9A7);
        icon = Icons.info_outline_rounded;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.announcementDetail, arguments: announcement.id);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(width: borderWidth, color: borderColor),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(17),
            topRight: Radius.circular(11),
            bottomLeft: Radius.circular(11),
            bottomRight: Radius.circular(17),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.judul,
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Center(
                        child: Icon(icon, size: 18, color: borderColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Content
                Text(
                  announcement.konten,
                  style: TextStyle(
                    color: Color(0xFF5D5D5D),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                SizedBox(height: 28),
              ],
            ),
            // Date positioned at bottom right
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.50,
                child: Text(
                  dateFormat.format(announcement.createdAt).toUpperCase(),
                  style: TextStyle(
                    color: Color(0xFF1A1C1A),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.27,
                    letterSpacing: 0.22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
