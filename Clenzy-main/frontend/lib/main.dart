import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/partner/completed_jobs_screen.dart';
import 'screens/partner/completed_job_details_screen.dart';
import 'screens/partner/job_requests_screen.dart';
import 'screens/admin/admin_users_details_screen.dart';
import 'screens/admin/admin_partners_details_screen.dart';
import 'screens/admin/admin_jobs_details_screen.dart';
import 'screens/admin/admin_revenue_details_screen.dart';
import 'screens/admin/admin_approvals_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ClenzyApp());
}

class ClenzyApp extends StatefulWidget {
  const ClenzyApp({super.key});

  @override
  State<ClenzyApp> createState() => _ClenzyAppState();
}

class _ClenzyAppState extends State<ClenzyApp> {
  final ThemeProvider _themeProvider = ThemeProvider.instance;

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
    // Update status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _themeProvider.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clenzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.themeMode,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/completedJobs': (context) => const CompletedJobsScreen(),
        '/completedJobDetails': (context) => const CompletedJobDetailsScreen(),
        '/jobRequests': (context) => const JobRequestsScreen(),
        '/admin/users': (context) => const UsersDetailsScreen(),
        '/admin/partners': (context) => const AdminPartnersDetailsScreen(),
        '/admin/jobs': (context) => const AdminJobsDetailsScreen(),
        '/admin/revenue': (context) => const AdminRevenueDetailsScreen(),
        '/admin/approvals': (context) => const AdminApprovalsScreen(),
      },
    );
  }
}
