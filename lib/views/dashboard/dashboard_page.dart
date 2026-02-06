import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/dashboard_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DashboardViewModel>();
    Future.microtask(() {
      viewModel.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.stats == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null && viewModel.stats == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(viewModel.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadDashboard(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final stats = viewModel.stats;
        if (stats == null) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng quan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Làm mới',
                      onPressed: () => viewModel.loadDashboard(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards - only 3 cards now (removed Total Likes)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth > 1200
                            ? 3
                            : constraints.maxWidth > 600
                            ? 3
                            : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8,
                      children: [
                        _StatCard(
                          title: 'Tổng người dùng',
                          value: stats.users.total.toString(),
                          subtitle:
                              '+${stats.users.newToday} hôm nay',
                          icon: Icons.people,
                          color: AppTheme.primaryColor,
                        ),
                        _StatCard(
                          title: 'Người dùng đã xác minh',
                          value: stats.users.verified.toString(),
                          subtitle:
                              '${((stats.users.verified / (stats.users.total > 0 ? stats.users.total : 1)) * 100).toStringAsFixed(1)}% tổng số',
                          icon: Icons.verified_user,
                          color: AppTheme.verifiedColor,
                        ),
                        _StatCard(
                          title: 'Tổng Bài viết',
                          value: stats.twizzs.total.toString(),
                          subtitle:
                              '+${stats.twizzs.newToday} hôm nay',
                          icon: Icons.article,
                          color: AppTheme.infoColor,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // User Status Breakdown
                Row(
                  children: [
                    Expanded(
                      child: _StatusBreakdownCard(
                        title: 'Trạng thái người dùng',
                        items: [
                          _StatusItem(
                            'Đã xác minh',
                            stats.users.verified,
                            AppTheme.verifiedColor,
                          ),
                          _StatusItem(
                            'Chưa xác minh',
                            stats.users.unverified,
                            AppTheme.unverifiedColor,
                          ),
                          _StatusItem(
                            'Bị cấm',
                            stats.users.banned,
                            AppTheme.bannedColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Growth Chart with Period Selector
                if (viewModel.growthData.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biểu đồ tăng trưởng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Period Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: viewModel.selectedDays,
                            dropdownColor: AppTheme.cardColor,
                            items: const [
                              DropdownMenuItem(
                                value: 7,
                                child: Text('7 ngày qua'),
                              ),
                              DropdownMenuItem(
                                value: 14,
                                child: Text('14 ngày qua'),
                              ),
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 ngày qua'),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text('60 ngày qua'),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text('90 ngày qua'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.changeGrowthPeriod(
                                  value,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Legend
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Người dùng mới',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor,
                                  borderRadius:
                                      BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Bài viết mới',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child:
                                viewModel.isLoading
                                    ? const Center(
                                      child:
                                          CircularProgressIndicator(),
                                    )
                                    : _GrowthChart(
                                      data: viewModel.growthData,
                                    ),
                          ),
                          const SizedBox(height: 16),

                          // Chart Navigation Arrows
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed:
                                    viewModel.isLoading
                                        ? null
                                        : () =>
                                            viewModel
                                                .previousPeriod(),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 16,
                                ),
                                label: const Text('Cũ hơn'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 32),
                              TextButton.icon(
                                onPressed:
                                    viewModel.isLoading ||
                                            viewModel.offset == 0
                                        ? null
                                        : () =>
                                            viewModel
                                                .nextPeriod(),
                                icon: const Text('Mới hơn'),
                                label: const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem {
  final String label;
  final int value;
  final Color color;

  _StatusItem(this.label, this.value, this.color);
}

class _StatusBreakdownCard extends StatelessWidget {
  final String title;
  final List<_StatusItem> items;

  const _StatusBreakdownCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(
      0,
      (sum, item) => sum + item.value,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children:
                  items.where((item) => item.value > 0).map((
                    item,
                  ) {
                    final percentage =
                        total > 0 ? (item.value / total) : 0.0;
                    return Expanded(
                      flex: (percentage * 100).round().clamp(
                        1,
                        100,
                      ),
                      child: Container(
                        height: 8,
                        color: item.color,
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children:
                  items.map((item) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(
                              2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.label}: ${item.value}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrowthChart extends StatelessWidget {
  final List<GrowthData> data;

  const _GrowthChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final maxUsers = data
        .map((e) => e.users)
        .reduce((a, b) => a > b ? a : b);
    final maxTwizzs = data
        .map((e) => e.twizzs)
        .reduce((a, b) => a > b ? a : b);
    final maxY =
        (maxUsers > maxTwizzs ? maxUsers : maxTwizzs)
            .toDouble() +
        1;

    // Calculate label interval based on data length
    final labelInterval =
        data.length > 14
            ? (data.length / 7).ceil().toDouble()
            : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppTheme.cardColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: labelInterval,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  final parts = date.split('-');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${parts[1]}/${parts[2]}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY > 0 ? maxY / 4 : 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots:
                data.asMap().entries.map((e) {
                  return FlSpot(
                    e.key.toDouble(),
                    e.value.users.toDouble(),
                  );
                }).toList(),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: data.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withValues(
                alpha: 0.1,
              ),
            ),
          ),
          LineChartBarData(
            spots:
                data.asMap().entries.map((e) {
                  return FlSpot(
                    e.key.toDouble(),
                    e.value.twizzs.toDouble(),
                  );
                }).toList(),
            isCurved: true,
            color: AppTheme.successColor,
            barWidth: 3,
            dotData: FlDotData(show: data.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.successColor.withValues(
                alpha: 0.1,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isUsers = spot.barIndex == 0;
                return LineTooltipItem(
                  '${isUsers ? 'Người dùng' : 'Bài viết'}: ${spot.y.toInt()}',
                  TextStyle(
                    color:
                        isUsers
                            ? AppTheme.primaryColor
                            : AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
