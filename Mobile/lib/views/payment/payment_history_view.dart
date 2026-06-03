import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_drawer.dart';

/// Payment History View
/// Tampilan riwayat pembayaran tenant
class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPayments();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPayments() async {
    final paymentController = context.read<PaymentController>();
    
    // Backend will auto-filter based on user role
    // Admin: gets all payments
    // Tenant: gets only their payments
    await paymentController.getPaymentHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
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
            Tab(text: 'Menunggu'),
            Tab(text: 'Lunas'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<PaymentController>(
        builder: (context, paymentController, child) {
          if (paymentController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (paymentController.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    paymentController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadPayments,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPaymentList(paymentController.pendingPayments, 'menunggu_verifikasi'),
              _buildPaymentList(paymentController.verifiedPayments, 'lunas'),
              _buildPaymentList(paymentController.rejectedPayments, 'ditolak'),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPaymentList(List payments, String status) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'lunas' 
                ? Icons.check_circle_outline 
                : status == 'ditolak'
                  ? Icons.cancel_outlined
                  : Icons.pending_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              status == 'lunas' 
                ? 'Belum ada pembayaran yang diverifikasi'
                : status == 'ditolak'
                  ? 'Tidak ada pembayaran yang ditolak'
                  : 'Tidak ada pembayaran yang menunggu verifikasi',
              style: AppTheme.bodyText1.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }
  
  Widget _buildPaymentCard(payment) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    
    Color statusColor;
    IconData statusIcon;
    
    switch (payment.status) {
      case 'lunas':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${payment.id}',
                  style: AppTheme.caption.copyWith(
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
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
                        payment.statusLabel,
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
            
            // Penghuni (jika ada)
            if (payment.namaTenant != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment.namaTenant!,
                      style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Tagihan (Periode)
            if (payment.bulanTagihan != null && payment.tahunTagihan != null) ...[
              Row(
                children: [
                  const Icon(Icons.receipt, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Tagihan: ${payment.bulanTagihan} ${payment.tahunTagihan}',
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
                  currencyFormat.format(payment.jumlah),
                  style: AppTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Tanggal Bayar
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tgl Bayar: ${dateFormat.format(payment.tanggalBayar)}',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Metode Pembayaran
            Row(
              children: [
                const Icon(Icons.payment, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Metode: ${payment.metodePembayaranLabel}',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey),
                ),
              ],
            ),
            
            // Keterangan (jika ada)
            if (payment.keterangan != null && payment.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                        payment.keterangan!,
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
    );
  }
}
