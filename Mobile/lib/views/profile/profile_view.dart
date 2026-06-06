import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tenant_controller.dart';
import '../../services/auth_service.dart';
import '../../core/theme/app_theme.dart';
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

    try {
      final authController = context.read<AuthController>();
      final user = authController.currentUser;
      
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

      print('🔄 [Profile] Updating profile...');
      print('📝 [Profile] User ID: ${user.id}');
      print('📝 [Profile] Old Nama: ${user.nama}');
      print('📝 [Profile] New Nama: ${_namaController.text}');
      print('📝 [Profile] Old NoTelepon: ${user.noTelepon}');
      print('📝 [Profile] New NoTelepon: ${_noTeleponController.text}');

      // Call update profile API
      final updatedUser = await AuthService.updateProfile(
        userId: user.id.toString(),
        nama: _namaController.text,
        noTelepon: _noTeleponController.text,
      );

      print('✅ [Profile] Profile updated successfully');
      print('📦 [Profile] Updated user: ${updatedUser.nama}, ${updatedUser.noTelepon}');

      // Update auth controller dengan user baru
      await authController.refreshUser();
      
      // Reload user data to UI
      _loadUserData();
      
      print('🔄 [Profile] UI refreshed');
      
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
    } catch (e) {
      print('❌ [Profile] Update failed: $e');
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
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
    
    // Get tenant info if available
    final tenantController = context.watch<TenantController>();
    final tenant = tenantController.selectedTenant;

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
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          color: AppTheme.backgroundColor,
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // Profile Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 37, bottom: 37),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar with Solid Brown Color
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.nama.substring(0, 2).toUpperCase() ?? 'U',
                          style: AppTheme.displayText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 19),
                    
                    // User Name
                    Text(
                      user?.nama ?? 'Pengguna',
                      textAlign: TextAlign.center,
                      style: AppTheme.heading2.copyWith(
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PENGHUNI',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyText2.copyWith(
                          color: AppTheme.accentColor,
                          letterSpacing: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          border: Border.all(width: 1, color: AppTheme.borderColor),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(17),
                            topRight: Radius.circular(11),
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(17),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Left orange strip
                            Positioned(
                              left: -19,
                              top: 9,
                              bottom: 9,
                              child: Container(
                                width: 5,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            // Form Fields
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                children: [
                                  _buildFormField(
                                    'NAMA LENGKAP',
                                    user?.nama ?? '',
                                    _namaController,
                                    enabled: _isEditing,
                                  ),
                                  const SizedBox(height: 11),
                                  _buildFormField(
                                    'EMAIL',
                                    user?.email ?? '',
                                    _emailController,
                                    enabled: false,
                                    opacity: 0.7,
                                  ),
                                  const SizedBox(height: 11),
                                  _buildFormField(
                                    'NO. TELEPON',
                                    user?.noTelepon ?? '',
                                    _noTeleponController,
                                    enabled: _isEditing,
                                  ),
                                  if (tenant != null && tenant.nomorKamar != null) ...[
                                    const SizedBox(height: 11),
                                    _buildFormField(
                                      'NO. KAMAR',
                                      'Room ${tenant.nomorKamar}',
                                      null,
                                      enabled: false,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 27),
                      
                      // Action Buttons
                      if (_isEditing) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Simpan Perubahan'),
                          ),
                        ),
                        const SizedBox(height: 11),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondaryColor,
                              side: const BorderSide(color: AppTheme.borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                      ] else ...[
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                              side: const BorderSide(color: AppTheme.errorColor),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 19),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormField(
    String label,
    String value,
    TextEditingController? controller,
    {bool enabled = true, double opacity = 1.0}
  ) {
    return Opacity(
      opacity: opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              letterSpacing: 1.10,
            ),
          ),
          const SizedBox(height: 0.5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: AppTheme.borderColor),
              ),
            ),
            child: controller != null
                ? TextFormField(
                    controller: controller,
                    enabled: enabled,
                    style: AppTheme.bodyText1.copyWith(
                      color: enabled ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                    ),
                  )
                : Text(
                    value,
                    style: AppTheme.bodyText1.copyWith(
                      color: enabled ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F1),
        border: Border.all(width: 1, color: AppTheme.borderColor),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(17),
          topRight: Radius.circular(11),
          bottomLeft: Radius.circular(11),
          bottomRight: Radius.circular(17),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.heading3,
          ),
        ],
      ),
    );
  }
  
  String _calculateMonths(DateTime start, DateTime? end) {
    final endDate = end ?? DateTime.now();
    final months = (endDate.year - start.year) * 12 + (endDate.month - start.month);
    return '$months Bulan';
  }
  
  bool _isContractActive(DateTime endDate) {
    return DateTime.now().isBefore(endDate);
  }
}
