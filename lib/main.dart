import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_hub/features/admin/dashboard/pages/admin_dashboard_page.dart';
import 'package:study_hub/features/auth/pages/auth_page.dart';
import 'package:study_hub/features/user/dashboard/pages/user_dashboard_page.dart';

final _router = GoRouter(
  initialLocation: '/admin',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthPage()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const UserDashboardPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyHubApp());
}

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ← changed from MaterialApp
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      routerConfig: _router, // ← add this, remove `home:`
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF0D0D0D),
        ),
      ),
    );
  }
}
