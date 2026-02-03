import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/users_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<UsersViewModel>();
    Future.microtask(() {
      viewModel.loadUsers(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStatusDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _StatusChangeDialog(user: user),
    );
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa người dùng'),
            content: Text(
              'Bạn có chắc muốn xóa "${user.name}"? Hành động này không thể hoàn tác.',
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
                  Navigator.pop(context);
                  final success = await context
                      .read<UsersViewModel>()
                      .deleteUser(user.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đã xóa người dùng thành công',
                        ),
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
    return Consumer<UsersViewModel>(
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
                    'Quản lý Người dùng',
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
                        hintText:
                            'Tìm theo tên, email hoặc username...',
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

                  // Status Filter
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: viewModel.filterStatus,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
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
                          child: Text('Chưa xác minh'),
                        ),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Đã xác minh'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Bị cấm'),
                        ),
                      ],
                      onChanged: viewModel.setFilterStatus,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Users Table
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 48), // Avatar space
                            SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Người dùng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Status',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Vi phạm',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Ngày tham gia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Thao tác',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Table Body
                      Expanded(
                        child:
                            viewModel.users.isEmpty &&
                                    !viewModel.isLoading
                                ? const Center(
                                  child: Text(
                                    'Không tìm thấy người dùng',
                                  ),
                                )
                                : ListView.separated(
                                  itemCount:
                                      viewModel.users.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(
                                        height: 1,
                                      ),
                                  itemBuilder: (context, index) {
                                    final user =
                                        viewModel.users[index];
                                    return _UserRow(
                                      user: user,
                                      onStatusChange:
                                          () =>
                                              _showStatusDialog(
                                                user,
                                              ),
                                      onDelete:
                                          () =>
                                              _showDeleteDialog(
                                                user,
                                              ),
                                    );
                                  },
                                ),
                      ),
                    ],
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

class _UserRow extends StatelessWidget {
  final User user;
  final VoidCallback onStatusChange;
  final VoidCallback onDelete;

  const _UserRow({
    required this.user,
    required this.onStatusChange,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (user.verify) {
      case 0:
        return AppTheme.unverifiedColor;
      case 1:
        return AppTheme.verifiedColor;
      case 2:
        return AppTheme.bannedColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getImageUrl(String? url) {
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
    return '${AppConstants.baseUrl}/static/image/$finalUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withValues(
              alpha: 0.1,
            ),
            backgroundImage:
                user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(_getImageUrl(user.avatar!))
                    : null,
            child:
                user.avatar == null || user.avatar!.isEmpty
                    ? Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
          const SizedBox(width: 16),

          // Name & Username
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Email
          Expanded(
            flex: 2,
            child: Text(
              user.email,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.verifyStatusText,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Violations
          Expanded(
            child: Text(
              '${user.violationCount}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    user.violationCount > 0
                        ? AppTheme.errorColor
                        : AppTheme.textSecondary,
                fontWeight:
                    user.violationCount > 0
                        ? FontWeight.bold
                        : null,
              ),
            ),
          ),

          // Joined Date
          Expanded(
            child: Text(
              DateFormat('MMM d, yyyy').format(user.createdAt),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                  tooltip: 'Đổi trạng thái',
                  onPressed: onStatusChange,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppTheme.errorColor,
                  ),
                  tooltip: 'Xóa',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChangeDialog extends StatefulWidget {
  final User user;

  const _StatusChangeDialog({required this.user});

  @override
  State<_StatusChangeDialog> createState() =>
      _StatusChangeDialogState();
}

class _StatusChangeDialogState
    extends State<_StatusChangeDialog> {
  late int _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.user.verify;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Đổi trạng thái cho ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<int>(
            title: const Text('Chưa xác minh'),
            value: 0,
            groupValue: _selectedStatus,
            onChanged:
                (value) =>
                    setState(() => _selectedStatus = value!),
          ),
          RadioListTile<int>(
            title: const Text('Đã xác minh'),
            value: 1,
            groupValue: _selectedStatus,
            onChanged:
                (value) =>
                    setState(() => _selectedStatus = value!),
          ),
          RadioListTile<int>(
            title: const Text('Bị cấm'),
            value: 2,
            groupValue: _selectedStatus,
            onChanged:
                (value) =>
                    setState(() => _selectedStatus = value!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            final success = await context
                .read<UsersViewModel>()
                .updateUserStatus(
                  widget.user.id,
                  _selectedStatus,
                );
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đã cập nhật trạng thái thành công',
                  ),
                ),
              );
            }
          },
          child: const Text('Lưu'),
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
