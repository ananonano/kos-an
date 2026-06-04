import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/maintenance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

/// Maintenance Detail View
/// Tampilan detail keluhan
class MaintenanceDetailView extends StatefulWidget {
  final String maintenanceId;
  
  const MaintenanceDetailView({
    super.key,
    required this.maintenanceId,
  });

  @override
  State<MaintenanceDetailView> createState() => _MaintenanceDetailViewState();
}

class _MaintenanceDetailViewState extends State<MaintenanceDetailView> {
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }
  
  Future<void> _loadDetail() async {
    final controller = context.read<MaintenanceController>();
    await controller.getMaintenanceDetail(widget.maintenanceId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluhan'),
      ),
      body: Consumer<MaintenanceController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          final maintenance = controller.selectedMaintenance;
          if (maintenance == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                _buildStatusCard(maintenance),
                const SizedBox(height: 16),
                
                // Info Card
                _buildInfoCard(maintenance),
                const SizedBox(height: 16),
                
                // Deskripsi
                _buildDescriptionCard(maintenance),
                const SizedBox(height: 16),
                
                // Foto (jika ada)
                if (maintenance.foto != null && maintenance.foto!.isNotEmpty) ...[
                  _buildPhotoCard(maintenance),
                  const SizedBox(height: 16),
                ],
                
                // Komentar Admin (jika ada)
                if (maintenance.komentarAdmin != null && maintenance.komentarAdmin!.isNotEmpty) ...[
                  _buildAdminCommentCard(maintenance),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusCard(maintenance) {
    Color statusColor;
    IconData statusIcon;
    
    switch (maintenance.status) {
      case 'baru':
        statusColor = Colors.blue;
        statusIcon = Icons.new_releases;
        break;
      case 'diproses':
        statusColor = Colors.orange;
        statusIcon = Icons.engineering;
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }
    
    Color prioritasColor;
    switch (maintenance.prioritas) {
      case 'urgent':
        prioritasColor = Colors.red;
        break;
      case 'tinggi':
        prioritasColor = Colors.orange;
        break;
      case 'sedang':
        prioritasColor = Colors.blue;
        break;
      case 'rendah':
        prioritasColor = Colors.green;
        break;
      default:
        prioritasColor = Colors.grey;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Status
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      maintenance.statusLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                
                // Prioritas
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: prioritasColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.flag, color: prioritasColor, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      maintenance.prioritasLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: prioritasColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(maintenance) {
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi', style: AppTheme.heading3),
            const Divider(),
            const SizedBox(height: 8),
            
            _buildInfoRow(Icons.title, 'Judul', maintenance.judul),
            _buildInfoRow(Icons.category, 'Kategori', maintenance.kategori),
            
            if (maintenance.namaTenant != null)
              _buildInfoRow(Icons.person, 'Penghuni', maintenance.namaTenant!),
            
            if (maintenance.nomorKamar != null)
              _buildInfoRow(Icons.meeting_room, 'Kamar', 'Kamar ${maintenance.nomorKamar}'),
            
            _buildInfoRow(
              Icons.calendar_today,
              'Tanggal Lapor',
              dateFormat.format(maintenance.tanggalLapor),
            ),
            
            if (maintenance.tanggalSelesai != null)
              _buildInfoRow(
                Icons.event_available,
                'Tanggal Selesai',
                dateFormat.format(maintenance.tanggalSelesai!),
              ),
            
            if (maintenance.biaya != null && maintenance.biaya! > 0)
              _buildInfoRow(
                Icons.attach_money,
                'Biaya',
                currencyFormat.format(maintenance.biaya),
                valueColor: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.caption.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionCard(maintenance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deskripsi', style: AppTheme.heading3),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              maintenance.deskripsi,
              style: AppTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhotoCard(maintenance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foto', style: AppTheme.heading3),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: maintenance.foto!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAdminCommentCard(maintenance) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Komentar Admin', style: AppTheme.heading3),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              maintenance.komentarAdmin!,
              style: AppTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
