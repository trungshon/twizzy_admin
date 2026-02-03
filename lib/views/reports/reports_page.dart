import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/reports_viewmodel.dart';
import '../../models/report_model.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/twizz_card.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsViewModel>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý báo cáo'),
        actions: [
          Consumer<ReportsViewModel>(
            builder: (context, viewModel, child) {
              return DropdownButton<int?>(
                value: viewModel.selectedStatus,
                hint: const Text('Lọc theo trạng thái'),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Tất cả'),
                  ),
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Chờ xử lý'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Đã giải quyết'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Bỏ qua'),
                  ),
                ],
                onChanged: (value) {
                  viewModel.changeStatusFilter(value);
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ReportsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Text('Lỗi: ${viewModel.error}'),
            );
          }

          if (viewModel.reports.isEmpty) {
            return const Center(
              child: Text('Không có báo cáo nào'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.reports.length,
            itemBuilder: (context, index) {
              final report = viewModel.reports[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lý do: ${report.reason.label}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildStatusBadge(report.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Người báo cáo: ${report.reporter?.name ?? report.userId}',
                      ),
                      Text(
                        'Ngày báo cáo: ${DateFormat('MMM d, yyyy • HH:mm').format(report.createdAt.toLocal())}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (report.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Mô tả: ${report.description}'),
                      ],
                      if (report.status !=
                              ReportStatus.pending &&
                          report.action != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                            border: Border.all(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cách xử lý: ${_getActionLabel(report.action!)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Divider(),
                      if (report.twizz != null) ...[
                        const Text(
                          'Nội dung bị báo cáo:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TwizzCard(
                          twizz: report.twizz!,
                          showDelete: false,
                          onDelete: () {},
                        ),
                        if (report.twizz?.user != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (report
                                              .twizz!
                                              .user!
                                              .violationCount >
                                          0
                                      ? Colors.red
                                      : Colors.blue)
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(4),
                              border: Border.all(
                                color: (report
                                                .twizz!
                                                .user!
                                                .violationCount >
                                            0
                                        ? Colors.red
                                        : Colors.blue)
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color:
                                      report
                                                  .twizz!
                                                  .user!
                                                  .violationCount >
                                              0
                                          ? Colors.red
                                          : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Số lần vi phạm của người này: ${report.twizz!.user!.violationCount}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        report
                                                    .twizz!
                                                    .user!
                                                    .violationCount >
                                                0
                                            ? Colors.red
                                            : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 12),
                      if (report.status == ReportStatus.pending)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed:
                                  () => viewModel.handleReport(
                                    report.id,
                                    'ignore',
                                  ),
                              child: const Text('Bỏ qua'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed:
                                  () => viewModel.handleReport(
                                    report.id,
                                    'delete',
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Xóa bài'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed:
                                  () => viewModel.handleReport(
                                    report.id,
                                    'ban',
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Khóa người dùng',
                              ),
                            ),
                          ],
                        ),
                      if (report.status != ReportStatus.pending)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final confirmed =
                                    await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (
                                            context,
                                          ) => AlertDialog(
                                            title: const Text(
                                              'Xác nhận xóa',
                                            ),
                                            content: const Text(
                                              'Bạn có chắc chắn muốn xóa báo cáo này không?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                child:
                                                    const Text(
                                                      'Hủy',
                                                    ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppTheme
                                                          .errorColor,
                                                ),
                                                child:
                                                    const Text(
                                                      'Xóa',
                                                    ),
                                              ),
                                            ],
                                          ),
                                    ) ??
                                    false;

                                if (confirmed &&
                                    context.mounted) {
                                  try {
                                    await context
                                        .read<ReportsViewModel>()
                                        .deleteReport(report.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đã xóa báo cáo',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lỗi: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.delete_forever,
                              ),
                              label: const Text('Xóa báo cáo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.errorColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color color;
    String label;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.blue;
        label = 'Chờ xử lý';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        label = 'Đã giải quyết';
        break;
      case ReportStatus.ignored:
        color = Colors.grey;
        label = 'Bỏ qua';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'delete':
        return 'Xóa bài viết';
      case 'ban':
        return 'Khóa người dùng';
      case 'ignore':
        return 'Bỏ qua báo cáo';
      default:
        return action;
    }
  }
}
