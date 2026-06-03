import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/tenant_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

/// Tenant Detail View
/// Tampilan detail penghuni untuk Admin
class TenantDetailView extends StatefulWidget {
  final String tenantId;

  const TenantDetailView({
    super.key,
    required this.tenantId,
  });

  @override
  State<TenantDetailView> createState() => _TenantDetailViewState();
}

class _TenantDetailViewState extends State<TenantDetailView> {
  @override
  void initState() {
    super.initState();
    _loadTenantDetail();
  }

  Future<void> _loadTenantDetail() async {
    final tenantController = context.read<TenantController>();
    await tenantController.getTenantDetail(widget.tenantId);
  }

  Future<void> _deleteTenant() async {
    final tenant = context.read<TenantController>().selectedTenant;
    if (tenant == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus penghuni "${tenant.nama}"?'),
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
      final success = await tenantController.deleteTenant(widget.tenantId);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Penghuni berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tenantController.errorMessage ?? 'Gagal menghapus penghuni'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penghuni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editTenant,
                arguments: widget.tenantId,
              ).then((_) => _loadTenantDetail());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTenant,
          ),
        ],
      ),
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
                    onPressed: _loadTenantDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final tenant = tenantController.selectedTenant;
          if (tenant == null) {
            return const Center(
              child: Text('Data penghuni tidak ditemukan'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTenantDetail,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              tenant.nama[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tenant.nama,
                            style: AppTheme.heading2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tenant.status == 'aktif'
                                  ? AppTheme.successColor
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tenant.statusLabel,
                              style: AppTheme.bodyText2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSectionCard(
                    'Informasi Kontak',
                    [
                      _buildInfoRow(Icons.email, 'Email', tenant.email),
                      _buildInfoRow(Icons.phone, 'No. Telepon', tenant.noTelepon),
                      if (tenant.kontakDarurat != null)
                        _buildInfoRow(
                          Icons.contact_phone,
                          'Kontak Darurat',
                          tenant.kontakDarurat!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Room Information
                  _buildSectionCard(
                    'Informasi Kamar',
                    [
                      if (tenant.nomorKamar != null)
                        _buildInfoRow(
                          Icons.meeting_room,
                          'Nomor Kamar',
                          tenant.nomorKamar!,
                        )
                      else
                        _buildInfoRow(
                          Icons.meeting_room_outlined,
                          'Nomor Kamar',
                          'Belum ada kamar',
                          valueColor: Colors.grey,
                        ),
                      if (tenant.tanggalMasuk != null)
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Tanggal Masuk',
                          DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(tenant.tanggalMasuk!),
                        ),
                      if (tenant.tanggalKeluar != null)
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Tanggal Keluar',
                          DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(tenant.tanggalKeluar!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Personal Information
                  _buildSectionCard(
                    'Informasi Pribadi',
                    [
                      if (tenant.alamatAsal != null)
                        _buildInfoRow(
                          Icons.location_on,
                          'Alamat Asal',
                          tenant.alamatAsal!,
                        ),
                      if (tenant.pekerjaan != null)
                        _buildInfoRow(
                          Icons.work,
                          'Pekerjaan',
                          tenant.pekerjaan!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // System Information
                  _buildSectionCard(
                    'Informasi Sistem',
                    [
                      _buildInfoRow(
                        Icons.fingerprint,
                        'ID',
                        tenant.id,
                      ),
                      _buildInfoRow(
                        Icons.access_time,
                        'Dibuat',
                        DateFormat('dd MMM yyyy HH:mm', 'id_ID')
                            .format(tenant.createdAt),
                      ),
                      _buildInfoRow(
                        Icons.update,
                        'Diupdate',
                        DateFormat('dd MMM yyyy HH:mm', 'id_ID')
                            .format(tenant.updatedAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyText1.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
