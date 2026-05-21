import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/keluhan_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/keluhan_model.dart';

/// Keluhan List View
/// Tampilan daftar keluhan (realtime)
class KeluhanListView extends StatelessWidget {
  const KeluhanListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final keluhanController = context.watch<KeluhanController>();
    final isAdmin = authController.isAdmin;
    final userId = authController.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Keluhan'),
      ),
      floatingActionButton: !isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createKeluhan);
              },
              child: Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<KeluhanModel>>(
        stream: keluhanController.streamKeluhan(
          penghuniId: !isAdmin ? userId : null,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: AppTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
          
          final keluhanList = snapshot.data ?? [];
          
          if (keluhanList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada keluhan',
                    style: AppTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keluhanList.length,
            itemBuilder: (context, index) {
              final keluhan = keluhanList[index];
              return _KeluhanCard(
                keluhan: keluhan,
                isAdmin: isAdmin,
              );
            },
          );
        },
      ),
    );
  }
}

class _KeluhanCard extends StatelessWidget {
  final KeluhanModel keluhan;
  final bool isAdmin;
  
  const _KeluhanCard({
    required this.keluhan,
    required this.isAdmin,
  });

  Color _getStatusColor() {
    switch (keluhan.status) {
      case 'baru':
        return AppTheme.primaryColor;
      case 'diproses':
        return AppTheme.warningColor;
      case 'selesai':
        return AppTheme.successColor;
      case 'ditolak':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    keluhan.judul,
                    style: AppTheme.heading3,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    Helpers.getStatusLabel(keluhan.status),
                    style: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              keluhan.deskripsi,
              style: AppTheme.bodyText1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  Helpers.getRelativeTime(keluhan.createdAt),
                  style: AppTheme.caption,
                ),
                if (isAdmin && keluhan.namaPenghuni != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    keluhan.namaPenghuni!,
                    style: AppTheme.caption,
                  ),
                ],
              ],
            ),
            if (keluhan.foto != null && keluhan.foto!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${keluhan.foto!.length} foto',
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
