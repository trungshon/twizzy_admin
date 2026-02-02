import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/twizzs_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/twizz_model.dart';
import '../../core/constants/app_constants.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

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
                              return _TwizzCard(
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

class _TwizzCard extends StatelessWidget {
  final Twizz twizz;
  final VoidCallback onDelete;

  const _TwizzCard({
    required this.twizz,
    required this.onDelete,
  });

  Color get _typeColor {
    switch (twizz.type) {
      case 0:
        return AppTheme.primaryColor;
      case 1:
        return AppTheme.successColor;
      case 2:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMediaUrl(String? url, {bool isVideo = false}) {
    if (url == null || url.isEmpty) return '';
    String finalUrl = url;
    // Replace emulator IP with localhost for web
    if (finalUrl.contains('10.0.2.2')) {
      finalUrl = finalUrl.replaceAll('10.0.2.2', 'localhost');
    }
    if (finalUrl.startsWith('http')) return finalUrl;
    if (finalUrl.startsWith('/')) {
      return '${AppConstants.baseUrl}$finalUrl';
    }
    final String path = isVideo ? 'video-stream' : 'image';
    return '${AppConstants.baseUrl}/static/$path/$finalUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withValues(
            alpha: 0.1,
          ),
          backgroundImage:
              twizz.user?.avatar != null &&
                      twizz.user!.avatar!.isNotEmpty
                  ? NetworkImage(
                    _getMediaUrl(twizz.user!.avatar!),
                  )
                  : null,
          child:
              twizz.user?.avatar == null ||
                      twizz.user!.avatar!.isEmpty
                  ? Text(
                    twizz.user?.name.isNotEmpty == true
                        ? twizz.user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info & Type
              Row(
                children: [
                  if (twizz.user != null) ...[
                    Text(
                      twizz.user!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${twizz.user!.username}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      twizz.typeText,
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              Text(
                twizz.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Media (Images/Videos)
              if (twizz.medias.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: twizz.medias.length,
                    separatorBuilder:
                        (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final media = twizz.medias[index];
                      // type 0 = image, type 1 = video
                      if (media.type == 0) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _getMediaUrl(media.url),
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 150,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    color:
                                        AppTheme.textSecondary,
                                  ),
                                ),
                          ),
                        );
                      } else {
                        // Web Video Player
                        return Container(
                          height: 150,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                            child: _WebVideoPlayer(
                              url: _getMediaUrl(
                                media.url,
                                isVideo: true,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Stats & Actions
              Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${twizz.totalViews} lượt xem',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'MMM d, yyyy • HH:mm',
                    ).format(twizz.createdAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppTheme.errorColor,
                    ),
                    label: const Text(
                      'Xóa',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                      ),
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

class _WebVideoPlayer extends StatelessWidget {
  final String url;
  const _WebVideoPlayer({required this.url});

  @override
  Widget build(BuildContext context) {
    // Unique view type for each video to prevent recycling issues
    final String viewType = 'video-$url';

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) =>
          (web.document.createElement('video')
                as web.HTMLVideoElement)
            ..src = url
            ..controls = true
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.backgroundColor = 'black',
    );

    return HtmlElementView(viewType: viewType);
  }
}
