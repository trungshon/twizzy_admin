import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_page.dart';
import '../users/users_page.dart';
import '../twizzs/twizzs_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard, label: 'Tổng quan'),
    _NavItem(icon: Icons.people, label: 'Người dùng'),
    _NavItem(icon: Icons.article, label: 'Bài viết'),
  ];

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const UsersPage();
      case 2:
        return const TwizzsPage();
      default:
        return const DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 800;
    final navWidth = isWideScreen ? 220.0 : 72.0;

    return Scaffold(
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Row(
          children: [
            // Side Navigation
            SizedBox(
              width: navWidth,
              height: screenHeight,
              child: Container(
                color: AppTheme.surfaceColor,
                child: Column(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                          ),
                          if (isWideScreen) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Twizzy Admin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Navigation Items
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        children:
                            _navItems.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected =
                                  _selectedIndex == index;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                child:
                                    isWideScreen
                                        ? ListTile(
                                          leading: Icon(
                                            item.icon,
                                            color:
                                                isSelected
                                                    ? AppTheme
                                                        .primaryColor
                                                    : AppTheme
                                                        .textSecondary,
                                          ),
                                          title: Text(
                                            item.label,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? AppTheme
                                                          .primaryColor
                                                      : AppTheme
                                                          .textPrimary,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight
                                                          .bold
                                                      : FontWeight
                                                          .normal,
                                            ),
                                          ),
                                          selected: isSelected,
                                          selectedTileColor:
                                              AppTheme
                                                  .primaryColor
                                                  .withValues(
                                                    alpha: 0.1,
                                                  ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  8,
                                                ),
                                          ),
                                          onTap:
                                              () => setState(
                                                () =>
                                                    _selectedIndex =
                                                        index,
                                              ),
                                        )
                                        : IconButton(
                                          icon: Icon(
                                            item.icon,
                                            color:
                                                isSelected
                                                    ? AppTheme
                                                        .primaryColor
                                                    : AppTheme
                                                        .textSecondary,
                                          ),
                                          tooltip: item.label,
                                          onPressed:
                                              () => setState(
                                                () =>
                                                    _selectedIndex =
                                                        index,
                                              ),
                                        ),
                              );
                            }).toList(),
                      ),
                    ),

                    // User Info & Logout
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme
                                .primaryColor
                                .withValues(alpha: 0.1),
                            child: Text(
                              authViewModel
                                          .currentUser
                                          ?.name
                                          .isNotEmpty ==
                                      true
                                  ? authViewModel
                                      .currentUser!
                                      .name[0]
                                      .toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          if (isWideScreen) ...[
                            const SizedBox(height: 8),
                            Text(
                              authViewModel.currentUser?.name ??
                                  'Admin',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Quản trị viên',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          if (isWideScreen)
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(
                                  Icons.logout,
                                  size: 18,
                                ),
                                label: const Text('Đăng xuất'),
                                onPressed: () async {
                                  await authViewModel.logout();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  }
                                },
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.logout),
                              tooltip: 'Đăng xuất',
                              onPressed: () async {
                                await authViewModel.logout();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            const VerticalDivider(thickness: 1, width: 1),

            // Main Content
            Expanded(
              child: SizedBox(
                height: screenHeight,
                child: _getPage(_selectedIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem({required this.icon, required this.label});
}
