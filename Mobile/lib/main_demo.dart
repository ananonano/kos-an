import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

/// Demo Main - Login tanpa backend
/// Run dengan: flutter run -t lib/main_demo.dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DemoAuthController(),
      child: MaterialApp(
        title: 'Kos Terpadu - Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DemoLoginView(),
      ),
    );
  }
}

// Demo Auth Controller
class DemoAuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    // Demo credentials
    if (email == 'admin@test.com' && password == 'admin123') {
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (email == 'user@test.com' && password == 'user123') {
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Email atau password salah';
      notifyListeners();
      return false;
    }
  }
}

// Demo Login View
class DemoLoginView extends StatefulWidget {
  const DemoLoginView({Key? key}) : super(key: key);

  @override
  State<DemoLoginView> createState() => _DemoLoginViewState();
}

class _DemoLoginViewState extends State<DemoLoginView> {
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
    
    final authController = context.read<DemoAuthController>();
    final success = await authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DemoHomeView()),
      );
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
                  'Login ke akun Anda (DEMO MODE)',
                  style: AppTheme.bodyText2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Demo Credentials Info
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔑 Demo Credentials:',
                          style: AppTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Admin:', style: AppTheme.bodyText2),
                        Text('Email: admin@test.com', style: AppTheme.caption),
                        Text('Password: admin123', style: AppTheme.caption),
                        const SizedBox(height: 8),
                        Text('Penghuni:', style: AppTheme.bodyText2),
                        Text('Email: user@test.com', style: AppTheme.caption),
                        Text('Password: user123', style: AppTheme.caption),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Masukkan password',
                    prefixIcon: Icon(Icons.lock),
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
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                Consumer<DemoAuthController>(
                  builder: (context, controller, _) {
                    return ElevatedButton(
                      onPressed: controller.isLoading ? null : _handleLogin,
                      child: controller.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Login'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Demo Home View
class DemoHomeView extends StatelessWidget {
  const DemoHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kos Terpadu - Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DemoLoginView()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              Text(
                '✅ Login Berhasil!',
                style: AppTheme.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat datang di Kos Terpadu',
                style: AppTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '📱 Status:',
                        style: AppTheme.heading3,
                      ),
                      const SizedBox(height: 16),
                      _StatusItem(icon: Icons.check, text: 'Flutter: OK'),
                      _StatusItem(icon: Icons.check, text: 'Firebase: OK'),
                      _StatusItem(icon: Icons.check, text: 'Login: OK'),
                      _StatusItem(icon: Icons.warning, text: 'Backend API: Belum tersedia', isWarning: true),
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
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isWarning;
  
  const _StatusItem({
    required this.icon,
    required this.text,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? AppTheme.warningColor : AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.bodyText1),
        ],
      ),
    );
  }
}
