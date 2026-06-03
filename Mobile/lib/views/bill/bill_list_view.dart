import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/tenant_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';

/// Bill List View
/// Tampilan daftar tagihan untuk tenant
class BillListView extends StatefulWidget {
  const BillListView({Key? key}) : super(key: key);

  @override
  State<BillListView> createState() => _BillListViewState();
}

class _BillListViewState extends State<BillListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBills();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBills() async {
    final billController = context.read<BillController>();
    
    // Backend will auto-filter based on user role
    // Admin: gets all bills
    // Tenant: gets only their bills
    await billController.getAllBills();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
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
            Tab(text: 'Belum Lunas'),
            Tab(text: 'Lunas'),
            Tab(text: 'Terlambat'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<BillController>(
        builder: (context, billController, child) {
          if (billController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (billController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    billController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBills,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildBillList(billController.unpaidBills, 'belum_lunas'),
              _buildBillList(billController.paidBills, 'lunas'),
              _buildBillList(billController.overdueBills, 'terlambat'),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildBillList(List bills, String status) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'lunas' ? Icons.check_circle_outline : Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'lunas' 
                ? 'Belum ada tagihan yang lunas'
                : status == 'terlambat'
                  ? 'Tidak ada tagihan terlambat'
                  : 'Tidak ada tagihan',
              style: AppTheme.bodyText1.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBills,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          final bill = bills[index];
          return _buildBillCard(bill);
        },
      ),
    );
  }
  
  Widget _buildBillCard(bill) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    
    Color statusColor;
    IconData statusIcon;
    
    switch (bill.status) {
      case 'lunas':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'terlambat':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.billDetail,
            arguments: bill.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Periode & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${bill.bulan} ${bill.tahun}',
                    style: AppTheme.heading3,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          bill.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Penghuni
              if (bill.namaTenant != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bill.namaTenant!,
                        style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Kamar
              if (bill.nomorKamar != null) ...[
                Row(
                  children: [
                    const Icon(Icons.meeting_room, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Kamar ${bill.nomorKamar}',
                      style: AppTheme.bodyText2,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Jumlah
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    currencyFormat.format(bill.jumlah),
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              // Denda (jika ada)
              if (bill.denda != null && bill.denda > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.warning, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Denda: ${currencyFormat.format(bill.denda)}',
                      style: AppTheme.bodyText2.copyWith(color: Colors.red),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Jatuh Tempo
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Jatuh Tempo: ${dateFormat.format(bill.jatuhTempo)}',
                    style: AppTheme.bodyText2.copyWith(
                      color: bill.isOverdue ? Colors.red : Colors.grey,
                      fontWeight: bill.isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              
              // Catatan (jika ada)
              if (bill.catatan != null && bill.catatan!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bill.catatan!,
                          style: AppTheme.caption.copyWith(color: Colors.grey.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
