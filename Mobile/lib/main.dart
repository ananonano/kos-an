import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import firebase_options
import 'firebase_options.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_notification_service.dart';
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
import 'controllers/tenant_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/maintenance_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Intl for date formatting
  try {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
    print('✅ Intl initialized successfully');
  } catch (e) {
    print('⚠️ Intl initialization failed: $e');
  }
  
  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('⚠️ App will run without Firebase features (Chat will not work)');
  }
  
  // Initialize Local Notifications
  try {
    await LocalNotificationService.initialize();
    print('✅ Local Notification Service initialized');
  } catch (e) {
    print('⚠️ Local Notification initialization failed: $e');
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
        ChangeNotifierProvider(create: (_) => TenantController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => MaintenanceController()),
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
