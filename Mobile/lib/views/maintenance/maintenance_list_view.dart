import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/maintenance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/tenant_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';

/// Maintenance List View (Keluhan)
/// Tampilan daftar keluhan untuk tenant dan admin
class MaintenanceListView extends StatefulWidget {
  const MaintenanceListView({super.key});

  @override
  State<MaintenanceListView> createState() => _MaintenanceListViewState();
}

class _MaintenanceListViewState extends State<MaintenanceListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMaintenance();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMaintenance() async {
    final maintenanceController = context.read<MaintenanceController>();
    
    // Backend will auto-filter based on user role
    // Admin: gets all maintenance
    // Tenant: gets only their maintenance
    await maintenanceController.getAllMaintenance();
  }
  
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isAdmin = authController.currentUser?.role == 'admin';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keluhan'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Diproses'),
            Tab(text: 'Selesai'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<MaintenanceController>(
        builder: (context, maintenanceController, child) {
          if (maintenanceController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (maintenanceController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    maintenanceController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMaintenance,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMaintenanceList(maintenanceController.newMaintenance, 'baru'),
              _buildMaintenanceList(maintenanceController.inProgressMaintenance, 'diproses'),
              _buildMaintenanceList(maintenanceController.completedMaintenance, 'selesai'),
              _buildMaintenanceList(maintenanceController.rejectedMaintenance, 'ditolak'),
            ],
          );
        },
      ),
      floatingActionButton: !isAdmin ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.createMaintenance);
          if (result == true) {
            _loadMaintenance();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ) : null,
    );
  }
  
  Widget _buildMaintenanceList(List maintenance, String status) {
    if (maintenance.isEmpty) {
      String emptyMessage;
      IconData emptyIcon;
      
      switch (status) {
        case 'baru':
          emptyMessage = 'Tidak ada keluhan baru';
          emptyIcon = Icons.inbox_outlined;
          break;
        case 'diproses':
          emptyMessage = 'Tidak ada keluhan yang sedang diproses';
          emptyIcon = Icons.engineering_outlined;
          break;
        case 'selesai':
          emptyMessage = 'Belum ada keluhan yang selesai';
          emptyIcon = Icons.check_circle_outline;
          break;
        case 'ditolak':
          emptyMessage = 'Tidak ada keluhan yang ditolak';
          emptyIcon = Icons.cancel_outlined;
          break;
        default:
          emptyMessage = 'Tidak ada data';
          emptyIcon = Icons.inbox_outlined;
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: AppTheme.bodyText1.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadMaintenance,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: maintenance.length,
        itemBuilder: (context, index) {
          final item = maintenance[index];
          return _buildMaintenanceCard(item);
        },
      ),
    );
  }
  
  Widget _buildMaintenanceCard(maintenance) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
    
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
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.maintenanceDetail,
            arguments: maintenance.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Judul & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      maintenance.judul,
                      style: AppTheme.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          maintenance.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Kategori & Prioritas
              Row(
                children: [
                  // Kategori
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      maintenance.kategori,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Prioritas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: prioritasColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, size: 12, color: prioritasColor),
                        const SizedBox(width: 4),
                        Text(
                          maintenance.prioritasLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: prioritasColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Deskripsi
              Text(
                maintenance.deskripsi,
                style: AppTheme.bodyText2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // Penghuni & Kamar
              if (maintenance.namaTenant != null || maintenance.nomorKamar != null) ...[
                Row(
                  children: [
                    if (maintenance.namaTenant != null) ...[
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        maintenance.namaTenant!,
                        style: AppTheme.caption,
                      ),
                    ],
                    if (maintenance.namaTenant != null && maintenance.nomorKamar != null)
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                    if (maintenance.nomorKamar != null) ...[
                      const Icon(Icons.meeting_room, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Kamar ${maintenance.nomorKamar}',
                        style: AppTheme.caption,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Tanggal Lapor
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(maintenance.tanggalLapor),
                    style: AppTheme.caption,
                  ),
                ],
              ),
              
              // Biaya (jika ada)
              if (maintenance.biaya != null && maintenance.biaya! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(maintenance.biaya),
                      style: AppTheme.caption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Foto indicator
              if (maintenance.foto != null && maintenance.foto!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.photo_library, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${maintenance.foto!.length} foto',
                      style: AppTheme.caption.copyWith(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
