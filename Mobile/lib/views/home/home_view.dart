import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/tenant_dashboard_view.dart';

/// Home View
/// Tampilan halaman utama untuk tenant dengan dashboard dan hamburger menu
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Saya'),
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
      body: const TenantDashboardView(),
    );
  }
}
