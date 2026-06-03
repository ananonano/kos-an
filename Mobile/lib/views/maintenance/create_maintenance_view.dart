import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/maintenance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../services/tenant_service.dart';
import '../../core/theme/app_theme.dart';

/// Create Maintenance View
/// Form untuk tenant membuat laporan keluhan
class CreateMaintenanceView extends StatefulWidget {
  const CreateMaintenanceView({super.key});

  @override
  State<CreateMaintenanceView> createState() => _CreateMaintenanceViewState();
}

class _CreateMaintenanceViewState extends State<CreateMaintenanceView> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String _kategori = 'Listrik';
  String _prioritas = 'sedang';
  
  bool _isLoading = false;
  int? _tenantId;
  int? _kamarId;
  
  final List<String> _kategoriList = [
    'Listrik',
    'Air',
    'AC',
    'Furniture',
    'Kamar Mandi',
    'Pintu/Jendela',
    'Lainnya',
  ];
  
  final List<Map<String, dynamic>> _prioritasList = [
    {'value': 'rendah', 'label': 'Rendah', 'color': Colors.green},
    {'value': 'sedang', 'label': 'Sedang', 'color': Colors.blue},
    {'value': 'tinggi', 'label': 'Tinggi', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'Urgent', 'color': Colors.red},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadTenantData();
  }
  
  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTenantData() async {
    final authController = context.read<AuthController>();
    
    if (authController.currentUser != null) {
      final user = authController.currentUser!;
      
      // Get tenant data
      final tenant = await TenantService.getTenantByUserId(user.id);
      
      if (tenant != null && mounted) {
        setState(() {
          _tenantId = int.tryParse(tenant.id);
          _kamarId = tenant.kamarId != null ? int.tryParse(tenant.kamarId!) : null;
        });
      }
    }
  }
  
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_tenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data tenant tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_kamarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda belum memiliki kamar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final controller = context.read<MaintenanceController>();
    
    final success = await controller.createMaintenance(
      tenantId: _tenantId!,
      kamarId: _kamarId!,
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      kategori: _kategori,
      prioritas: _prioritas,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan keluhan berhasil dibuat')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Gagal membuat laporan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Keluhan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Laporkan masalah atau kerusakan di kamar Anda. Admin akan segera menindaklanjuti.',
                          style: AppTheme.bodyText2.copyWith(color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Judul
              Text('Judul Keluhan', style: AppTheme.heading3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: AC tidak dingin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  if (value.length < 5) {
                    return 'Judul minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Kategori
              Text('Kategori', style: AppTheme.heading3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _kategoriList.map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _kategori = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              
              // Prioritas
              Text('Prioritas', style: AppTheme.heading3),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _prioritasList.map((prioritas) {
                  final isSelected = _prioritas == prioritas['value'];
                  return ChoiceChip(
                    label: Text(prioritas['label']),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _prioritas = prioritas['value'];
                        });
                      }
                    },
                    selectedColor: (prioritas['color'] as Color).withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? prioritas['color'] : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    avatar: isSelected
                        ? Icon(Icons.check, size: 18, color: prioritas['color'])
                        : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih prioritas sesuai tingkat urgensi masalah',
                style: AppTheme.caption.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              // Deskripsi
              Text('Deskripsi', style: AppTheme.heading3),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  hintText: 'Jelaskan masalah secara detail...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  if (value.length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Laporan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
