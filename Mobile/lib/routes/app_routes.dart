import 'package:flutter/material.dart';
import '../views/splash/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/home/home_view.dart';
import '../views/chat/chat_list_view.dart';
import '../views/chat/chat_room_view.dart';
import '../views/bill/bill_list_view.dart';
import '../views/bill/bill_detail_view.dart';
import '../views/payment/payment_history_view.dart';
import '../views/payment/create_payment_view.dart';
import '../views/announcement/announcement_list_view.dart';
import '../views/announcement/announcement_detail_view.dart';
import '../views/notification/notification_list_view.dart';
import '../views/profile/profile_view.dart';
import '../views/maintenance/maintenance_list_view.dart';
import '../views/maintenance/maintenance_detail_view.dart';
import '../views/maintenance/create_maintenance_view.dart';

/// App Routes - Tenant Only
/// Mengelola routing aplikasi untuk tenant
class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String chatList = '/chat';
  static const String chatRoom = '/chat/room';
  static const String billList = '/bills';
  static const String billDetail = '/bills/detail';
  static const String paymentHistory = '/payments/history';
  static const String createPayment = '/payments/create';
  static const String announcementList = '/announcements';
  static const String announcementDetail = '/announcements/detail';
  static const String notificationList = '/notifications';
  static const String profile = '/profile';
  static const String maintenanceList = '/maintenance';
  static const String maintenanceDetail = '/maintenance/detail';
  static const String createMaintenance = '/maintenance/create';
  
  // Generate Route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListView());
      
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatRoomView(
            chatRoomId: args['chatRoomId'],
            recipientName: args['recipientName'],
          ),
        );
      
      case billList:
        return MaterialPageRoute(builder: (_) => const BillListView());
      
      case billDetail:
        final billId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BillDetailView(billId: billId),
        );
      
      case paymentHistory:
        return MaterialPageRoute(builder: (_) => const PaymentHistoryView());
      
      case createPayment:
        final billId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CreatePaymentView(billId: billId),
        );
      
      case announcementList:
        return MaterialPageRoute(builder: (_) => const AnnouncementListView());
      
      case announcementDetail:
        final announcementId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AnnouncementDetailView(announcementId: announcementId),
        );
      
      case notificationList:
        return MaterialPageRoute(builder: (_) => const NotificationListView());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      
      case maintenanceList:
        return MaterialPageRoute(builder: (_) => const MaintenanceListView());
      
      case maintenanceDetail:
        final maintenanceId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MaintenanceDetailView(maintenanceId: maintenanceId),
        );
      
      case createMaintenance:
        return MaterialPageRoute(builder: (_) => const CreateMaintenanceView());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
