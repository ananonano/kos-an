import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tenant_controller.dart';
import '../../controllers/bill_controller.dart';

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
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header/Greeting Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 37, left: 27, right: 27, bottom: 27),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user?.nama ?? 'Penghuni'}! 🔑',
                          style: AppTheme.heading2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Selamat datang kembali',
                          style: AppTheme.bodyText2.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Unpaid Bills Warning (if exists)
            if (unpaidBills.isNotEmpty) ...[
              Transform.translate(
                offset: const Offset(27, -10),
                child: Container(
                  width: MediaQuery.of(context).size.width - 54,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.warning_amber, color: AppTheme.primaryColor, size: 19),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${unpaidBills.length} TAGIHAN BELUM LUNAS',
                          style: AppTheme.smallText.copyWith(
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Room Info Card
            if (tenant != null && tenant.nomorKamar != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 37, left: 27, right: 27),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(27),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: AppTheme.borderColor),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      bottomRight: Radius.circular(11),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left orange strip
                      Positioned(
                        left: -27,
                        top: -27,
                        bottom: -27,
                        child: Container(
                          width: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                              bottomLeft: Radius.circular(11),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ROOM NUMBER',
                                      style: AppTheme.bodyText2.copyWith(
                                        letterSpacing: 1.30,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      tenant.nomorKamar ?? '-',
                                      style: AppTheme.displayText.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Premium Room',
                                      style: AppTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.meeting_room, color: AppTheme.primaryColor, size: 27),
                              ),
                            ],
                          ),
                          if (daysUntilContractEnd != null) ...[
                            const SizedBox(height: 19),
                            Container(
                              padding: const EdgeInsets.only(top: 19),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(width: 1, color: AppTheme.borderColor),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 27,
                                    height: 27,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.event, color: AppTheme.accentColor, size: 19),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Sisa Kontrak: ',
                                            style: AppTheme.bodyText2,
                                          ),
                                          TextSpan(
                                            text: '$daysUntilContractEnd Hari',
                                            style: AppTheme.bodyText2.copyWith(
                                              color: daysUntilContractEnd < 30 
                                                  ? AppTheme.warningColor 
                                                  : AppTheme.primaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
