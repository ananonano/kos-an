import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/kamar_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/kamar_card.dart';

/// Kamar List View
/// Tampilan daftar kamar
class KamarListView extends StatefulWidget {
  const KamarListView({Key? key}) : super(key: key);

  @override
  State<KamarListView> createState() => _KamarListViewState();
}

class _KamarListViewState extends State<KamarListView> {
  String? _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KamarController>().getAllKamar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kamar'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value == 'all' ? null : value;
              });
              context.read<KamarController>().getAllKamar(
                status: _selectedStatus,
              );
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text('Semua'),
              ),
              PopupMenuItem(
                value: 'kosong',
                child: Text('Kosong'),
              ),
              PopupMenuItem(
                value: 'terisi',
                child: Text('Terisi'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<KamarController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    style: AppTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.getAllKamar(status: _selectedStatus);
                    },
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          if (controller.kamarList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data kamar',
                    style: AppTheme.bodyText1,
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => controller.getAllKamar(status: _selectedStatus),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.kamarList.length,
              itemBuilder: (context, index) {
                final kamar = controller.kamarList[index];
                return KamarCard(
                  kamar: kamar,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.kamarDetail,
                      arguments: kamar.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
