import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_view.dart';
import '../dashboard/tenant_dashboard_view.dart';

/// Home View
/// Tampilan halaman utama dengan dashboard dan hamburger menu
/// Admin: Dashboard Admin, Tenant: Dashboard Tenant
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isAdmin = authController.isAdmin;

    Widget dashboardWidget;
    if (isAdmin) {
      dashboardWidget = const DashboardView();
    } else {
      dashboardWidget = TenantDashboardView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Dashboard Admin' : 'Dashboard Saya'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: dashboardWidget,
    );
  }
}
