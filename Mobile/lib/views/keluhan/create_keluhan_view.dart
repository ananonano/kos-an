import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/keluhan_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Create Keluhan View
/// Tampilan form membuat keluhan baru
class CreateKeluhanView extends StatefulWidget {
  const CreateKeluhanView({Key? key}) : super(key: key);

  @override
  State<CreateKeluhanView> createState() => _CreateKeluhanViewState();
}

class _CreateKeluhanViewState extends State<CreateKeluhanView> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final List<String> _selectedImages = [];
  
  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authController = context.read<AuthController>();
    final keluhanController = context.read<KeluhanController>();
    final user = authController.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User tidak ditemukan'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // TODO: Get kamarId from user's penghuni data
    final kamarId = '1'; // Placeholder
    
    final success = await keluhanController.createKeluhan(
      penghuniId: user.id,
      kamarId: kamarId,
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      fotoPaths: _selectedImages.isNotEmpty ? _selectedImages : null,
      namaPenghuni: user.nama,
      nomorKamar: 'A1', // Placeholder
    );
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keluhan berhasil dibuat'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            keluhanController.errorMessage ?? 'Gagal membuat keluhan',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _pickImage() async {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur upload foto akan segera hadir'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buat Keluhan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _judulController,
                label: 'Judul Keluhan',
                hint: 'Masukkan judul keluhan',
                validator: (value) => Validators.required(
                  value,
                  fieldName: 'Judul',
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _deskripsiController,
                label: 'Deskripsi',
                hint: 'Jelaskan keluhan Anda',
                maxLines: 5,
                validator: (value) => Validators.required(
                  value,
                  fieldName: 'Deskripsi',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Foto (Opsional)',
                style: AppTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.add_photo_alternate),
                label: Text('Tambah Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_selectedImages.length} foto dipilih',
                  style: AppTheme.caption,
                ),
              ],
              const SizedBox(height: 32),
              Consumer<KeluhanController>(
                builder: (context, controller, _) {
                  return CustomButton(
                    text: 'Kirim Keluhan',
                    onPressed: _handleSubmit,
                    isLoading: controller.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
