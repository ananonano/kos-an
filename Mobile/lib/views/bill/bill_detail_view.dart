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
  
  const BillDetailView({super.key, required this.billId});

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA23900)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tagihan',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          String statusText;
          
          switch (bill.status) {
            case 'lunas':
              statusColor = const Color(0xFF00C9A7);
              statusText = 'LUNAS';
              break;
            case 'terlambat':
              statusColor = const Color(0xFFE84C3D);
              statusText = 'TERLAMBAT';
              break;
            default:
              statusColor = const Color(0xFFC77DFF);
              statusText = 'PENDING';
          }
          
          final totalBayar = bill.jumlah + (bill.denda ?? 0);
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 51, left: 27, right: 27, bottom: 37),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Total Amount dengan Left Strip
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8F0),
                      border: Border.all(width: 1, color: const Color(0xFFE8DED2)),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                        bottomRight: Radius.circular(17),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(27),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Total Amount Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL YANG HARUS DIBAYAR',
                                    style: TextStyle(
                                      color: Color(0xFF58423A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      height: 1.27,
                                      letterSpacing: 0.55,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    currencyFormat.format(totalBayar),
                                    style: TextStyle(
                                      color: Color(0xFFA23900),
                                      fontSize: 37,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                      letterSpacing: -0.37,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 19),
                              // Status Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600,
                                          height: 1.26,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (bill.status == 'lunas') ...[
                                    SizedBox(height: 5),
                                    Text(
                                      'Dibayar pada ${dateFormat.format(DateTime.now())}',
                                      style: TextStyle(
                                        color: Color(0xFF58423A),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.38,
                                        letterSpacing: 0.13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Left Green Strip
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 5,
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(17),
                                bottomLeft: Radius.circular(11),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 37),
                  
                  // Info Card - Periode & Jatuh Tempo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(19),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1, color: const Color(0xFFE8DED2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Periode Tagihan
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0x19A23900),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.calendar_today, size: 16, color: Color(0xFFA23900)),
                            ),
                            SizedBox(width: 11),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Periode Tagihan',
                                  style: TextStyle(
                                    color: Color(0xFF58423A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    height: 1.27,
                                    letterSpacing: 0.22,
                                  ),
                                ),
                                Text(
                                  '${bill.bulan} ${bill.tahun}',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.47,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                          decoration: BoxDecoration(color: Color(0xFFE8DED2)),
                        ),
                        // Jatuh Tempo
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0x19046670),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.event, size: 16, color: Color(0xFF046670)),
                            ),
                            SizedBox(width: 11),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jatuh Tempo',
                                  style: TextStyle(
                                    color: Color(0xFF58423A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    height: 1.27,
                                    letterSpacing: 0.22,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(bill.jatuhTempo),
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.47,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Catatan (jika ada)
                  if (bill.catatan != null && bill.catatan!.isNotEmpty) ...[
                    SizedBox(height: 19),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F3F1),
                        border: Border.all(width: 4, color: const Color(0xFFA23900)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan',
                            style: TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.26,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            bill.catatan!,
                            style: TextStyle(
                              color: Color(0xFF58423A),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.47,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 37),
                  
                  // Buttons
                  Column(
                    children: [
                      // Tombol Bayar (jika belum lunas)
                      if (bill.status != 'lunas')
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA23900),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.createPayment,
                                arguments: bill.id,
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Bayar Sekarang',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                height: 1.26,
                              ),
                            ),
                          ),
                        ),
                      
                      if (bill.status != 'lunas') SizedBox(height: 11),
                      
                      // Tombol Riwayat Pembayaran
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: const Color(0xFFA23900)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.paymentHistory,
                              arguments: bill.id,
                            );
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Riwayat Pembayaran',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFA23900),
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              height: 1.26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
