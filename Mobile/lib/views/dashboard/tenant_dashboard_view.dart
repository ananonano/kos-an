import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tenant_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../routes/app_routes.dart';

class TenantDashboardView extends StatefulWidget {
  const TenantDashboardView({super.key});

  @override
  State<TenantDashboardView> createState() => _TenantDashboardViewState();
}

class _TenantDashboardViewState extends State<TenantDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authController = context.read<AuthController>();
    final tenantController = context.read<TenantController>();
    final billController = context.read<BillController>();

    if (authController.currentUser != null) {
      await tenantController.getTenantByUserId(authController.currentUser!.id);
      await billController.getAllBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final tenantController = context.watch<TenantController>();
    final billController = context.watch<BillController>();
    
    final user = authController.currentUser;
    final tenant = tenantController.selectedTenant;
    final bills = billController.billList;

    int? daysUntilContractEnd;
    if (tenant != null && tenant.tanggalKeluar != null) {
      final now = DateTime.now();
      final contractEnd = tenant.tanggalKeluar!;
      daysUntilContractEnd = contractEnd.difference(now).inDays;
    }

    final unpaidBills = bills.where((b) => b.status != 'lunas').toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 36, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          user?.nama ?? 'Penghuni',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (tenant != null && tenant.nomorKamar != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Kamar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(height: 24),
                      Text('Nomor Kamar: ${tenant.nomorKamar ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('Tanggal Masuk: ${tenant.tanggalMasuk != null ? DateFormat('dd MMM yyyy').format(tenant.tanggalMasuk!) : '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (daysUntilContractEnd != null) ...[
              Card(
                color: daysUntilContractEnd < 30 ? Colors.orange.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Masa Kontrak', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('$daysUntilContractEnd hari lagi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (unpaidBills.isNotEmpty) ...[
              Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: const Text('Tagihan Belum Lunas'),
                  subtitle: Text('${unpaidBills.length} Tagihan'),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.billList),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
