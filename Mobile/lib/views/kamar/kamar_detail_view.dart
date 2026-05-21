import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/kamar_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';

/// Kamar Detail View
/// Tampilan detail kamar
class KamarDetailView extends StatefulWidget {
  final String kamarId;
  
  const KamarDetailView({
    Key? key,
    required this.kamarId,
  }) : super(key: key);

  @override
  State<KamarDetailView> createState() => _KamarDetailViewState();
}

class _KamarDetailViewState extends State<KamarDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KamarController>().getKamarById(widget.kamarId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kamar'),
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
                ],
              ),
            );
          }
          
          final kamar = controller.selectedKamar;
          if (kamar == null) {
            return Center(child: Text('Data kamar tidak ditemukan'));
          }
          
          final isKosong = kamar.status == 'kosong';
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: Icon(
                    Icons.meeting_room,
                    size: 100,
                    color: Colors.grey.shade500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kamar ${kamar.nomorKamar}',
                            style: AppTheme.heading2,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isKosong 
                                  ? AppTheme.successColor 
                                  : AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              Helpers.getStatusLabel(kamar.status),
                              style: AppTheme.bodyText2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kamar.tipe,
                        style: AppTheme.bodyText1,
                      ),
                      const SizedBox(height: 16),
                      // Price
                      Text(
                        'Harga',
                        style: AppTheme.bodyText2,
                      ),
                      Text(
                        '${Helpers.formatCurrency(kamar.harga)}/bulan',
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Description
                      if (kamar.deskripsi != null) ...[
                        Text(
                          'Deskripsi',
                          style: AppTheme.heading3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kamar.deskripsi!,
                          style: AppTheme.bodyText1,
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Facilities
                      if (kamar.fasilitas != null && kamar.fasilitas!.isNotEmpty) ...[
                        Text(
                          'Fasilitas',
                          style: AppTheme.heading3,
                        ),
                        const SizedBox(height: 8),
                        ...kamar.fasilitas!.map((fasilitas) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                fasilitas,
                                style: AppTheme.bodyText1,
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
