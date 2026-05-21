import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Helper Functions
/// Menyediakan fungsi-fungsi helper yang sering digunakan
class Helpers {
  // Format Currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  // Format Date
  static String formatDate(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormat);
    return formatter.format(date);
  }
  
  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat(AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }
  
  // Format Time
  static String formatTime(DateTime time) {
    final formatter = DateFormat(AppConstants.timeFormat);
    return formatter.format(time);
  }
  
  // Parse Date
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Get Status Color
  static String getStatusColor(String status) {
    switch (status) {
      case AppConstants.pembayaranLunas:
      case AppConstants.keluhanSelesai:
        return 'success';
      case AppConstants.pembayaranMenungguVerifikasi:
      case AppConstants.keluhanDiproses:
        return 'warning';
      case AppConstants.pembayaranBelumLunas:
      case AppConstants.keluhanBaru:
        return 'info';
      case AppConstants.pembayaranDitolak:
      case AppConstants.keluhanDitolak:
        return 'error';
      default:
        return 'default';
    }
  }
  
  // Get Status Label
  static String getStatusLabel(String status) {
    switch (status) {
      case AppConstants.pembayaranBelumLunas:
        return 'Belum Lunas';
      case AppConstants.pembayaranMenungguVerifikasi:
        return 'Menunggu Verifikasi';
      case AppConstants.pembayaranLunas:
        return 'Lunas';
      case AppConstants.pembayaranDitolak:
        return 'Ditolak';
      case AppConstants.keluhanBaru:
        return 'Baru';
      case AppConstants.keluhanDiproses:
        return 'Diproses';
      case AppConstants.keluhanSelesai:
        return 'Selesai';
      case AppConstants.keluhanDitolak:
        return 'Ditolak';
      case AppConstants.kamarKosong:
        return 'Kosong';
      case AppConstants.kamarTerisi:
        return 'Terisi';
      default:
        return status;
    }
  }
  
  // Calculate File Size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
  
  // Get Relative Time
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
