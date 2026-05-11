import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_hub/features/admin/dashboard/pages/admin_dashboard_page.dart';
import 'package:study_hub/features/auth/pages/auth_page.dart';
import 'package:study_hub/features/user/dashboard/pages/user_dashboard_page.dart';
import 'package:study_hub/core/theme/app_theme.dart';

final appRouter = GoRouter(
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

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
    );
  }
}
