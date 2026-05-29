import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

/// Splash View
/// Tampilan splash screen dan check authentication
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }
  
  Future<void> _checkAuth() async {
    final authController = context.read<AuthController>();
    await authController.initialize();
    
    // Wait 2 seconds for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Navigate based on auth status
    if (authController.isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Kos Terpadu',
              style: AppTheme.heading1.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Manajemen Kos Modern',
              style: AppTheme.bodyText1.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
