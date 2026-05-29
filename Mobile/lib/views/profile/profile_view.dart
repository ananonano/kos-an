import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../routes/app_routes.dart';

/// Profile View
/// Tampilan untuk melihat dan edit profil pengguna
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTeleponController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authController = context.read<AuthController>();
    final user = authController.currentUser;
    
    if (user != null) {
      _namaController.text = user.nama;
      _emailController.text = user.email;
      _noTeleponController.text = user.noTelepon ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement update profile API
    // For now, just show success message
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authController = context.read<AuthController>();
      await authController.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.accentColor,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // TODO: Implement image picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fitur upload foto akan segera hadir'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isAdmin ? AppTheme.primaryColor : AppTheme.successColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAdmin ? 'Admin' : 'Penghuni',
                  style: AppTheme.bodyText1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              CustomTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                prefixIcon: Icons.person,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'email@example.com',
                prefixIcon: Icons.email,
                enabled: false, // Email tidak bisa diubah
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _noTeleponController,
                label: 'No. Telepon',
                hint: '08123456789',
                prefixIcon: Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 10) {
                      return 'No. telepon minimal 10 digit';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing) ...[
                CustomButton(
                  text: 'Simpan Perubahan',
                  onPressed: _updateProfile,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Batal',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadUserData(); // Reset form
                    });
                  },
                  backgroundColor: Colors.grey,
                ),
              ] else ...[
                // Info Cards
                _buildInfoCard(
                  'ID Pengguna',
                  user?.id.toString() ?? '-',
                  Icons.badge,
                ),
                const SizedBox(height: 12),
                
                if (!isAdmin && user?.noTelepon != null)
                  _buildInfoCard(
                    'No. Telepon',
                    user!.noTelepon!,
                    Icons.phone,
                  ),
                
                const SizedBox(height: 32),

                // Logout Button
                CustomButton(
                  text: 'Logout',
                  onPressed: _logout,
                  backgroundColor: AppTheme.errorColor,
                  icon: Icons.logout,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          label,
          style: AppTheme.caption.copyWith(
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: AppTheme.bodyText1,
        ),
      ),
    );
  }
}
