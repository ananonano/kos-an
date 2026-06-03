import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/tenant_controller.dart';
import '../../core/theme/app_theme.dart';

/// Edit Tenant View
/// Form untuk mengedit data penghuni
class EditTenantView extends StatefulWidget {
  final String tenantId;

  const EditTenantView({
    super.key,
    required this.tenantId,
  });

  @override
  State<EditTenantView> createState() => _EditTenantViewState();
}

class _EditTenantViewState extends State<EditTenantView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTeleponController = TextEditingController();
  final _alamatAsalController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _kontakDaruratController = TextEditingController();
  
  DateTime? _tanggalMasuk;
  DateTime? _tanggalKeluar;
  String _status = 'aktif';
  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTenantData();
  }

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

  Future<void> _loadTenantData() async {
    final tenantController = context.read<TenantController>();
    await tenantController.getTenantDetail(widget.tenantId);

    final tenant = tenantController.selectedTenant;
    if (tenant != null && mounted) {
      setState(() {
        _namaController.text = tenant.nama;
        _emailController.text = tenant.email;
        _noTeleponController.text = tenant.noTelepon;
        _alamatAsalController.text = tenant.alamatAsal ?? '';
        _pekerjaanController.text = tenant.pekerjaan ?? '';
        _kontakDaruratController.text = tenant.kontakDarurat ?? '';
        _tanggalMasuk = tenant.tanggalMasuk;
        _tanggalKeluar = tenant.tanggalKeluar;
        _status = tenant.status;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(bool isMasuk) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isMasuk
          ? (_tanggalMasuk ?? DateTime.now())
          : (_tanggalKeluar ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        if (isMasuk) {
          _tanggalMasuk = picked;
        } else {
          _tanggalKeluar = picked;
        }
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
    final success = await tenantController.updateTenant(
      id: widget.tenantId,
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
      tanggalKeluar: _tanggalKeluar,
      status: _status,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penghuni berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tenantController.errorMessage ?? 'Gagal mengupdate penghuni'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Penghuni'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Penghuni'),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'aktif',
                  child: Text('Aktif'),
                ),
                DropdownMenuItem(
                  value: 'tidak_aktif',
                  child: Text('Tidak Aktif'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Informasi Tambahan
            Text(
              'Informasi Tambahan',
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
              onTap: () => _selectDate(true),
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
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tanggal Keluar (Opsional)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tanggalKeluar == null
                          ? 'Pilih tanggal keluar'
                          : DateFormat('dd MMMM yyyy', 'id_ID').format(_tanggalKeluar!),
                      style: TextStyle(
                        color: _tanggalKeluar == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    if (_tanggalKeluar != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _tanggalKeluar = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
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
                      'Simpan Perubahan',
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
