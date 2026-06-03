import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/tenant_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';

/// Tenant List View
/// Tampilan daftar penghuni untuk Admin
class TenantListView extends StatefulWidget {
  const TenantListView({super.key});

  @override
  State<TenantListView> createState() => _TenantListViewState();
}

class _TenantListViewState extends State<TenantListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTenants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    final tenantController = context.read<TenantController>();
    await tenantController.getAllTenants();
  }

  Future<void> _deleteTenant(String id, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus penghuni "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final tenantController = context.read<TenantController>();
      final success = await tenantController.deleteTenant(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Penghuni berhasil dihapus' : 'Gagal menghapus penghuni'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Penghuni'),
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
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Tidak Aktif'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<TenantController>(
        builder: (context, tenantController, child) {
          if (tenantController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tenantController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    tenantController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTenants,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTenantList(tenantController.activeTenants),
              _buildTenantList(tenantController.inactiveTenants),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createTenant);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTenantList(List tenants) {
    if (tenants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada penghuni',
              style: AppTheme.bodyText1.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTenants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tenants.length,
        itemBuilder: (context, index) {
          final tenant = tenants[index];
          return _buildTenantCard(tenant);
        },
      ),
    );
  }

  Widget _buildTenantCard(tenant) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.tenantDetail,
            arguments: tenant.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      tenant.nama[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.nama,
                          style: AppTheme.heading3,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tenant.email,
                                style: AppTheme.caption.copyWith(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editTenant,
                          arguments: tenant.id,
                        );
                      } else if (value == 'delete') {
                        _deleteTenant(tenant.id, tenant.nama);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.phone,
                      tenant.noTelepon,
                    ),
                  ),
                  if (tenant.nomorKamar != null)
                    Expanded(
                      child: _buildInfoItem(
                        Icons.meeting_room,
                        'Kamar ${tenant.nomorKamar}',
                      ),
                    ),
                ],
              ),
              if (tenant.tanggalMasuk != null) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  Icons.calendar_today,
                  'Masuk: ${dateFormat.format(tenant.tanggalMasuk!)}',
                ),
              ],
              if (tenant.pekerjaan != null) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  Icons.work,
                  tenant.pekerjaan!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTheme.caption.copyWith(color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
