import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

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
    final authController = context.read<AuthController>();
    final paymentController = context.read<PaymentController>();
    
    if (authController.currentUser != null) {
      await paymentController.getPaymentHistory(tenantId: authController.currentUser!.id.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Lunas'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
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
    String statusText;
    
    switch (payment.status) {
      case 'lunas':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'LUNAS';
        break;
      case 'ditolak':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'DITOLAK';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'MENUNGGU';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(payment.jumlah),
                  style: AppTheme.heading3,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
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
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Tanggal: ${dateFormat.format(payment.tanggalBayar)}',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.payment, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Metode: ${payment.metodePembayaran}',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey),
                ),
              ],
            ),
            if (payment.keterangan != null && payment.keterangan!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment.keterangan!,
                      style: AppTheme.caption.copyWith(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (payment.verifiedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    payment.status == 'lunas' ? Icons.verified : Icons.info_outline,
                    size: 18,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diverifikasi: ${dateFormat.format(payment.verifiedAt!)}',
                    style: AppTheme.caption.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
            if (payment.buktiPembayaran != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  // TODO: Show image viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lihat bukti pembayaran')),
                  );
                },
                icon: const Icon(Icons.image, size: 18),
                label: const Text('Lihat Bukti Pembayaran'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
