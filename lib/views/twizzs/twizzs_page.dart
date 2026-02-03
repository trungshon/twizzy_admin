import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/twizzs_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/twizz_model.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;
import '../../widgets/twizz_card.dart';

class TwizzsPage extends StatefulWidget {
  const TwizzsPage({super.key});

  @override
  State<TwizzsPage> createState() => _TwizzsPageState();
}

class _TwizzsPageState extends State<TwizzsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<TwizzsViewModel>();
    Future.microtask(() {
      viewModel.loadTwizzs(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(Twizz twizz) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bạn có chắc muốn xóa?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    twizz.content.length > 100
                        ? '${twizz.content.substring(0, 100)}...'
                        : twizz.content,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                onPressed: () async {
                  final viewModel =
                      context.read<TwizzsViewModel>();
                  final messenger = ScaffoldMessenger.of(
                    context,
                  );
                  Navigator.pop(context);
                  final success = await viewModel.deleteTwizz(
                    twizz.id,
                  );
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa thành công'),
                      ),
                    );
                  }
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TwizzsViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quản lý Bài viết',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (viewModel.isLoading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Search and Filters
              Row(
                children: [
                  // Search
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm theo nội dung...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    viewModel.setSearchQuery('');
                                  },
                                )
                                : null,
                      ),
                      onSubmitted: viewModel.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Type Filter
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: viewModel.filterType,
                      decoration: const InputDecoration(
                        labelText: 'Loại',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        DropdownMenuItem(
                          value: 0,
                          child: Text('Bài viết'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Bình luận'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Trích dẫn'),
                        ),
                      ],
                      onChanged: viewModel.setFilterType,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Twizzs List
              Expanded(
                child: Card(
                  child:
                      viewModel.twizzs.isEmpty &&
                              !viewModel.isLoading
                          ? const Center(
                            child: Text(
                              'Không tìm thấy bài viết',
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: viewModel.twizzs.length,
                            separatorBuilder:
                                (_, __) =>
                                    const Divider(height: 32),
                            itemBuilder: (context, index) {
                              final twizz =
                                  viewModel.twizzs[index];
                              return TwizzCard(
                                twizz: twizz,
                                onDelete:
                                    () =>
                                        _showDeleteDialog(twizz),
                              );
                            },
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Pagination
              if (viewModel.pagination != null)
                _Pagination(
                  pagination: viewModel.pagination!,
                  onPageChange: viewModel.goToPage,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Pagination extends StatelessWidget {
  final dynamic pagination;
  final Function(int) onPageChange;

  const _Pagination({
    required this.pagination,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hiển thị ${((pagination.page - 1) * pagination.limit) + 1} - ${(pagination.page * pagination.limit).clamp(0, pagination.total)} của ${pagination.total}',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              pagination.page > 1
                  ? () => onPageChange(pagination.page - 1)
                  : null,
        ),
        for (int i = 1; i <= pagination.totalPages; i++)
          if (i <= 5 ||
              i == pagination.totalPages ||
              (i - pagination.page).abs() <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed:
                    i != pagination.page
                        ? () => onPageChange(i)
                        : null,
                style: TextButton.styleFrom(
                  backgroundColor:
                      i == pagination.page
                          ? AppTheme.primaryColor
                          : null,
                  foregroundColor:
                      i == pagination.page ? Colors.white : null,
                  minimumSize: const Size(40, 40),
                ),
                child: Text('$i'),
              ),
            ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              pagination.page < pagination.totalPages
                  ? () => onPageChange(pagination.page + 1)
                  : null,
        ),
      ],
    );
  }
}
