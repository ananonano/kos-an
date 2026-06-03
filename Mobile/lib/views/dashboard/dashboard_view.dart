import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

/// Dashboard View
/// Tampilan dashboard dengan statistik dan grafik (persis seperti web)
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final dashboardController = context.read<DashboardController>();
    await dashboardController.getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userName = authController.currentUser?.nama.split(' ')[0] ?? 'Admin';

    return Consumer<DashboardController>(
      builder: (context, dashboardController, child) {
        if (dashboardController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (dashboardController.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    dashboardController.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText1,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDashboard,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Text(
                  'Selamat datang, $userName 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berikut ringkasan aktivitas kos Anda hari ini',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Grid - 8 cards seperti web
                _buildStatsGrid(dashboardController),

                const SizedBox(height: 20),

                // Grafik Pemasukan Bulanan
                _buildMonthlyIncomeChart(),

                const SizedBox(height: 20),

                // Status Kamar Card
                _buildRoomStatusCard(dashboardController),

                const SizedBox(height: 20),

                // Aktivitas Terbaru
                _buildRecentActivities(),

                const SizedBox(height: 20),

                // Pembayaran Pending
                _buildPendingPayments(dashboardController),
              ],
            ),
          ),
        );
      },
    );
  }

  // Stats Grid - 8 cards seperti web
  Widget _buildStatsGrid(DashboardController controller) {
    final stats = [
      {
        'title': 'Total Penghuni',
        'value': '${controller.totalTenants}',
        'subtitle': 'Penghuni aktif',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Total Kamar',
        'value': '${controller.totalRooms}',
        'subtitle': '${controller.occupiedRooms} terisi, ${controller.availableRooms} kosong',
        'icon': Icons.bed,
        'color': Colors.indigo,
      },
      {
        'title': 'Kamar Tersedia',
        'value': '${controller.availableRooms}',
        'subtitle': 'Siap dihuni',
        'icon': Icons.door_front_door,
        'color': Colors.green,
      },
      {
        'title': 'Total Pemasukan',
        'value': _formatCurrency(controller.totalIncome),
        'subtitle': 'Bulan ini',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
      {
        'title': 'Tagihan Belum Bayar',
        'value': '${controller.unpaidBills}',
        'subtitle': 'Perlu tindakan',
        'icon': Icons.warning_amber,
        'color': Colors.orange,
      },
      {
        'title': 'Pembayaran Pending',
        'value': '${controller.pendingPaymentsCount}',
        'subtitle': 'Menunggu verifikasi',
        'icon': Icons.access_time,
        'color': Colors.red,
      },
      {
        'title': 'Keluhan Pending',
        'value': '${controller.pendingMaintenance}',
        'subtitle': 'Perlu ditangani',
        'icon': Icons.build,
        'color': Colors.amber,
      },
      {
        'title': 'Kamar Terisi',
        'value': '${controller.occupiedRooms}',
        'subtitle': '${controller.occupancyRate.toStringAsFixed(0)}% occupancy rate',
        'icon': Icons.meeting_room,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          subtitle: stat['subtitle'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
        );
      },
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Grafik Pemasukan Bulanan
  Widget _buildMonthlyIncomeChart() {
    // Data dummy untuk grafik (seperti di web)
    final monthlyData = [
      {'month': 'Jan', 'income': 36000000.0},
      {'month': 'Feb', 'income': 38000000.0},
      {'month': 'Mar', 'income': 40000000.0},
      {'month': 'Apr', 'income': 42000000.0},
      {'month': 'Mei', 'income': 44000000.0},
      {'month': 'Jun', 'income': 46000000.0},
      {'month': 'Jul', 'income': 48000000.0},
      {'month': 'Agu', 'income': 45000000.0},
      {'month': 'Sep', 'income': 47000000.0},
      {'month': 'Okt', 'income': 50000000.0},
      {'month': 'Nov', 'income': 48000000.0},
      {'month': 'Des', 'income': 52000000.0},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemasukan Bulanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Grafik pemasukan 12 bulan terakhir',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10000000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000000).toInt()}jt',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                monthlyData[value.toInt()]['month'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (monthlyData.length - 1).toDouble(),
                  minY: 30000000,
                  maxY: 55000000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['income'] as double),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            _formatCurrencyFull(spot.y),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Status Kamar Card
  Widget _buildRoomStatusCard(DashboardController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Kamar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Distribusi kamar saat ini',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _buildRoomStatusBar(
              'Terisi',
              controller.occupiedRooms,
              controller.totalRooms,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildRoomStatusBar(
              'Tersedia',
              controller.availableRooms,
              controller.totalRooms,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildRoomStatusBar(
              'Perbaikan',
              controller.totalRooms - controller.occupiedRooms - controller.availableRooms,
              controller.totalRooms,
              Colors.amber,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${controller.occupancyRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Occupancy Rate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomStatusBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$value kamar',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Aktivitas Terbaru
  Widget _buildRecentActivities() {
    final activities = [
      {'icon': '💰', 'text': 'Pembayaran dari Budi Santoso diverifikasi', 'time': '2 jam lalu'},
      {'icon': '🔧', 'text': 'Keluhan AC kamar 101 sedang diproses', 'time': '5 jam lalu'},
      {'icon': '👤', 'text': 'Ahmad Fauzi ditambahkan sebagai penghuni baru', 'time': '1 hari lalu'},
      {'icon': '📢', 'text': 'Pengumuman jadwal pemadaman listrik dikirim', 'time': '2 hari lalu'},
      {'icon': '📄', 'text': 'Tagihan bulan Mei 2026 berhasil digenerate', 'time': '3 hari lalu'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Log aktivitas sistem',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      activity['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['text'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity['time'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Pembayaran Pending
  Widget _buildPendingPayments(DashboardController controller) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pembayaran Pending',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Menunggu verifikasi admin',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            if (controller.pendingPayments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Tidak ada pembayaran pending',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              ...controller.pendingPayments.take(5).map((payment) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pembayaran #${payment['id']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(DateTime.parse(
                                payment['tanggal_bayar'] ?? payment['created_at']
                              )),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(payment['jumlah']),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // Helper functions
  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  String _formatCurrencyFull(double amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(amount);
  }
}
