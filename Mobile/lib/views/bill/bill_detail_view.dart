import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

/// Bill Detail View
/// Tampilan detail tagihan
class BillDetailView extends StatefulWidget {
  final String billId;
  
  const BillDetailView({Key? key, required this.billId}) : super(key: key);

  @override
  State<BillDetailView> createState() => _BillDetailViewState();
}

class _BillDetailViewState extends State<BillDetailView> {
  @override
  void initState() {
    super.initState();
    _loadBillDetail();
  }
  
  Future<void> _loadBillDetail() async {
    final billController = context.read<BillController>();
    await billController.getBillDetail(widget.billId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
      ),
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
                    onPressed: _loadBillDetail,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          final bill = billController.selectedBill;
          
          if (bill == null) {
            return const Center(child: Text('Tagihan tidak ditemukan'));
          }
          
          final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
          
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
          
          final totalBayar = bill.jumlah + (bill.denda ?? 0);
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(statusIcon, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        bill.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${bill.bulan} ${bill.tahun}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Detail Tagihan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Tagihan', style: AppTheme.heading2),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Periode', '${bill.bulan} ${bill.tahun}'),
                      _buildDetailRow('Jumlah Tagihan', currencyFormat.format(bill.jumlah)),
                      
                      if (bill.denda != null && bill.denda! > 0)
                        _buildDetailRow(
                          'Denda Keterlambatan', 
                          currencyFormat.format(bill.denda),
                          valueColor: Colors.red,
                        ),
                      
                      const Divider(height: 32),
                      
                      _buildDetailRow(
                        'Total yang Harus Dibayar', 
                        currencyFormat.format(totalBayar),
                        isTotal: true,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Jatuh Tempo', dateFormat.format(bill.jatuhTempo)),
                      
                      if (bill.catatan != null && bill.catatan!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Catatan:', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(bill.catatan!, style: AppTheme.bodyText2),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Tombol Bayar (jika belum lunas)
                      if (bill.status != 'lunas')
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createPayment,
                                arguments: bill.id,
                              );
                            },
                            icon: const Icon(Icons.payment),
                            label: const Text('Bayar Sekarang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Tombol Lihat Riwayat Pembayaran
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.paymentHistory,
                              arguments: bill.id,
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('Riwayat Pembayaran'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
              ? AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 16)
              : AppTheme.bodyText1,
          ),
          Text(
            value,
            style: isTotal
              ? AppTheme.heading3.copyWith(color: AppTheme.primaryColor)
              : AppTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
