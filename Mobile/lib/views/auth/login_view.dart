import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Login View
/// Tampilan halaman login
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authController = context.read<AuthController>();
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (success) {
      // Check if user is admin - block admin from mobile
      if (authController.currentUser?.role == 'admin') {
        // Logout immediately
        await authController.logout();
        
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akun admin hanya bisa login melalui Web Admin.\nMobile app khusus untuk tenant/penghuni.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      
      // If tenant, navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Login gagal'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(
                  Icons.home_work,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang',
                  style: AppTheme.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login ke akun Anda',
                  style: AppTheme.bodyText2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Masukkan password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 32),
                Consumer<AuthController>(
                  builder: (context, controller, _) {
                    return CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: controller.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Untuk mendaftar sebagai penghuni baru,\nsilakan hubungi admin kos',
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
