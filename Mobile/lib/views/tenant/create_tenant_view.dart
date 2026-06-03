import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/tenant_controller.dart';
import '../../core/theme/app_theme.dart';

/// Create Tenant View
/// Form untuk menambah penghuni baru
class CreateTenantView extends StatefulWidget {
  const CreateTenantView({super.key});

  @override
  State<CreateTenantView> createState() => _CreateTenantViewState();
}

class _CreateTenantViewState extends State<CreateTenantView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _alamatAsalController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _kontakDaruratController = TextEditingController();
  
  DateTime? _tanggalMasuk;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTeleponController.dispose();
    _alamatAsalController.dispose();
    _pekerjaanController.dispose();
    _kontakDaruratController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _tanggalMasuk) {
      setState(() {
        _tanggalMasuk = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final tenantController = context.read<TenantController>();
    final success = await tenantController.createTenant(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noTelepon: _noTeleponController.text.trim(),
      alamatAsal: _alamatAsalController.text.trim().isEmpty
          ? null
          : _alamatAsalController.text.trim(),
      pekerjaan: _pekerjaanController.text.trim().isEmpty
          ? null
          : _pekerjaanController.text.trim(),
      kontakDarurat: _kontakDaruratController.text.trim().isEmpty
          ? null
          : _kontakDaruratController.text.trim(),
      tanggalMasuk: _tanggalMasuk,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penghuni berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tenantController.errorMessage ?? 'Gagal menambah penghuni'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Penghuni'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informasi Dasar
            Text(
              'Informasi Dasar',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'contoh@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noTeleponController,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                hintText: '08xxxxxxxxxx',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'No. telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Informasi Tambahan
            Text(
              'Informasi Tambahan (Opsional)',
              style: AppTheme.heading3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _alamatAsalController,
              decoration: const InputDecoration(
                labelText: 'Alamat Asal',
                hintText: 'Masukkan alamat asal',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pekerjaanController,
              decoration: const InputDecoration(
                labelText: 'Pekerjaan',
                hintText: 'Masukkan pekerjaan',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _kontakDaruratController,
              decoration: const InputDecoration(
                labelText: 'Kontak Darurat',
                hintText: '08xxxxxxxxxx',
                prefixIcon: Icon(Icons.contact_phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Masuk',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _tanggalMasuk == null
                      ? 'Pilih tanggal masuk'
                      : DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggalMasuk!),
                  style: TextStyle(
                    color: _tanggalMasuk == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Tambah Penghuni',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
