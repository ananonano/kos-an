import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/tenant_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Create Payment View
/// Form untuk upload bukti pembayaran
class CreatePaymentView extends StatefulWidget {
  final String billId;
  
  const CreatePaymentView({Key? key, required this.billId}) : super(key: key);

  @override
  State<CreatePaymentView> createState() => _CreatePaymentViewState();
}

class _CreatePaymentViewState extends State<CreatePaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  
  String _metodePembayaran = 'Transfer Bank';
  DateTime _tanggalBayar = DateTime.now();
  String? _buktiPembayaranPath;
  
  final List<String> _metodeList = [
    'Transfer Bank',
    'Cash',
    'E-Wallet',
    'Kartu Kredit',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadBillDetail();
  }
  
  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBillDetail() async {
    final billController = context.read<BillController>();
    await billController.getBillDetail(widget.billId);
    
    // Auto-fill jumlah dari tagihan
    if (billController.selectedBill != null) {
      final bill = billController.selectedBill!;
      final total = bill.jumlah + (bill.denda ?? 0);
      _jumlahController.text = total.toString();
    }
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalBayar,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _tanggalBayar) {
      setState(() {
        _tanggalBayar = picked;
      });
    }
  }
  
  Future<void> _pickImage() async {
    // TODO: Implement image picker
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur upload foto akan segera tersedia'),
        backgroundColor: Colors.orange,
      ),
    );
    
    // Simulate image selection
    setState(() {
      _buktiPembayaranPath = '/path/to/image.jpg';
    });
  }
  
  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_buktiPembayaranPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan upload bukti pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final authController = context.read<AuthController>();
    final paymentController = context.read<PaymentController>();
    
    // Get tenant_id from tenants table based on user_id
    final user = authController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Get tenant data by user_id
    final tenant = await TenantService.getTenantByUserId(user.id.toString());
    
    if (tenant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data tenant tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final success = await paymentController.createPayment(
      billId: widget.billId,
      tenantId: int.parse(tenant.id),
      jumlah: double.parse(_jumlahController.text),
      metodePembayaran: _metodePembayaran,
      buktiPembayaran: _buktiPembayaranPath,
      keterangan: _keteranganController.text.isEmpty ? null : _keteranganController.text,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil disubmit. Menunggu verifikasi admin.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentController.errorMessage ?? 'Gagal submit pembayaran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bukti Pembayaran'),
      ),
      body: Consumer2<BillController, PaymentController>(
        builder: (context, billController, paymentController, child) {
          if (billController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final bill = billController.selectedBill;
          
          if (bill == null) {
            return const Center(child: Text('Tagihan tidak ditemukan'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Tagihan
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Informasi Tagihan', style: AppTheme.heading3),
                          const SizedBox(height: 12),
                          _buildInfoRow('Periode', '${bill.bulan} ${bill.tahun}'),
                          _buildInfoRow('Jumlah Tagihan', currencyFormat.format(bill.jumlah)),
                          if (bill.denda != null && bill.denda! > 0)
                            _buildInfoRow('Denda', currencyFormat.format(bill.denda), valueColor: Colors.red),
                          const Divider(),
                          _buildInfoRow(
                            'Total', 
                            currencyFormat.format(bill.jumlah + (bill.denda ?? 0)),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text('Detail Pembayaran', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  
                  // Jumlah Bayar
                  CustomTextField(
                    controller: _jumlahController,
                    label: 'Jumlah Bayar',
                    hint: 'Masukkan jumlah bayar',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah bayar harus diisi';
                      }
                      final jumlah = double.tryParse(value);
                      if (jumlah == null) {
                        return 'Jumlah tidak valid';
                      }
                      final total = bill.jumlah + bill.denda;
                      if (jumlah < total) {
                        return 'Jumlah kurang dari total tagihan';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tanggal Bayar
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Bayar',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(dateFormat.format(_tanggalBayar)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Metode Pembayaran
                  DropdownButtonFormField<String>(
                    value: _metodePembayaran,
                    decoration: InputDecoration(
                      labelText: 'Metode Pembayaran',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _metodeList.map((metode) {
                      return DropdownMenuItem(
                        value: metode,
                        child: Text(metode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _metodePembayaran = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bukti Pembayaran
                  Text('Bukti Pembayaran', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                      ),
                      child: _buktiPembayaranPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk upload foto',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 48, color: Colors.green),
                              const SizedBox(height: 8),
                              Text(
                                'Foto berhasil dipilih',
                                style: TextStyle(color: Colors.green),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: _pickImage,
                                child: const Text('Ganti Foto'),
                              ),
                            ],
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Keterangan
                  CustomTextField(
                    controller: _keteranganController,
                    label: 'Keterangan (Opsional)',
                    hint: 'Tambahkan keterangan jika perlu',
                    maxLines: 3,
                    prefixIcon: Icons.note,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  CustomButton(
                    text: 'Submit Pembayaran',
                    onPressed: _submitPayment,
                    isLoading: paymentController.isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pembayaran akan diverifikasi oleh admin dalam 1x24 jam',
                            style: TextStyle(color: Colors.blue[700], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
              ? AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold)
              : AppTheme.bodyText2,
          ),
          Text(
            value,
            style: isTotal
              ? AppTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)
              : AppTheme.bodyText2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}
