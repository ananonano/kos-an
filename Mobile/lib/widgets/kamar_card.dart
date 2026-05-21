import 'package:flutter/material.dart';
import '../models/kamar_model.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/helpers.dart';

/// Kamar Card Widget
/// Card untuk menampilkan info kamar
class KamarCard extends StatelessWidget {
  final KamarModel kamar;
  final VoidCallback onTap;
  
  const KamarCard({
    Key? key,
    required this.kamar,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isKosong = kamar.status == 'kosong';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isKosong 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.meeting_room,
                  size: 32,
                  color: isKosong ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kamar ${kamar.nomorKamar}',
                      style: AppTheme.heading3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kamar.tipe,
                      style: AppTheme.bodyText2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(kamar.harga),
                      style: AppTheme.bodyText1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isKosong ? AppTheme.successColor : AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  Helpers.getStatusLabel(kamar.status),
                  style: AppTheme.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
