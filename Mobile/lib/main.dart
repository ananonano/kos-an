import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/kamar_controller.dart';
import 'controllers/penghuni_controller.dart';
import 'controllers/pembayaran_controller.dart';
import 'controllers/keluhan_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/bill_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/announcement_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('⚠️ App will run without Firebase features (Chat & Keluhan will not work)');
  }
  
  // Initialize App Config
  await AppConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => KamarController()),
        ChangeNotifierProvider(create: (_) => PenghuniController()),
        ChangeNotifierProvider(create: (_) => PembayaranController()),
        ChangeNotifierProvider(create: (_) => KeluhanController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => BillController()),
        ChangeNotifierProvider(create: (_) => PaymentController()),
        ChangeNotifierProvider(create: (_) => AnnouncementController()),
      ],
      child: MaterialApp(
        title: 'Kos Terpadu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
