import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import 'package:study_hub/features/admin/repository/admin_repository.dart';
// Tabs
import 'tabs/overview_tab.dart';
import 'tabs/global_resources_tab.dart';
import 'tabs/user_uploads_tab.dart';
import 'tabs/users_tab.dart';
import 'tabs/my_resources_tab.dart';
import 'tabs/profile_tab.dart';
// Shared widgets
import 'widgets/theme_helper.dart';
import 'widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE  —  only wires BLoC + Scaffold + Navbar + PageSwitcher
// All tab content lives in tabs/*.dart
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc()..add(AdminStarted()),
      child: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Scaffold(
              backgroundColor: AppColors.darkBg,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          if (state is AdminError) {
            return Scaffold(body: Center(child: Text(state.message)));
          }
          if (state is AdminLoaded) {
            final t = AdminTheme(state.isDarkMode);
            return Scaffold(
              backgroundColor: t.bg,
              body: BlocListener<AdminBloc, AdminState>(
                listener: (context, s) {
                  if (s is AdminLoaded) {
                    if (s.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snack(s.successMessage!, t, isError: false),
                      );
                    }
                    if (s.errorMessage != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(_snack(s.errorMessage!, t, isError: true));
                    }
                  }
                },
                child: Column(
                  children: [
                    _CombinedNavbar(
                      t: t,
                      currentAdminName: state.currentAdminName,
                      currentAdminEmail: state.currentAdminEmail,
                      activeTab: state.activeTab,
                    ),
                    Expanded(
                      child: AdminAnimatedPageSwitcher(
                        index: state.activeTab.index,
                        pages: [
                          OverviewTab(state: state, t: t),
                          GlobalResourcesTab(state: state, t: t),
                          UserUploadsTab(state: state, t: t),
                          UsersTab(state: state, t: t),
                          MyResourcesTab(state: state, t: t),
                          ProfileTab(state: state, t: t),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  SnackBar _snack(String msg, AdminTheme t, {required bool isError}) {
    return SnackBar(
      backgroundColor: isError ? const Color(0xFF2A1010) : t.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isError ? const Color(0xFF4A1A1A) : t.border),
      ),
      content: Text(
        msg,
        style: TextStyle(
          fontSize: 12,
          color: isError ? const Color(0xFFFF6B6B) : t.text,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMBINED NAVBAR  —  unchanged from original
// ─────────────────────────────────────────────────────────────────────────────
class _CombinedNavbar extends StatelessWidget {
  final AdminTheme t;
  final String currentAdminName;
  final String currentAdminEmail;
  final AdminTab activeTab;

  const _CombinedNavbar({
    required this.t,
    required this.currentAdminName,
    required this.currentAdminEmail,
    required this.activeTab,
  });

  String get _initials {
    if (currentAdminName.trim().isEmpty) return '?';
    final parts = currentAdminName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return currentAdminName[0].toUpperCase();
  }

  void _showMobileMenu(BuildContext context) {
    final bloc = context.read<AdminBloc>();
    final tabs = [
      (AdminTab.overview, 'Overview', Icons.home_outlined),
      (AdminTab.globalResources, 'Global Resources', Icons.folder_outlined),
      (AdminTab.userUploads, 'User Uploads', Icons.upload_outlined),
      (AdminTab.users, 'Users', Icons.people_outline),
      (AdminTab.myResources, 'My Resources', Icons.my_library_books_outlined),
      (AdminTab.profile, 'Profile', Icons.person_outline),
    ];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sidebar',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      pageBuilder: (dialogContext, _, __) {
        return BlocProvider.value(
          value: bloc,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (dialogContext, sidebarState) {
                  final sidebarT = sidebarState is AdminLoaded
                      ? AdminTheme(sidebarState.isDarkMode)
                      : t;
                  return Container(
                    width: 260,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: sidebarT.surface,
                      border: Border(right: BorderSide(color: sidebarT.border)),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: sidebarT.isDark
                                        ? Colors.white
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Icon(
                                    Icons.book_rounded,
                                    size: 15,
                                    color: sidebarT.isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'StudyHub',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                    color: sidebarT.text,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sidebarT.isDark
                                        ? Colors.white.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: sidebarT.border2),
                                  ),
                                  child: Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: sidebarT.textMuted,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: sidebarT.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: sidebarT.border, height: 1),
                          // Nav items
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: tabs.map((tab) {
                                  final currentState = bloc.state;
                                  final isActive =
                                      currentState is AdminLoaded &&
                                      currentState.activeTab == tab.$1;
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () =>
                                          bloc.add(AdminTabChanged(tab.$1)),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? (t.isDark
                                                    ? const Color(0xFF1E1E1E)
                                                    : const Color(0xFFEEEEEE))
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              tab.$3,
                                              size: 18,
                                              color: isActive
                                                  ? t.text
                                                  : t.textSub,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              tab.$2,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isActive
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isActive
                                                    ? t.text
                                                    : t.textSub,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Divider(color: t.border, height: 1),
                          // Profile row
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  bloc.add(AdminTabChanged(AdminTab.profile)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: t.surface2,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: t.border),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _initials,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: t.text,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentAdminName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: sidebarT.text,
                                            ),
                                          ),
                                          Text(
                                            currentAdminEmail,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: sidebarT.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AdminIconBtn(
                                      child: Text(
                                        t.isDark ? '☀' : '🌙',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      t: t,
                                      onTap: () =>
                                          bloc.add(AdminThemeToggled()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Logout
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  context.go('/');
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A1010),
                                    border: Border.all(
                                      color: const Color(0xFF4A1A1A),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.logout,
                                        size: 15,
                                        color: Color(0xFFFF6B6B),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final tabs = [
      (AdminTab.overview, 'Overview'),
      (AdminTab.globalResources, 'Global Resources'),
      (AdminTab.userUploads, 'User Uploads'),
      (AdminTab.users, 'Users'),
      (AdminTab.myResources, 'My Resources'),
      (AdminTab.profile, 'Profile'),
    ];

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          // Logo + Admin badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: t.isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.book_rounded,
                  size: 14,
                  color: t.isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'StudyHub',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: t.text,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: t.isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: t.border2),
                ),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: t.textMuted,
                  ),
                ),
              ),
            ],
          ),

          // Center tabs (desktop only)
          if (!isMobile)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: tabs.map((tab) {
                  return _TabItem(
                    label: tab.$2,
                    isActive: activeTab == tab.$1,
                    t: t,
                    onTap: () =>
                        context.read<AdminBloc>().add(AdminTabChanged(tab.$1)),
                  );
                }).toList(),
              ),
            )
          else
            const Spacer(),

          // Right: theme toggle + avatar / burger
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminIconBtn(
                child: Text(
                  t.isDark ? '☀' : '🌙',
                  style: const TextStyle(fontSize: 13),
                ),
                t: t,
                onTap: () => context.read<AdminBloc>().add(AdminThemeToggled()),
              ),
              const SizedBox(width: 10),
              if (isMobile)
                AdminIconBtn(
                  child: Icon(Icons.menu, size: 16, color: t.textSub),
                  t: t,
                  onTap: () => _showMobileMenu(context),
                )
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: t.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: t.border),
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── TAB ITEM ─────────────────────────────────────────────────────────────────
class _TabItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final AdminTheme t;
  final VoidCallback onTap;
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isActive
                    ? (widget.t.isDark ? Colors.white : Colors.black)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                color: widget.isActive
                    ? widget.t.text
                    : (_hover ? widget.t.text : widget.t.textSub),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



