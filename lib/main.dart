import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/users_viewmodel.dart';
import 'viewmodels/twizzs_viewmodel.dart';
import 'viewmodels/reports_viewmodel.dart';
import 'views/auth/login_page.dart';
import 'views/main/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  await ApiService().init();

  runApp(const TwizzyAdminApp());
}

class TwizzyAdminApp extends StatelessWidget {
  const TwizzyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(),
        ),
        ChangeNotifierProvider(create: (_) => UsersViewModel()),
        ChangeNotifierProvider(create: (_) => TwizzsViewModel()),
        ChangeNotifierProvider(
          create: (_) => ReportsViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Twizzy Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGuard(child: MainShell()),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _redirected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        // Show loading while initializing
        if (!auth.isInitialized || auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect to login if not authenticated or not admin
        if (!auth.isAuthenticated || !auth.isAdmin) {
          if (!_redirected) {
            _redirected = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return widget.child;
      },
    );
  }
}
