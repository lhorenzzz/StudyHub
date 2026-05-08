import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import 'package:study_hub/features/admin/repository/admin_repository.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:study_hub/core/models/admin_user.dart';

// ─── THEME HELPER (same pattern as student dashboard) ─────────────────────────
class _T {
  final bool isDark;
  final Color bg, surface, surface2, border, border2, text, textSub, textMuted;

  _T(this.isDark)
    : bg = isDark ? AppColors.darkBg : AppColors.lightBg,
      surface = isDark ? AppColors.darkSurface : AppColors.lightSurface,
      surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
      border = isDark ? AppColors.darkBorder : AppColors.lightBorder,
      border2 = isDark ? AppColors.darkBorder2 : AppColors.lightBorder2,
      text = isDark ? AppColors.darkText : AppColors.lightText,
      textSub = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF666666),
      textMuted = isDark ? const Color(0xFF777777) : const Color(0xFF999999);

  Color get hover =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04);
}

// ─── CATEGORY COLOR PALETTE (same as student dashboard) ───────────────────────
class _CatColor {
  final Color border;
  final Color bg;
  final Color icon;
  const _CatColor({required this.border, required this.bg, required this.icon});
}

const _kDark = [
  _CatColor(
    border: Color(0xFF1D4ED8),
    bg: Color(0xFF0F1E3A),
    icon: Color(0xFF1E3A5F),
  ),
  _CatColor(
    border: Color(0xFF0F766E),
    bg: Color(0xFF0A2520),
    icon: Color(0xFF0D3330),
  ),
  _CatColor(
    border: Color(0xFFB45309),
    bg: Color(0xFF2A1A05),
    icon: Color(0xFF3A2208),
  ),
  _CatColor(
    border: Color(0xFF7C3AED),
    bg: Color(0xFF1A0D35),
    icon: Color(0xFF2A1255),
  ),
  _CatColor(
    border: Color(0xFFBE185D),
    bg: Color(0xFF2A0D1E),
    icon: Color(0xFF3A1028),
  ),
  _CatColor(
    border: Color(0xFF15803D),
    bg: Color(0xFF0A2015),
    icon: Color(0xFF0D2E1A),
  ),
];
const _kLight = [
  _CatColor(
    border: Color(0xFF93C5FD),
    bg: Color(0xFFEFF6FF),
    icon: Color(0xFFDBEAFE),
  ),
  _CatColor(
    border: Color(0xFF5EEAD4),
    bg: Color(0xFFF0FDFA),
    icon: Color(0xFFCCFBF1),
  ),
  _CatColor(
    border: Color(0xFFFCD34D),
    bg: Color(0xFFFFFBEB),
    icon: Color(0xFFFEF3C7),
  ),
  _CatColor(
    border: Color(0xFFC4B5FD),
    bg: Color(0xFFF5F3FF),
    icon: Color(0xFFEDE9FE),
  ),
  _CatColor(
    border: Color(0xFFF9A8D4),
    bg: Color(0xFFFDF2F8),
    icon: Color(0xFFFCE7F3),
  ),
  _CatColor(
    border: Color(0xFF86EFAC),
    bg: Color(0xFFF0FDF4),
    icon: Color(0xFFDCFCE7),
  ),
];
_CatColor _cc(int i, bool dark) =>
    (dark ? _kDark : _kLight)[i % (dark ? _kDark.length : _kLight.length)];

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE
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
            final t = _T(state.isDarkMode);
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
                      child: _AnimatedPageSwitcher(
                        index: state.activeTab.index,
                        pages: [
                          _OverviewTab(state: state, t: t),
                          _GlobalResourcesTab(state: state, t: t),
                          _UserUploadsTab(state: state, t: t),
                          _UsersTab(state: state, t: t),
                          _MyResourcesView(state: state, t: t),
                          _ProfileTab(state: state, t: t),
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

  SnackBar _snack(String msg, _T t, {required bool isError}) {
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

class _CombinedNavbar extends StatelessWidget {
  final _T t;
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
                      ? _T(sidebarState.isDarkMode)
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
                                      onTap: () {
                                        bloc.add(AdminTabChanged(tab.$1));
                                      },
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
                              onTap: () {
                                bloc.add(AdminTabChanged(AdminTab.profile));
                              },
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
                                    _IconBtn(
                                      child: Text(
                                        t.isDark ? '☀' : '🌙',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      t: t,
                                      onTap: () {
                                        bloc.add(AdminThemeToggled());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Logout button
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
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 15,
                                        color: const Color(0xFFFF6B6B),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
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
          // ── LEFT: Logo + Admin badge ──────────────────────────
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

          // ── CENTER: Tabs (desktop only) ───────────────────────
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

          // ── RIGHT: Theme toggle + Avatar or Burger ────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBtn(
                child: Text(
                  t.isDark ? '☀' : '🌙',
                  style: const TextStyle(fontSize: 13),
                ),
                t: t,
                onTap: () => context.read<AdminBloc>().add(AdminThemeToggled()),
              ),
              const SizedBox(width: 10),
              if (isMobile)
                _IconBtn(
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

class _TabItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final _T t;
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

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final AdminLoaded state;
  final _T t;
  const _OverviewTab({required this.state, required this.t});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: recentSlice was computed but never rendered — now used below
    // 🔥 FIREBASE: replace with a Firestore query:
    //   FirebaseFirestore.instance
    //     .collection('resources')
    //     .orderBy('uploaded_at', descending: true)
    //     .limit(5)
    //     .snapshots()
    final recent = [...state.resources]
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    final recentSlice = recent.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Summary of StudyHub activity.',
            style: TextStyle(fontSize: 13, color: t.textSub),
          ),
          const SizedBox(height: 28),

          // Stat cards
          LayoutBuilder(
            builder: (_, c) {
              final cols = c.maxWidth > 700 ? 3 : 1;
              final w = (c.maxWidth - (10.0 * (cols - 1))) / cols;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _StatCard(
                    icon: Icons.library_books_outlined,
                    label: 'Global Resources',
                    value: state.totalGlobalResources,
                    width: w,
                    t: t,
                    onTap: () => context.read<AdminBloc>().add(
                      AdminTabChanged(AdminTab.globalResources),
                    ),
                  ),
                  _StatCard(
                    icon: Icons.people_outline,
                    label: 'Total Users',
                    value: state.totalUsers,
                    width: w,
                    t: t,
                    onTap: () => context.read<AdminBloc>().add(
                      AdminTabChanged(AdminTab.users),
                    ),
                  ),
                  _StatCard(
                    icon: Icons.folder_outlined,
                    label: 'Total Categories',
                    value: state.totalCategories,
                    width: w,
                    t: t,
                    onTap: () => context.read<AdminBloc>().add(
                      AdminTabChanged(AdminTab.globalResources),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          // ✅ FIX: Recent Uploads section — was missing entirely
          // 🔥 FIREBASE: recentSlice comes from Firestore stream above
          const SizedBox(height: 4),
          Text(
            'Last 5 resources uploaded across all users.',
            style: TextStyle(fontSize: 12, color: t.textMuted),
          ),
          const SizedBox(height: 12),

          if (recentSlice.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No uploads yet.',
                  style: TextStyle(color: t.textSub, fontSize: 13),
                ),
              ),
            )
          else
            // ✅ connected to Global Resources tab on tap
            Column(
              children: recentSlice
                  .map(
                    (r) => _RecentResourceRow(
                      resource: r,
                      t: t,
                      // ✅ clicking a recent upload navigates to its category in Global Resources
                      onTap: () => context.read<AdminBloc>().add(
                        AdminTabChanged(AdminTab.globalResources),
                      ),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 32),

          _SectionHeader(title: 'Top Uploaders', t: t),

          Builder(
            builder: (context) {
              final Map<String, List<ResourceModel>> byUser = {};
              for (final r in state.resources) {
                byUser.putIfAbsent(r.uploadedBy, () => []).add(r);
              }
              final sorted = byUser.entries.toList()
                ..sort((a, b) => b.value.length.compareTo(a.value.length));
              final maxCount = sorted.isEmpty ? 1 : sorted.first.value.length;

              if (sorted.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No uploads yet.',
                      style: TextStyle(color: t.textSub, fontSize: 13),
                    ),
                  ),
                );
              }

              return Column(
                children: sorted.map((entry) {
                  return _UploaderRow(
                    uploadedBy: entry.key,
                    resources: entry.value,
                    maxCount: maxCount,
                    t: t,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int value;
  final double width;
  final _T t;
  // ✅ FIX: added onTap for cross-tab navigation
  // 🔥 FIREBASE: no changes needed here
  final VoidCallback? onTap;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
    required this.t,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // ✅ subtle hover effect when card is tappable
            color: _hover && widget.onTap != null
                ? widget.t.surface2
                : widget.t.surface,
            border: Border.all(
              color: _hover && widget.onTap != null
                  ? widget.t.border2
                  : widget.t.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.t.surface2,
                  border: Border.all(color: widget.t.border2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: widget.t.textSub),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.value}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: widget.t.text,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.t.textMuted,
                        ),
                      ),
                      // ✅ arrow hint when card is tappable
                      if (widget.onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 11,
                          color: widget.t.textMuted,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentResourceRow extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  // ✅ FIX: added onTap for cross-tab navigation
  // 🔥 FIREBASE: no changes needed here
  final VoidCallback? onTap;
  const _RecentResourceRow({
    required this.resource,
    required this.t,
    this.onTap,
  });
  @override
  State<_RecentResourceRow> createState() => _RecentResourceRowState();
}

class _RecentResourceRowState extends State<_RecentResourceRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hover ? t.surface : Colors.transparent,
            border: Border.all(color: _hover ? t.border2 : t.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: t.surface2,
                  border: Border.all(color: t.border2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    r.typeEmoji,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${r.categoryName} · ${r.difficultyLabel}',
                      style: TextStyle(fontSize: 12, color: t.textSub),
                    ),
                  ],
                ),
              ),
              Text(
                '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
                style: TextStyle(fontSize: 11, color: t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploaderRow extends StatefulWidget {
  final String uploadedBy;
  final List<ResourceModel> resources;
  final int maxCount;
  final _T t;
  const _UploaderRow({
    required this.uploadedBy,
    required this.resources,
    required this.maxCount,
    required this.t,
  });

  @override
  State<_UploaderRow> createState() => _UploaderRowState();
}

class _UploaderRowState extends State<_UploaderRow> {
  bool _expanded = false;
  final Map<String, bool> _showAll = {};

  String get _initials {
    final parts = widget.uploadedBy.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.uploadedBy.isNotEmpty
        ? widget.uploadedBy[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final count = widget.resources.length;
    final barWidth = count / widget.maxCount;

    final Map<String, List<ResourceModel>> byCategory = {};
    for (final r in widget.resources) {
      byCategory.putIfAbsent(r.categoryName, () => []).add(r);
    }

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _expanded ? t.surface2 : t.surface,
                border: Border.all(color: _expanded ? t.border2 : t.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border2),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.uploadedBy,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ✅ FIX: quick link to view this user's uploads in User Uploads tab
                  // 🔥 FIREBASE: when Firebase is connected, pass uid instead of name
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        context.read<AdminBloc>()
                          ..add(
                            AdminUserUploadsFilterChanged(widget.uploadedBy),
                          )
                          ..add(AdminTabChanged(AdminTab.userUploads));
                      },
                      child: Tooltip(
                        message: 'View uploads',
                        child: Icon(
                          Icons.open_in_new,
                          size: 13,
                          color: t.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                      ),
                      Text(
                        'uploads',
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 80,
                    height: 5,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: barWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.textMuted,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.25 : 0,
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: t.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_expanded)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: byCategory.entries.map((catEntry) {
                final catName = catEntry.key;
                final catResources = catEntry.value;
                final showAll = _showAll[catName] ?? false;
                const limit = 6;
                final visible = showAll
                    ? catResources
                    : catResources.take(limit).toList();
                final remaining = catResources.length - limit;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${catResources.first.categoryName.toUpperCase()} · ${catResources.length} FILES',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...visible.map((r) => _FileChip(resource: r, t: t)),
                          if (!showAll && remaining > 0)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _showAll[catName] = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: t.border2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '+ $remaining more',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: t.textSub,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _FileChip extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  const _FileChip({required this.resource, required this.t});

  @override
  State<_FileChip> createState() => _FileChipState();
}

class _FileChipState extends State<_FileChip> {
  bool _hover = false;

  (Color, Color) get _typeColors {
    switch (widget.resource.type) {
      case ResourceType.pdf:
        return (const Color(0xFFFCEBEB), const Color(0xFFA32D2D));
      case ResourceType.word:
        return (const Color(0xFFE6F1FB), const Color(0xFF185FA5));
      case ResourceType.ppt:
        return (const Color(0xFFFAEEDA), const Color(0xFF854F0B));
      case ResourceType.excel:
        return (const Color(0xFFE6F7EE), const Color(0xFF1A6E3C));
      case ResourceType.article:
        return (const Color(0xFFEAF3DE), const Color(0xFF3B6D11));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final r = widget.resource;
    final (bgColor, fgColor) = _typeColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _hover ? t.surface2 : t.surface,
          border: Border.all(color: _hover ? t.border2 : t.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                r.typeLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(r.title, style: TextStyle(fontSize: 12, color: t.text)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL RESOURCES TAB — NEW
// Breadcrumb helper
// ─────────────────────────────────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  final String? categoryName;
  final _T t;
  final VoidCallback onBack;
  const _Breadcrumb({
    required this.categoryName,
    required this.t,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: t.surface2,
                border: Border.all(color: t.border2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, size: 14, color: t.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.folder_outlined, size: 15, color: t.textMuted),
        const SizedBox(width: 6),
        Text(
          categoryName ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
        ),
      ],
    );
  }
}

// File type filter chips
class _TypeFilterChips extends StatelessWidget {
  final String selected;
  final _T t;
  final ValueChanged<String> onChanged;
  const _TypeFilterChips({
    required this.selected,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      ('', 'All'),
      ('pdf', 'PDF'),
      ('word', 'Word'),
      ('ppt', 'PPT'),
      ('excel', 'Excel'),
      ('article', 'Article'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isActive = selected == type.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _Chip(
              label: type.$2,
              selected: isActive,
              t: t,
              onTap: () => onChanged(type.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Compact file card (grid layout) used by both GlobalResources and UserUploads
class _CompactFileCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final _T t;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  const _CompactFileCard({
    required this.resource,
    required this.width,
    required this.t,
    required this.onView,
    required this.onDelete,
    required this.onSave,
  });

  @override
  State<_CompactFileCard> createState() => _CompactFileCardState();
}

class _CompactFileCardState extends State<_CompactFileCard> {
  bool _hover = false;

  (Color, Color) get _typeColors {
    switch (widget.resource.type) {
      case ResourceType.pdf:
        return (const Color(0xFF3A1010), const Color(0xFFFF6B6B));
      case ResourceType.word:
        return (const Color(0xFF0F2040), const Color(0xFF60A5FA));
      case ResourceType.ppt:
        return (const Color(0xFF3A1F05), const Color(0xFFFB923C));
      case ResourceType.excel:
        return (const Color(0xFF0A2A18), const Color(0xFF34D399));
      default: // article
        return (const Color(0xFF1A2A0A), const Color(0xFFA3E635));
    }
  }

  // Replace the entire outer GestureDetector + MouseRegion in _CompactFileCard:

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;
    final (badgeBg, badgeFg) = _typeColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onView,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hover
                ? (t.isDark ? const Color(0xFF161616) : const Color(0xFFF0F0F0))
                : t.surface,
            border: Border.all(color: _hover ? t.border2 : t.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      r.typeLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: badgeFg,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ── Save button ──────────────────────────────
                  Tooltip(
                    message: 'Add to My Resources',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.onSave();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.bookmark_add_outlined,
                          size: 14,
                          color: t.textSub,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // ── Delete button ────────────────────────────
                  Tooltip(
                    message: 'Delete',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.onDelete();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: const Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                r.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border2),
                    ),
                    child: Center(
                      child: Text(
                        r.uploadedBy.isNotEmpty
                            ? r.uploadedBy[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: t.textSub,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      r.uploadedBy,
                      style: TextStyle(fontSize: 10, color: t.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${r.uploadedAt.day}/${r.uploadedAt.month}',
                    style: TextStyle(fontSize: 10, color: t.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Top-level helper so _AddCategoryMiniCard can call it
void _showAddCategoryModal(BuildContext context, _T t) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String selectedEmoji = '📁';
  final emojis = [
    '📁',
    '💻',
    '🧪',
    '🍳',
    '📚',
    '🎨',
    '🔧',
    '🌐',
    '🧠',
    '📐',
    '🎵',
    '⚽',
  ];

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Add Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.text,
                    ),
                  ),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, size: 18, color: t.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Icon',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emojis.map((e) {
                  final isSel = selectedEmoji == e;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setS(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSel
                              ? (t.isDark ? Colors.white : Colors.black)
                              : t.surface2,
                          border: Border.all(
                            color: isSel
                                ? (t.isDark ? Colors.white : Colors.black)
                                : t.border2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Category Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              _ModalTextField(ctrl: nameCtrl, hint: 'e.g. Mathematics', t: t),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              _ModalTextField(
                ctrl: descCtrl,
                hint: 'Brief description...',
                t: t,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _ModalBtn(
                  label: 'Add Category',
                  primary: true,
                  t: t,
                  onTap: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<AdminBloc>().add(
                      AdminCategoryAddRequested(
                        name: name,
                        description: descCtrl.text.trim(),
                        emoji: selectedEmoji,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Global Resources Tab — category grid → drill into files
class _GlobalResourcesTab extends StatefulWidget {
  final AdminLoaded state;
  final _T t;
  const _GlobalResourcesTab({required this.state, required this.t});

  @override
  State<_GlobalResourcesTab> createState() => _GlobalResourcesTabState();
}

class _GlobalResourcesTabState extends State<_GlobalResourcesTab> {
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _typeFilter = '';

  void _showUploadModal(BuildContext context, _T t) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: _AdminUploadForm(
              t: t,
              preselectedCategoryId: _selectedCategoryId,
              categories: widget.state.categories,
              isLoading: widget.state.isActionLoading,
              defaultScope: ResourceScope.global,
              onSubmit: (data) {
                context.read<AdminBloc>().add(
                  AdminResourceUploadSubmitted(
                    title: data['title']!,
                    description: data['description']!,
                    categoryId: data['categoryId']!,
                    difficulty: data['difficulty']!,
                    tags: data['tags']!,
                    fileName: data['fileName']!,
                    fileType: data['fileType']!,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  List<ResourceModel> _getFilesForCategory(String categoryId) {
    // ✅ FIX: only show global-scoped resources in this tab
    // 🔥 FIREBASE: replace this entire method body with a Firestore query:
    //   final snapshot = await FirebaseFirestore.instance
    //     .collection('resources')
    //     .where('category_id', isEqualTo: categoryId)
    //     .where('scope', isEqualTo: 'global')       // ← only public files
    //     .orderBy('uploaded_at', descending: true)
    //     .get();
    //   return snapshot.docs
    //     .map((d) => ResourceModel.fromFirestore(d.data(), d.id))
    //     .toList();
    return widget.state.resources
        .where((r) => r.categoryId == categoryId && r.isGlobal)
        .toList();
  }

  List<ResourceModel> get _filteredFiles {
    final files = _getFilesForCategory(_selectedCategoryId ?? '');
    if (_typeFilter.isEmpty) return files;
    // ✅ FIX: compare against r.fileType (String getter) not r.type (enum)
    // 🔥 FIREBASE: when using Firestore, filter server-side:
    //   .where('file_type', isEqualTo: _typeFilter)
    //   .where('category_id', isEqualTo: _selectedCategoryId)
    return files.where((r) => r.fileType == _typeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final state = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (_selectedCategoryId != null)
                _Breadcrumb(
                  categoryName: _selectedCategoryName,
                  t: t,
                  onBack: () => setState(() {
                    _selectedCategoryId = null;
                    _selectedCategoryName = null;
                    _typeFilter = '';
                  }),
                )
              else
                Text(
                  'Global Resources',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: t.text,
                  ),
                ),
              const Spacer(),
              if (_selectedCategoryId != null)
                _HoverBtn(
                  label: '↑  Upload to this category',
                  t: t,
                  primary: true,
                  onTap: () => _showUploadModal(context, t),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (_selectedCategoryId == null)
            Text(
              'Browse and manage resources by category.',
              style: TextStyle(fontSize: 13, color: t.textSub),
            ),
          const SizedBox(height: 24),

          // LEVEL 1: Category grid
          if (_selectedCategoryId == null) ...[
            LayoutBuilder(
              builder: (_, c) {
                final cols = c.maxWidth > 900
                    ? 4
                    : c.maxWidth > 600
                    ? 3
                    : 2;
                final w = (c.maxWidth - (10.0 * (cols - 1))) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...state.categories.asMap().entries.map((e) {
                      final cat = e.value;
                      // ✅ FIX: only count global resources per category
                      // 🔥 FIREBASE: store this as a denormalized field on the category document:
                      //   'global_resource_count': FieldValue.increment(1)  ← on upload (scope=global)
                      //   'global_resource_count': FieldValue.increment(-1) ← on delete or scope→private
                      //   Then read: cat.globalResourceCount directly from CategoryModel
                      final count = state.resources
                          .where((r) => r.categoryId == cat.id && r.isGlobal)
                          .length;
                      return _GlobalCategoryCard(
                        category: cat,
                        resourceCount: count,
                        colorIndex: e.key,
                        width: w,
                        t: t,
                        onTap: () => setState(() {
                          _selectedCategoryId = cat.id;
                          _selectedCategoryName = cat.name;
                          _typeFilter = '';
                        }),
                      );
                    }),
                    _AddCategoryMiniCard(width: w, t: t),
                  ],
                );
              },
            ),
          ],

          // LEVEL 2: Files in selected category
          if (_selectedCategoryId != null) ...[
            _TypeFilterChips(
              selected: _typeFilter,
              t: t,
              onChanged: (v) => setState(() => _typeFilter = v),
            ),
            const SizedBox(height: 16),
            Text(
              '${_filteredFiles.length} files',
              style: TextStyle(fontSize: 12, color: t.textMuted),
            ),
            const SizedBox(height: 12),
            if (_filteredFiles.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        size: 36,
                        color: t.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No files in this category yet.',
                        style: TextStyle(color: t.textSub, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use "Upload to this category" above.',
                        style: TextStyle(color: t.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (_, c) {
                  final cols = c.maxWidth > 800
                      ? 3
                      : c.maxWidth > 500
                      ? 2
                      : 1;
                  final w = (c.maxWidth - (10.0 * (cols - 1))) / cols;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _filteredFiles
                        .map(
                          (r) => _CompactFileCard(
                            resource: r,
                            width: w,
                            t: t,
                            onView: () => _showViewModal(context, r, t),
                            onDelete: () => _confirmDelete(context, r, t),
                            onSave: () {
                              context.read<AdminBloc>().add(
                                AdminResourceScopeChanged(
                                  id: r.id,
                                  scope: 'private',
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: t.surface,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: t.border),
                                  ),
                                  content: Text(
                                    'Added to My Resources',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: t.text,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ResourceModel r, _T t) {
    _showConfirmDialog(
      context: context,
      t: t,
      title: 'Delete Resource',
      body: 'Delete "${r.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminResourceDeleteRequested(r.id)),
    );
  }

  void _showViewModal(BuildContext context, ResourceModel r, _T t) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      border: Border.all(color: t.border2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        r.typeEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        Text(
                          '${r.categoryName} · ${r.difficultyLabel}',
                          style: TextStyle(fontSize: 12, color: t.textSub),
                        ),
                      ],
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 18, color: t.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ModalRow(label: 'File Type', value: r.typeLabel, t: t),
              _ModalRow(label: 'Category', value: r.categoryName, t: t),
              _ModalRow(label: 'Difficulty', value: r.difficultyLabel, t: t),
              _ModalRow(
                label: 'Uploaded',
                value:
                    '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
                t: t,
              ),
              _ModalRow(label: 'Uploaded by', value: r.uploadedBy, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

// Global category card — clickable, drills into files
class _GlobalCategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int resourceCount;
  final int colorIndex;
  final double width;
  final _T t;
  final VoidCallback onTap;
  const _GlobalCategoryCard({
    required this.category,
    required this.resourceCount,
    required this.colorIndex,
    required this.width,
    required this.t,
    required this.onTap,
  });

  @override
  State<_GlobalCategoryCard> createState() => _GlobalCategoryCardState();
}

class _GlobalCategoryCardState extends State<_GlobalCategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final t = widget.t;
    final cc = _cc(widget.colorIndex, t.isDark);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hover ? cc.bg : t.surface,
            border: Border.all(
              color: _hover ? cc.border : t.border,
              width: _hover ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.surface2,
                  border: Border.all(color: t.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    c.emoji.isNotEmpty ? c.emoji : '📁',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                c.name.isNotEmpty ? c.name : 'Unnamed',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.description,
                style: TextStyle(fontSize: 11, color: t.textSub, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${widget.resourceCount} files',
                    style: TextStyle(
                      fontSize: 11,
                      color: t.textSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward, size: 13, color: t.textMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add category mini card shown in the global resources grid
class _AddCategoryMiniCard extends StatefulWidget {
  final double width;
  final _T t;
  const _AddCategoryMiniCard({required this.width, required this.t});

  @override
  State<_AddCategoryMiniCard> createState() => _AddCategoryMiniCardState();
}

class _AddCategoryMiniCardState extends State<_AddCategoryMiniCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => _showAddCategoryModal(context, widget.t),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: _hover ? widget.t.hover : Colors.transparent,
            border: Border.all(
              color: _hover ? widget.t.border2 : widget.t.border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 22, color: widget.t.textMuted),
              const SizedBox(height: 6),
              Text(
                'Add Category',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.t.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER UPLOADS TAB — NEW
// ─────────────────────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
// PATCH: _UserUploadsTab
// FILE: admin_dashboard_page.dart
// FIND: class _UserUploadsTab extends StatefulWidget
// REPLACE the entire class + state with this block
// ═════════════════════════════════════════════════════════════════════════════

class _UserUploadsTab extends StatefulWidget {
  final AdminLoaded state;
  final _T t;
  const _UserUploadsTab({required this.state, required this.t});

  @override
  State<_UserUploadsTab> createState() => _UserUploadsTabState();
}

class _UserUploadsTabState extends State<_UserUploadsTab> {
  static const _pageSize = 20;
  int _page = 0;

  String _search = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-filled when admin clicks "View Uploads" from the Users tab
    _search = widget.state.userUploadsFilter;
    _searchCtrl = TextEditingController(text: _search);
  }

  @override
  void didUpdateWidget(_UserUploadsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when userUploadsFilter is cleared (e.g. back button)
    if (oldWidget.state.userUploadsFilter != widget.state.userUploadsFilter) {
      _search = widget.state.userUploadsFilter;
      _searchCtrl.text = _search;
      _page = 0;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _categoryFilter = '';
  String _typeFilter = '';

  // 🗑️ DUMMY — returns all resources as user uploads
  // 🔥 FIREBASE: Replace with:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .where('uploaded_by', isNotEqualTo: 'admin')
  //     .orderBy('uploaded_at', descending: true)
  //     .limit(_pageSize)
  //     .get()

  // ✅ FIX: exclude admin uploads — this tab is for STUDENT uploads only
  // 🔥 FIREBASE: replace this getter entirely with a Firestore query:
  //   final snapshot = await FirebaseFirestore.instance
  //     .collection('resources')
  //     .where('uploaded_by', isNotEqualTo: 'admin') // ← exclude admin
  //     .orderBy('uploaded_by')                       // ← required when using isNotEqualTo
  //     .orderBy('uploaded_at', descending: true)
  //     .get();
  //   return snapshot.docs
  //     .map((d) => ResourceModel.fromFirestore(d.data(), d.id))
  //     .toList();
  //
  // 🔥 FIREBASE BETTER APPROACH: store a 'role' field on each resource document:
  //   .where('uploader_role', isEqualTo: 'student')
  //   This avoids the isNotEqualTo limitation in Firestore compound queries
  List<ResourceModel> get _allUploads => widget.state.resources
      .where((r) => r.uploadedBy != 'admin') // ✅ students only
      .toList();

  List<ResourceModel> get _filtered {
    return _allUploads.where((r) {
      final ms =
          _search.isEmpty ||
          r.title.toLowerCase().contains(_search.toLowerCase()) ||
          r.uploadedBy.toLowerCase().contains(_search.toLowerCase());
      final mc = _categoryFilter.isEmpty || r.categoryId == _categoryFilter;
      final mt = _typeFilter.isEmpty || r.fileType == _typeFilter;
      return ms && mc && mt;
    }).toList();
  }

  List<ResourceModel> get _paginated {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  int get _totalPages => (_filtered.length / _pageSize).ceil().clamp(1, 9999);

  // ✅ FIX: extracted as top-level function — shared by User Uploads,
  // My Resources, and any future tab that needs file type badge colors
  // 🔥 FIREBASE: no changes needed — purely a UI helper
  (Color, Color) _getTypeBadgeColors(String fileType) {
    switch (fileType) {
      case 'pdf':
        return (const Color(0xFF3A1010), const Color(0xFFFF6B6B));
      case 'word':
        return (const Color(0xFF0F2040), const Color(0xFF60A5FA));
      case 'ppt':
        return (const Color(0xFF3A1F05), const Color(0xFFFB923C));
      case 'excel':
        return (const Color(0xFF0A2A18), const Color(0xFF34D399));
      default: // article
        return (const Color(0xFF1A2A0A), const Color(0xFFA3E635));
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final state = widget.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          // ── Header ──────────────────────────────────────────────────
          // Back button — only shown when navigated from Users tab
          if (widget.state.userUploadsFilter.isNotEmpty) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.read<AdminBloc>()
                    ..add(AdminUserUploadsFilterChanged(''))
                    ..add(AdminTabChanged(AdminTab.users));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface2,
                    border: Border.all(color: t.border2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 14, color: t.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Back to Users',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.state.userUploadsFilter.isNotEmpty
                        ? 'Uploads by ${widget.state.userUploadsFilter}'
                        : 'User Uploads',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All files uploaded by students. View or delete.',
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Search + Filters ─────────────────────────────────────────
          // Wrap so it wraps on small screens
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 240,
                child: _SearchFieldWithController(
                  hint: 'Search title or uploader...',
                  controller: _searchCtrl,
                  t: t,
                  onChanged: (q) => setState(() {
                    _search = q;
                    _page = 0;
                  }),
                ),
              ),
              _FilterDropdown(
                hint: 'All categories',
                value: _categoryFilter.isEmpty ? null : _categoryFilter,
                items: state.categories.map((c) => (c.id, c.name)).toList(),
                t: t,
                onChanged: (v) => setState(() {
                  _categoryFilter = v ?? '';
                  _page = 0;
                }),
              ),
              _FilterDropdown(
                hint: 'All types',
                value: _typeFilter.isEmpty ? null : _typeFilter,
                items: const [
                  ('pdf', 'PDF'),
                  ('word', 'Word'),
                  ('ppt', 'PPT'),
                  ('excel', 'Excel'),
                  ('article', 'Article'),
                ],
                t: t,
                onChanged: (v) => setState(() {
                  _typeFilter = v ?? '';
                  _page = 0;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Count + page info ────────────────────────────────────────
          Row(
            children: [
              Text(
                '${_filtered.length} files',
                style: TextStyle(fontSize: 12, color: t.textMuted),
              ),
              if (_totalPages > 1) ...[
                const SizedBox(width: 8),
                Text(
                  '· Page ${_page + 1} of $_totalPages',
                  style: TextStyle(fontSize: 12, color: t.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // ── Table ────────────────────────────────────────────────────
          if (_paginated.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 36, color: t.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      _search.isNotEmpty
                          ? 'No files match your search.'
                          : 'No user uploads yet.',
                      style: TextStyle(color: t.textSub, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    // Table header — hide some cols on narrow
                    if (!isNarrow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: t.surface2,
                          border: Border(bottom: BorderSide(color: t.border)),
                        ),
                        child: Row(
                          children: [
                            // Type badge col
                            const SizedBox(width: 52),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Title',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(
                                'Uploader',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            // Delete col
                            const SizedBox(width: 32),
                          ],
                        ),
                      ),

                    // Table rows
                    ..._paginated.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      final isLast = i == _paginated.length - 1;
                      return _UploadRow(
                        resource: r,
                        t: t,
                        isLast: isLast,
                        isNarrow: isNarrow,
                        typeColors: (
                          bg: _getTypeBadgeColors(r.fileType).$1,
                          fg: _getTypeBadgeColors(r.fileType).$2,
                        ),
                        formattedDate: _formatDate(r.uploadedAt),
                        onView: () => _showViewModal(context, r, t),
                        onDelete: () => _confirmDelete(context, r, t),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // ── Pagination controls ──────────────────────────────────────
          if (_totalPages > 1) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HoverBtn(
                  label: '← Prev',
                  t: t,
                  primary: false,
                  onTap: _page > 0 ? () => setState(() => _page--) : () {},
                ),
                const SizedBox(width: 12),
                Text(
                  '${_page + 1} / $_totalPages',
                  style: TextStyle(fontSize: 13, color: t.textSub),
                ),
                const SizedBox(width: 12),
                _HoverBtn(
                  label: 'Next →',
                  t: t,
                  primary: false,
                  onTap: _page < _totalPages - 1
                      ? () => setState(() => _page++)
                      : () {},
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ResourceModel r, _T t) {
    _showConfirmDialog(
      context: context,
      t: t,
      title: 'Delete Resource',
      body: 'Delete "${r.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      // 🔥 FIREBASE: Replace mock delete with:
      //   FirebaseFirestore.instance
      //     .collection('resources')
      //     .doc(r.id)
      //     .delete()
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminResourceDeleteRequested(r.id)),
    );
  }

  void _showViewModal(BuildContext context, ResourceModel r, _T t) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      border: Border.all(color: t.border2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        r.typeEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        Text(
                          '${r.categoryName} · ${r.difficultyLabel}',
                          style: TextStyle(fontSize: 12, color: t.textSub),
                        ),
                      ],
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 18, color: t.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ModalRow(label: 'File Type', value: r.typeLabel, t: t),
              _ModalRow(label: 'Category', value: r.categoryName, t: t),
              _ModalRow(label: 'Difficulty', value: r.difficultyLabel, t: t),
              _ModalRow(
                label: 'Uploaded',
                value: _formatDate(r.uploadedAt),
                t: t,
              ),
              _ModalRow(label: 'Uploaded by', value: r.uploadedBy, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single upload row ──────────────────────────────────────────────────────────
// Separate widget so hover state is isolated per row
class _UploadRow extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  final bool isLast;
  final bool isNarrow;
  final ({Color bg, Color fg}) typeColors;
  final String formattedDate;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _UploadRow({
    required this.resource,
    required this.t,
    required this.isLast,
    required this.isNarrow,
    required this.typeColors,
    required this.formattedDate,
    required this.onView,
    required this.onDelete,
  });

  @override
  State<_UploadRow> createState() => _UploadRowState();
}

class _UploadRowState extends State<_UploadRow> {
  bool _hover = false;

  String get _initials {
    final s = widget.resource.uploadedBy;
    if (s.isEmpty) return '?';
    final parts = s.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return s[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;
    final badgeBg = widget.typeColors.bg;
    final badgeFg = widget.typeColors.fg;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onView,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _hover ? t.surface2 : t.surface,
            border: widget.isLast
                ? null
                : Border(bottom: BorderSide(color: t.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: widget.isNarrow
              // ── NARROW layout (mobile) ──────────────────────────
              ? Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.typeLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeFg,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title + uploader
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${r.uploadedBy} · ${r.categoryName}',
                            style: TextStyle(fontSize: 11, color: t.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Delete
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              // ── WIDE layout (desktop/tablet) ────────────────────
              : Row(
                  children: [
                    // Type badge
                    SizedBox(
                      width: 52,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            r.typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.categoryName,
                        style: TextStyle(fontSize: 14, color: t.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Uploader
                    SizedBox(
                      width: 90,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: t.surface2,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.border2),
                            ),
                            child: Center(
                              child: Text(
                                _initials,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: t.textSub,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r.uploadedBy,
                              style: TextStyle(fontSize: 12, color: t.textSub),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date
                    SizedBox(
                      width: 100,
                      child: Text(
                        widget.formattedDate,
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ),
                    // Delete
                    SizedBox(
                      width: 32,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onDelete,
                          child: Icon(
                            Icons.delete_outline,
                            size: 15,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USERS TAB
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// USERS TAB — REWRITTEN
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final AdminLoaded state;
  final _T t;
  const _UsersTab({required this.state, required this.t});

  List<AdminUser> get _filtered {
    var list = [...state.filteredUsers];
    if (state.userSort == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all registered users.',
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${_filtered.length} users',
                style: TextStyle(fontSize: 13, color: t.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ✅ FIX: role count summary chips — quick at-a-glance breakdown
          // 🔥 FIREBASE: these counts should come from Firestore aggregation queries:
          //   final adminCount = await FirebaseFirestore.instance
          //     .collection('users')
          //     .where('role', isEqualTo: 'admin')
          //     .count()
          //     .get();
          //   Use AggregateQuery (Firestore SDK 4.x+) for efficient counts
          _RoleCountRow(users: state.users, t: t),
          const SizedBox(height: 16),

          // ── Search + Filters ──────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 240,
                child: _SearchField(
                  hint: 'Search by name or email...',
                  t: t,
                  onChanged: (q) =>
                      context.read<AdminBloc>().add(AdminUserSearchChanged(q)),
                ),
              ),
              _FilterDropdown(
                hint: 'All roles',
                value: state.userRoleFilter.isEmpty
                    ? null
                    : state.userRoleFilter,
                items: const [
                  ('admin', 'Admin'),
                  ('student', 'Student'),
                  ('moderator', 'Moderator'),
                ],
                t: t,
                onChanged: (v) => context.read<AdminBloc>().add(
                  AdminUserRoleFilterChanged(v ?? ''),
                ),
              ),
              _FilterDropdown(
                hint: 'Sort: Date',
                value: state.userSort,
                items: const [
                  ('date', 'Sort: Date'),
                  ('name', 'Sort: Name A–Z'),
                ],
                t: t,
                onChanged: (v) => context.read<AdminBloc>().add(
                  AdminUserSortChanged(v ?? 'date'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Table ─────────────────────────────────────────────────
          if (_filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 36, color: t.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      state.userSearch.isNotEmpty ||
                              state.userRoleFilter.isNotEmpty
                          ? 'No users match your filters.'
                          : 'No users registered yet.',
                      style: TextStyle(color: t.textSub, fontSize: 13),
                    ),
                    if (state.userSearch.isNotEmpty ||
                        state.userRoleFilter.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminBloc>().add(
                              AdminUserSearchChanged(''),
                            );
                            context.read<AdminBloc>().add(
                              AdminUserRoleFilterChanged(''),
                            );
                          },
                          child: Text(
                            'Clear filters',
                            style: TextStyle(fontSize: 12, color: t.textSub),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    // ── Column headers ───────────────────────────────
                    if (!isNarrow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: t.surface2,
                          border: Border(bottom: BorderSide(color: t.border)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 46),
                            Expanded(flex: 3, child: _ColHeader('Name', t)),
                            Expanded(flex: 3, child: _ColHeader('Email', t)),
                            SizedBox(width: 90, child: _ColHeader('Role', t)),
                            SizedBox(width: 90, child: _ColHeader('Status', t)),
                            SizedBox(
                              width: 100,
                              child: _ColHeader('Joined', t),
                            ),
                            SizedBox(
                              width: 110,
                              child: _ColHeader('Actions', t),
                            ),
                          ],
                        ),
                      ),

                    // ── Rows ─────────────────────────────────────────
                    ..._filtered.asMap().entries.map((entry) {
                      final isLast = entry.key == _filtered.length - 1;
                      return _UserRow(
                        user: entry.value,
                        t: t,
                        isLast: isLast,
                        isNarrow: isNarrow,
                        onDelete: () => _confirmDelete(context, entry.value),
                        onBan: () => _confirmBan(context, entry.value),
                        onSuspend: () => _confirmSuspend(context, entry.value),
                        onUnban: () => _confirmUnban(context, entry.value),
                        onViewUploads: () => _viewUploads(context, entry.value),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ FIX: admin users → route to My Resources tab
  // student/moderator users → route to User Uploads tab (filtered by name)
  // 🔥 FIREBASE: when Firebase is connected, filter by uid instead of name:
  //   AdminUserUploadsFilterChanged(u.id) ← use uid not display name
  //   Then in _UserUploadsTabState._filtered, match against r.uploadedById
  void _viewUploads(BuildContext context, AdminUser u) {
    if (u.role == 'admin') {
      // ✅ admin uploads live in My Resources, not User Uploads
      context.read<AdminBloc>().add(AdminTabChanged(AdminTab.myResources));
    } else {
      // ✅ student/moderator uploads live in User Uploads
      context.read<AdminBloc>()
        ..add(AdminUserUploadsFilterChanged(u.name))
        ..add(AdminTabChanged(AdminTab.userUploads));
    }
  }

  // ✅ FIX: clearer language distinguishing ban vs suspend
  // 🔥 FIREBASE: ban = Firestore status:'banned' + Auth disabled via Cloud Function
  //   See admin_repository.dart banUser() for full implementation steps
  void _confirmBan(BuildContext context, AdminUser u) {
    _showConfirmDialog(
      context: context,
      t: t,
      title: 'Ban User',
      body:
          'Permanently ban "${u.name}"?\n\n'
          '• Their account will be disabled\n'
          '• They cannot log in until reinstated\n'
          '• Use Suspend instead for temporary restrictions',
      confirmLabel: 'Ban',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserBanRequested(u.id)),
    );
  }

  // ✅ FIX: clearer language distinguishing suspend vs ban
  // 🔥 FIREBASE: suspend = Firestore status:'suspended' only
  //   No Auth disable — app checks 'status' on login and blocks access
  //   See admin_repository.dart suspendUser() for full implementation steps
  void _confirmSuspend(BuildContext context, AdminUser u) {
    _showConfirmDialog(
      context: context,
      t: t,
      title: 'Suspend User',
      body:
          'Temporarily suspend "${u.name}"?\n\n'
          '• Their status will be set to suspended\n'
          '• They cannot access the app until reinstated\n'
          '• Use Ban for permanent removal of access',
      confirmLabel: 'Suspend',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserSuspendRequested(u.id)),
    );
  }

  // ✅ FIX: dialog title and body now reflect whether user was
  // banned or suspended so admin knows exactly what they're reversing
  // 🔥 FIREBASE: unban = Firestore status:'active' + Auth re-enabled via Cloud Function
  //   unsuspend = Firestore status:'active' only (no Auth change needed)
  //   See admin_repository.dart unbanUser() for full implementation steps
  void _confirmUnban(BuildContext context, AdminUser u) {
    final isBanned = u.status == 'banned';
    _showConfirmDialog(
      context: context,
      t: t,
      title: isBanned ? 'Lift Ban' : 'Lift Suspension',
      body: isBanned
          ? 'Lift the ban on "${u.name}"?\n\n'
                '• Their account will be re-enabled\n'
                '• They will be able to log in again'
          : 'Lift the suspension on "${u.name}"?\n\n'
                '• Their status will be set back to active\n'
                '• They will regain full app access',
      confirmLabel: isBanned ? 'Lift Ban' : 'Lift Suspension',
      isDestructive: false,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserUnbanRequested(u.id)),
    );
  }

  void _confirmDelete(BuildContext context, AdminUser u) {
    _showConfirmDialog(
      context: context,
      t: t,
      title: 'Delete User',
      body:
          'Delete "${u.name}"? This removes them from Firestore. '
          // 🔥 FIREBASE (backend team): also call Auth delete via Cloud Function.
          'Firebase Auth account will still exist until backend wires Cloud Function.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserDeleteRequested(u.id)),
    );
  }
}

// ✅ NEW: role count summary row
// 🔥 FIREBASE: replace counts with Firestore AggregateQuery results
class _RoleCountRow extends StatelessWidget {
  final List<AdminUser> users;
  final _T t;
  const _RoleCountRow({required this.users, required this.t});

  @override
  Widget build(BuildContext context) {
    // ✅ count by role and status from local state
    // 🔥 FIREBASE: swap these with server-side counts for accuracy at scale
    final students = users.where((u) => u.role == 'student').length;
    final admins = users.where((u) => u.role == 'admin').length;
    final moderators = users.where((u) => u.role == 'moderator').length;
    final banned = users.where((u) => u.status == 'banned').length;
    final suspended = users.where((u) => u.status == 'suspended').length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CountChip(
          label: 'Students',
          count: students,
          bg: const Color(0xFF0F2040),
          fg: const Color(0xFF60A5FA),
          t: t,
        ),
        _CountChip(
          label: 'Admins',
          count: admins,
          bg: const Color(0xFF0A2A18),
          fg: const Color(0xFF34D399),
          t: t,
        ),
        if (moderators > 0)
          _CountChip(
            label: 'Moderators',
            count: moderators,
            bg: const Color(0xFF2A1F05),
            fg: const Color(0xFFFB923C),
            t: t,
          ),
        if (banned > 0)
          _CountChip(
            label: 'Banned',
            count: banned,
            bg: const Color(0xFF3A1010),
            fg: const Color(0xFFFF6B6B),
            t: t,
          ),
        if (suspended > 0)
          _CountChip(
            label: 'Suspended',
            count: suspended,
            bg: const Color(0xFF2A1A05),
            fg: const Color(0xFFFBBF24),
            t: t,
          ),
      ],
    );
  }
}

// ── Count chip ────────────────────────────────────────────────────────────────
class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color bg, fg;
  final _T t;
  const _CountChip({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: fg.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

// ── Column header helper───────────────────────────────────────────────────────
class _ColHeader extends StatelessWidget {
  final String label;
  final _T t;
  const _ColHeader(this.label, this.t);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: t.textMuted,
      ),
    );
  }
}

// ── Role badge colors ──────────────────────────────────────────────────────────
({Color bg, Color fg, Color border}) _roleBadgeColors(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return (
        bg: const Color(0xFF0A2A18),
        fg: const Color(0xFF34D399),
        border: const Color(0xFF34D399),
      );
    case 'moderator':
      return (
        bg: const Color(0xFF2A1F05),
        fg: const Color(0xFFFB923C),
        border: const Color(0xFFFB923C),
      );
    default:
      return (
        bg: const Color(0xFF0F2040),
        fg: const Color(0xFF60A5FA),
        border: const Color(0xFF60A5FA),
      );
  }
}

// ── Status badge colors ────────────────────────────────────────────────────────
({Color bg, Color fg, Color border}) _statusBadgeColors(String status) {
  switch (status.toLowerCase()) {
    case 'banned':
      return (
        bg: const Color(0xFF3A1010),
        fg: const Color(0xFFFF6B6B),
        border: const Color(0xFFFF6B6B),
      );
    case 'suspended':
      return (
        bg: const Color(0xFF2A1A05),
        fg: const Color(0xFFFBBF24),
        border: const Color(0xFFFBBF24),
      );
    default:
      return (
        bg: const Color(0xFF0A2A18),
        fg: const Color(0xFF34D399),
        border: const Color(0xFF34D399),
      );
  }
}

// ── User row ───────────────────────────────────────────────────────────────────
class _UserRow extends StatefulWidget {
  final AdminUser user;
  final _T t;
  final bool isLast;
  final bool isNarrow;
  final VoidCallback onDelete;
  final VoidCallback onBan;
  final VoidCallback onSuspend;
  final VoidCallback onUnban;
  final VoidCallback onViewUploads;

  const _UserRow({
    required this.user,
    required this.t,
    required this.isLast,
    required this.isNarrow,
    required this.onDelete,
    required this.onBan,
    required this.onSuspend,
    required this.onUnban,
    required this.onViewUploads,
  });

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hover = false;

  String get _initials {
    final parts = widget.user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.user.name.isNotEmpty
        ? widget.user.name[0].toUpperCase()
        : '?';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final t = widget.t;
    final roleColors = _roleBadgeColors(u.role);
    final statusColors = _statusBadgeColors(u.status);
    final isBannedOrSuspended = u.status == 'banned' || u.status == 'suspended';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover ? t.surface2 : t.surface,
          border: widget.isLast
              ? null
              : Border(bottom: BorderSide(color: t.border)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: widget.isNarrow
            // ── Narrow (mobile) ──────────────────────────────────
            ? Row(
                children: [
                  _UserAvatar(initials: _initials, t: t),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          u.email,
                          style: TextStyle(fontSize: 11, color: t.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: u.status.toUpperCase(),
                    bg: statusColors.bg,
                    fg: statusColors.fg,
                    border: statusColors.border,
                  ),
                  const SizedBox(width: 8),
                  _UserActionsMenu(
                    u: u,
                    t: t,
                    isBannedOrSuspended: isBannedOrSuspended,
                    onBan: widget.onBan,
                    onSuspend: widget.onSuspend,
                    onUnban: widget.onUnban,
                    onViewUploads: widget.onViewUploads,
                    onDelete: widget.onDelete,
                  ),
                ],
              )
            // ── Wide (desktop) ───────────────────────────────────
            : Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: _UserAvatar(initials: _initials, t: t),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      u.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      u.email,
                      style: TextStyle(fontSize: 12, color: t.textSub),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(
                        label: u.role.toUpperCase(),
                        bg: roleColors.bg,
                        fg: roleColors.fg,
                        border: roleColors.border,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(
                        label: u.status.toUpperCase(),
                        bg: statusColors.bg,
                        fg: statusColors.fg,
                        border: statusColors.border,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      _formatDate(u.createdAt),
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: _UserActionsMenu(
                      u: u,
                      t: t,
                      isBannedOrSuspended: isBannedOrSuspended,
                      onBan: widget.onBan,
                      onSuspend: widget.onSuspend,
                      onUnban: widget.onUnban,
                      onViewUploads: widget.onViewUploads,
                      onDelete: widget.onDelete,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  final String initials;
  final _T t;
  const _UserAvatar({required this.initials, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: t.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: t.border2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
        ),
      ),
    );
  }
}

// ── Colored badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg, fg, border;
  const _StatusBadge({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}

// ── Actions overflow menu ──────────────────────────────────────────────────────
class _UserActionsMenu extends StatelessWidget {
  final AdminUser u;
  final _T t;
  final bool isBannedOrSuspended;
  final VoidCallback onBan;
  final VoidCallback onSuspend;
  final VoidCallback onUnban;
  final VoidCallback onViewUploads;
  final VoidCallback onDelete;

  const _UserActionsMenu({
    required this.u,
    required this.t,
    required this.isBannedOrSuspended,
    required this.onBan,
    required this.onSuspend,
    required this.onUnban,
    required this.onViewUploads,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (u.role == 'admin') {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onViewUploads,
          child: Icon(
            Icons.folder_outlined,
            size: 15,
            color: const Color(0xFF60A5FA),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Uploads',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewUploads,
              child: Icon(
                Icons.folder_outlined,
                size: 15,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!isBannedOrSuspended) ...[
          Tooltip(
            message: 'Suspend',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onSuspend,
                child: Icon(
                  Icons.pause_circle_outline,
                  size: 15,
                  color: const Color(0xFFFBBF24), // amber
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Ban',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBan,
                child: Icon(
                  Icons.block_outlined,
                  size: 15,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ),
          ),
        ] else ...[
          Tooltip(
            message: 'Reinstate',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onUnban,
                child: Icon(
                  Icons.check_circle_outline,
                  size: 15,
                  color: const Color(0xFF34D399),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Tooltip(
          message: 'Delete',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.delete_outline,
                size: 15,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// ─── ADMIN MY RESOURCES TAB ───────────────────────────────────────────────────

class _MyResourcesView extends StatefulWidget {
  final AdminLoaded state;
  final _T t;
  const _MyResourcesView({required this.state, required this.t});

  @override
  State<_MyResourcesView> createState() => _MyResourcesViewState();
}

class _MyResourcesViewState extends State<_MyResourcesView> {
  static const _pageSize = 20;
  int _page = 0;
  String _search = '';
  String _typeFilter = '';

  // 🔥 FIREBASE: Replace with:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .where('uploaded_by', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //     .orderBy('uploaded_at', descending: true)
  //     .snapshots()
  //     .map((s) => s.docs.map((d) => ResourceModel.fromFirestore(d.data(), d.id)).toList())
  // ✅ FIX: use currentAdminId from state instead of hardcoded 'admin'
  // 🔥 FIREBASE: replace the entire getter with a Firestore stream:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .where('uploaded_by', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //     .orderBy('uploaded_at', descending: true)
  //     .snapshots()
  //     .map((snap) => snap.docs
  //       .map((d) => ResourceModel.fromFirestore(d.data(), d.id))
  //       .toList())
  //
  // 🔥 FIREBASE: 'uploaded_by' field stores the user's Firebase Auth UID
  //   NOT their display name — match against currentUser.uid always

  List<ResourceModel> get _myResources =>
      widget.state.resources
          .where((r) => r.uploadedBy == widget.state.currentAdminId)
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

  List<ResourceModel> get _filtered {
    return _myResources.where((r) {
      final ms =
          _search.isEmpty ||
          r.title.toLowerCase().contains(_search.toLowerCase()) ||
          r.categoryName.toLowerCase().contains(_search.toLowerCase());
      final mt = _typeFilter.isEmpty || r.fileType == _typeFilter;
      return ms && mt;
    }).toList();
  }

  List<ResourceModel> get _paginated {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  // ✅ FIX: minimum 1 page always — prevents "Page 1 of 0" display
  // 🔥 FIREBASE: when using cursor-based pagination replace this entirely:
  //   track _hasNextPage bool from Firestore query result size
  //   if (snapshot.docs.length == _pageSize) _hasNextPage = true
  int get _totalPages =>
      (_filtered.isEmpty ? 1 : (_filtered.length / _pageSize).ceil());

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  (Color, Color) _getTypeBadgeColors(String fileType) {
    switch (fileType) {
      case 'pdf':
        return (const Color(0xFF3A1010), const Color(0xFFFF6B6B));
      case 'word':
        return (const Color(0xFF0F2040), const Color(0xFF60A5FA));
      case 'ppt':
        return (const Color(0xFF3A1F05), const Color(0xFFFB923C));
      case 'excel':
        return (const Color(0xFF0A2A18), const Color(0xFF34D399));
      default:
        return (const Color(0xFF1A2A0A), const Color(0xFFA3E635));
    }
  }

  // ✅ FIX: added confirmation dialog before making resource public
  // Making a resource global is consequential — all students will see it
  // 🔥 FIREBASE: AdminResourceScopeChanged triggers Firestore update:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .doc(r.id)
  //     .update({'scope': 'global'})
  //   AND increments category global_resource_count:
  //   .collection('categories').doc(r.categoryId)
  //   .update({'global_resource_count': FieldValue.increment(1)})
  void _makePublic(BuildContext context, ResourceModel r) {
    _showConfirmDialog(
      context: context,
      t: widget.t,
      title: 'Make Resource Public',
      body:
          'Make "${r.title}" visible to all students?\n\n'
          '• It will appear in Global Resources\n'
          '• All students can view and download it',
      confirmLabel: 'Make Public',
      isDestructive: false,
      onConfirm: () => context.read<AdminBloc>().add(
        AdminResourceScopeChanged(id: r.id, scope: 'global'),
      ),
    );
  }

  // ✅ FIX: added confirmation dialog before making resource private
  // 🔥 FIREBASE: AdminResourceScopeChanged triggers Firestore update:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .doc(r.id)
  //     .update({'scope': 'private'})
  //   AND decrements category global_resource_count:
  //   .collection('categories').doc(r.categoryId)
  //   .update({'global_resource_count': FieldValue.increment(-1)})
  void _makePrivate(BuildContext context, ResourceModel r) {
    _showConfirmDialog(
      context: context,
      t: widget.t,
      title: 'Make Resource Private',
      body:
          'Hide "${r.title}" from all students?\n\n'
          '• It will only be visible to you\n'
          '• Students who saved it will lose access',
      confirmLabel: 'Make Private',
      isDestructive: true,
      onConfirm: () => context.read<AdminBloc>().add(
        AdminResourceScopeChanged(id: r.id, scope: 'private'),
      ),
    );
  }

  void _showUploadModal(BuildContext context) {
    final t = widget.t;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: _AdminUploadForm(
              t: t,
              categories: widget.state.categories,
              isLoading: widget.state.isActionLoading,
              defaultScope: ResourceScope.private,
              onSubmit: (data) {
                context.read<AdminBloc>().add(
                  AdminResourceUploadSubmitted(
                    title: data['title']!,
                    description: data['description']!,
                    categoryId: data['categoryId']!,
                    difficulty: data['difficulty']!,
                    tags: data['tags']!,
                    fileName: data['fileName']!,
                    fileType: data['fileType']!,
                    scope: data['scope'] ?? 'global',
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showViewModal(BuildContext context, ResourceModel r) {
    final t = widget.t;
    final (badgeBg, badgeFg) = _getTypeBadgeColors(r.fileType);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      border: Border.all(color: t.border2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        r.typeEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        Text(
                          '${r.categoryName} · ${r.difficultyLabel}',
                          style: TextStyle(fontSize: 12, color: t.textSub),
                        ),
                      ],
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 18, color: t.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: t.border, height: 1),
              const SizedBox(height: 16),

              // Details
              _ModalRow(label: 'File Type', value: r.typeLabel, t: t),
              _ModalRow(label: 'Category', value: r.categoryName, t: t),
              _ModalRow(label: 'Difficulty', value: r.difficultyLabel, t: t),
              _ModalRow(
                label: 'Uploaded',
                value: _formatDate(r.uploadedAt),
                t: t,
              ),
              // Scope badge
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        'Visibility',
                        style: TextStyle(
                          fontSize: 12,
                          color: t.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 65,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: r.isGlobal
                            ? const Color(0xFF0A2A18)
                            : t.surface2,
                        border: Border.all(
                          color: r.isGlobal
                              ? const Color(0xFF34D399)
                              : t.border2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r.isGlobal ? 'Global' : 'Private',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: r.isGlobal
                              ? const Color(0xFF34D399)
                              : t.textSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Description if present
              if (r.description.isNotEmpty) ...[
                _ModalRow(label: 'Description', value: r.description, t: t),
              ],

              // Tags if present
              if (r.tags.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 12,
                            color: t.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: r.tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.surface2,
                                    border: Border.all(color: t.border2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: t.textSub,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 4),

              // Open File button
              // 🔥 FIREBASE: r.fileUrl will be populated after Storage upload
              //   Enable by storing download URL in Firestore 'file_url' field
              SizedBox(
                width: double.infinity,
                child: _hasFileUrl(r)
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _openFile(r.fileUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: t.isDark ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  size: 14,
                                  color: t.isDark ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Open File',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: t.isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    // Disabled state — no fileUrl yet
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: t.surface2,
                          border: Border.all(color: t.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 14,
                              color: t.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Open File',
                              style: TextStyle(
                                fontSize: 13,
                                color: t.textMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 🔥 FIREBASE: remove this badge once fileUrl is populated
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1A05),
                                border: Border.all(
                                  color: const Color(0xFF4A3010),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Firebase pending',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFFB923C),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFileUrl(ResourceModel r) => r.fileUrl.isNotEmpty;

  Future<void> _openFile(String url) async {
    // 🔥 FIREBASE: url_launcher — add to pubspec.yaml:
    //   url_launcher: ^6.3.0
    // Then import: import 'package:url_launcher/url_launcher.dart';
    // Uncomment below:
    // final uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // }
  }

  void _confirmDelete(BuildContext context, ResourceModel r) {
    _showConfirmDialog(
      context: context,
      t: widget.t,
      title: 'Delete Resource',
      body: 'Delete "${r.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      // 🔥 FIREBASE: Replace with:
      //   await FirebaseFirestore.instance
      //     .collection('resources')
      //     .doc(r.id)
      //     .delete();
      //   // Also delete from Storage:
      //   await FirebaseStorage.instance
      //     .refFromURL(r.fileUrl)
      //     .delete();
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminResourceDeleteRequested(r.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Resources',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your private and public uploads.',
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${_myResources.length} total',
                style: TextStyle(fontSize: 13, color: t.textMuted),
              ),
              const SizedBox(width: 12),
              // ✅ FIX: removed _showUpload toggle — button always opens modal
              // _showUpload state was dead (toggled label but never showed inline form)
              // 🔥 FIREBASE: upload modal calls _repo.uploadResource() which will
              //   trigger Storage upload + Firestore write when Firebase is connected
              _HoverBtn(
                label: '↑  Upload',
                t: t,
                primary: true,
                onTap: () => _showUploadModal(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Search + filter ──────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 260,
                child: _SearchField(
                  hint: 'Search by title or category...',
                  t: t,
                  onChanged: (q) => setState(() {
                    _search = q;
                    _page = 0;
                  }),
                ),
              ),
              _FilterDropdown(
                hint: 'All types',
                value: _typeFilter.isEmpty ? null : _typeFilter,
                items: const [
                  ('pdf', 'PDF'),
                  ('word', 'Word'),
                  ('ppt', 'PPT'),
                  ('excel', 'Excel'),
                  ('article', 'Article'),
                ],
                t: t,
                onChanged: (v) => setState(() {
                  _typeFilter = v ?? '';
                  _page = 0;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Count + page info
          Row(
            children: [
              Text(
                '${_filtered.length} files',
                style: TextStyle(fontSize: 12, color: t.textMuted),
              ),
              if (_totalPages > 1) ...[
                const SizedBox(width: 8),
                Text(
                  '· Page ${_page + 1} of $_totalPages',
                  style: TextStyle(fontSize: 12, color: t.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // ── Table ────────────────────────────────────────────────
          if (_paginated.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 36,
                      color: t.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _search.isNotEmpty
                          ? 'No files match your search.'
                          : 'No uploads yet. Use the Upload button above.',
                      style: TextStyle(color: t.textSub, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  children: [
                    // Table header
                    if (!isNarrow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: t.surface2,
                          border: Border(bottom: BorderSide(color: t.border)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 58), // type badge
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Title',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                'Visibility',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                  color: t.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 80), // actions
                          ],
                        ),
                      ),

                    // Rows
                    ..._paginated.asMap().entries.map((entry) {
                      final i = entry.key;
                      final r = entry.value;
                      final isLast = i == _paginated.length - 1;
                      return _MyResourceRow(
                        resource: r,
                        t: t,
                        isLast: isLast,
                        isNarrow: isNarrow,
                        badgeColors: _getTypeBadgeColors(r.fileType),
                        formattedDate: _formatDate(r.uploadedAt),
                        onView: () => _showViewModal(context, r),
                        onDelete: () => _confirmDelete(context, r),
                        onMakePublic: () => _makePublic(context, r),
                        onMakePrivate: () => _makePrivate(context, r),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // ── Pagination ───────────────────────────────────────────
          if (_totalPages > 1) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _page > 0 ? 1.0 : 0.35,
                  child: _HoverBtn(
                    label: '← Prev',
                    t: t,
                    primary: false,
                    onTap: _page > 0 ? () => setState(() => _page--) : () {},
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_page + 1} / $_totalPages',
                  style: TextStyle(fontSize: 13, color: t.textSub),
                ),
                const SizedBox(width: 12),
                Opacity(
                  opacity: _page < _totalPages - 1 ? 1.0 : 0.35,
                  child: _HoverBtn(
                    label: 'Next →',
                    t: t,
                    primary: false,
                    onTap: _page < _totalPages - 1
                        ? () => setState(() => _page++)
                        : () {},
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Single My Resource row ────────────────────────────────────────────────────
class _MyResourceRow extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  final bool isLast;
  final bool isNarrow;
  final (Color, Color) badgeColors;
  final String formattedDate;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback onMakePublic;
  final VoidCallback onMakePrivate;

  const _MyResourceRow({
    required this.resource,
    required this.t,
    required this.isLast,
    required this.isNarrow,
    required this.badgeColors,
    required this.formattedDate,
    required this.onView,
    required this.onDelete,
    required this.onMakePublic,
    required this.onMakePrivate,
  });

  @override
  State<_MyResourceRow> createState() => _MyResourceRowState();
}

class _MyResourceRowState extends State<_MyResourceRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;
    final badgeBg = widget.badgeColors.$1;
    final badgeFg = widget.badgeColors.$2;
    final isGlobal = r.isGlobal;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onView,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _hover ? t.surface2 : t.surface,
            border: widget.isLast
                ? null
                : Border(bottom: BorderSide(color: t.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: widget.isNarrow
              // ── Narrow (mobile) ─────────────────────────────────
              ? Row(
                  children: [
                    // Badge
                    SizedBox(
                      width: 58,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            r.typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        r.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Scope pill
                    _ScopePill(isGlobal: isGlobal, t: t),
                    const SizedBox(width: 8),
                    // Delete
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Icon(
                          Icons.delete_outline,
                          size: 15,
                          color: t.textMuted,
                        ),
                      ),
                    ),
                  ],
                )
              // ── Wide (desktop) ──────────────────────────────────
              : Row(
                  children: [
                    // Type badge
                    SizedBox(
                      width: 58,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            r.typeLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeFg,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Category
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.categoryName,
                        style: TextStyle(fontSize: 13, color: t.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Visibility
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _ScopePill(isGlobal: isGlobal, t: t),
                      ),
                    ),
                    // Date
                    SizedBox(
                      width: 100,
                      child: Text(
                        widget.formattedDate,
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ),
                    // Actions
                    SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Make public / make private toggle
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: isGlobal
                                  ? widget.onMakePrivate
                                  : widget.onMakePublic,
                              child: Tooltip(
                                message: isGlobal
                                    ? 'Make Private'
                                    : 'Make Public',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isGlobal
                                        ? const Color(0xFF0A2A18)
                                        : t.surface2,
                                    border: Border.all(
                                      color: isGlobal
                                          ? const Color(0xFF34D399)
                                          : t.border2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    isGlobal
                                        ? Icons.public
                                        : Icons.lock_outline,
                                    size: 12,
                                    color: isGlobal
                                        ? const Color(0xFF34D399)
                                        : t.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: widget.onDelete,
                              child: Icon(
                                Icons.delete_outline,
                                size: 15,
                                color: t.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Scope pill widget ─────────────────────────────────────────────────────────
class _ScopePill extends StatelessWidget {
  final bool isGlobal;
  final _T t;
  const _ScopePill({required this.isGlobal, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isGlobal ? const Color(0xFF0A2A18) : t.surface2,
        border: Border.all(
          color: isGlobal ? const Color(0xFF34D399) : t.border2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isGlobal ? 'Global' : 'Private',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isGlobal ? const Color(0xFF34D399) : t.textSub,
        ),
      ),
    );
  }
}

// ─── ADMIN PROFILE TAB — GITHUB-STYLE ────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  final _T t;
  final AdminLoaded state;
  const _ProfileTab({required this.t, required this.state});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: seed working copies from state — survives tab switches
    // 🔥 FIREBASE: override these with Firestore values after load
    _name = widget.state.currentAdminName;
    _email = widget.state.currentAdminEmail;
    _bio = 'StudyHub administrator.';
  }

  // ✅ FIX: initialize from state instead of hardcoded strings
  // these are now working copies only — source of truth is AdminLoaded state
  // 🔥 FIREBASE: on initState, load from Firestore:
  //   final doc = await FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(FirebaseAuth.instance.currentUser!.uid)
  //     .get();
  //   setState(() {
  //     _name  = doc['name']  ?? '';
  //     _email = doc['email'] ?? '';
  //     _bio   = doc['bio']   ?? '';
  //   });
  late String _name;
  late String _email;
  late String _bio;

  String get _initials {
    if (_name.trim().isEmpty) return '?';
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  // ✅ FIX: use currentAdminId from state instead of hardcoded 'admin'
  // 🔥 FIREBASE: replace entire getter with a Firestore stream:
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .where('uploaded_by', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
  //     .orderBy('uploaded_at', descending: true)
  //     .snapshots()
  //     .map((snap) => snap.docs
  //       .map((d) => ResourceModel.fromFirestore(d.data(), d.id))
  //       .toList())
  List<ResourceModel> get _myUploads =>
      widget.state.resources
          .where((r) => r.uploadedBy == widget.state.currentAdminId)
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

  // Group uploads by month label e.g. "Apr 2026"
  Map<String, List<ResourceModel>> get _groupedByMonth {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final Map<String, List<ResourceModel>> map = {};
    for (final r in _myUploads) {
      final key = '${months[r.uploadedAt.month - 1]} ${r.uploadedAt.year}';
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  void _logout() {
    // 🔥 FIREBASE: await FirebaseAuth.instance.signOut();
    context.go('/');
  }

  void _deleteAccount() {
    // 🔥 FIREBASE:
    //   await FirebaseAuth.instance.currentUser!.delete();
    //   // Re-auth may be needed if session is old:
    //   // await user.reauthenticateWithCredential(credential);
    //   // Do NOT delete Firestore doc here — use a Cloud Function
    //   //   trigger: onDelete user → clean up their Firestore data
    context.go('/');
  }

  void _showEditModal() {
    final t = widget.t;
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final bioCtrl = TextEditingController(text: _bio);
    final currPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: t.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: t.border),
          ),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                      const Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _Label('Name', required: true, t: t),
                  const SizedBox(height: 8),
                  _Field(ctrl: nameCtrl, hint: 'Full name', t: t),
                  const SizedBox(height: 14),

                  _Label('Email', required: true, t: t),
                  const SizedBox(height: 8),
                  _Field(ctrl: emailCtrl, hint: 'Email address', t: t),
                  const SizedBox(height: 6),
                  // ✅ FIX: warn admin that email change requires re-authentication
                  // 🔥 FIREBASE: email update flow:
                  //   FirebaseAuth requires recent login before updateEmail()
                  //   If session is old → catch FirebaseAuthException code:'requires-recent-login'
                  //   Then prompt re-auth with EmailAuthProvider.credential(email, password)
                  //   await user.reauthenticateWithCredential(credential)
                  //   Then retry updateEmail()
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1A05),
                      border: Border.all(color: const Color(0xFF4A3010)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 13,
                          color: Color(0xFFFB923C),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Changing your email requires re-authentication.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFB923C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _Label('Bio', required: false, t: t),
                  const SizedBox(height: 8),
                  _Field(
                    ctrl: bioCtrl,
                    hint: 'About you...',
                    t: t,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 16),

                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _Label('Current Password', required: false, t: t),
                  const SizedBox(height: 8),
                  _Field(
                    ctrl: currPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),

                  _Label('New Password', required: false, t: t),
                  const SizedBox(height: 8),
                  _Field(
                    ctrl: newPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),

                  // ✅ FIX: added confirm password field
                  // 🔥 FIREBASE: validate both fields match before calling:
                  //   await FirebaseAuth.instance.currentUser!
                  //     .updatePassword(newPassCtrl.text)
                  _Label('Confirm New Password', required: false, t: t),
                  const SizedBox(height: 8),
                  _Field(
                    ctrl: confirmPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 6),
                  // Password match indicator
                  ValueListenableBuilder(
                    valueListenable: confirmPassCtrl,
                    builder: (_, __, ___) {
                      // only show when both fields have content
                      if (newPassCtrl.text.isEmpty ||
                          confirmPassCtrl.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final matches = newPassCtrl.text == confirmPassCtrl.text;
                      return Row(
                        children: [
                          Icon(
                            matches
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 13,
                            color: matches
                                ? const Color(0xFF34D399)
                                : const Color(0xFFFF6B6B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            matches
                                ? 'Passwords match'
                                : 'Passwords do not match',
                            style: TextStyle(
                              fontSize: 11,
                              color: matches
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: _SubmitBtn(
                      isLoading: isSaving,
                      t: t,
                      label: 'Save Changes',
                      onTap: () async {
                        // Validate required fields
                        if (nameCtrl.text.trim().isEmpty) return;

                        // ✅ FIX: block save if passwords don't match
                        // 🔥 FIREBASE: this check must also run server-side
                        if (newPassCtrl.text.isNotEmpty &&
                            newPassCtrl.text != confirmPassCtrl.text) {
                          setS(() => isSaving = false);
                          return;
                        }

                        setS(() => isSaving = true);
                        await Future.delayed(const Duration(milliseconds: 600));

                        // 🔥 FIREBASE: STEP 1 — update Firebase Auth display name:
                        //   await FirebaseAuth.instance.currentUser!
                        //     .updateDisplayName(nameCtrl.text.trim());
                        //
                        // 🔥 FIREBASE: STEP 2 — update email (requires re-auth first):
                        //   try {
                        //     await FirebaseAuth.instance.currentUser!
                        //       .updateEmail(emailCtrl.text.trim());
                        //   } on FirebaseAuthException catch (e) {
                        //     if (e.code == 'requires-recent-login') {
                        //       // show re-auth dialog before proceeding
                        //     }
                        //   }
                        //
                        // 🔥 FIREBASE: STEP 3 — update password if provided:
                        //   if (newPassCtrl.text.isNotEmpty) {
                        //     await FirebaseAuth.instance.currentUser!
                        //       .updatePassword(newPassCtrl.text);
                        //   }
                        //
                        // 🔥 FIREBASE: STEP 4 — update Firestore user document:
                        //   await FirebaseFirestore.instance
                        //     .collection('users')
                        //     .doc(FirebaseAuth.instance.currentUser!.uid)
                        //     .update({
                        //       'name':       nameCtrl.text.trim(),
                        //       'bio':        bioCtrl.text.trim(),
                        //       'updated_at': FieldValue.serverTimestamp(),
                        //     });
                        //
                        // 🔥 FIREBASE: STEP 5 — update AdminLoaded state with new identity:
                        //   context.read<AdminBloc>().add(AdminProfileUpdated(
                        //     name:  nameCtrl.text.trim(),
                        //     email: emailCtrl.text.trim(),
                        //   ));

                        // ✅ update local working copies so UI reflects changes immediately
                        setState(() {
                          if (nameCtrl.text.trim().isNotEmpty)
                            _name = nameCtrl.text.trim();
                          if (emailCtrl.text.trim().isNotEmpty)
                            _email = emailCtrl.text.trim();
                          _bio = bioCtrl.text.trim();
                        });

                        setS(() => isSaving = false);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: widget.t.surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: widget.t.border),
                              ),
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 14,
                                    color: widget.t.text,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Profile saved',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.t.text,
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final grouped = _groupedByMonth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final isWide = constraints.maxWidth > 600;

              // ── LEFT COLUMN ────────────────────────────────────────
              final leftCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border2, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Text(
                    _email,
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                  const SizedBox(height: 8),

                  // ADMIN badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: t.surface2,
                      border: Border.all(color: t.border2),
                      borderRadius: BorderRadius.circular(4),
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
                  const SizedBox(height: 16),

                  // Bio
                  if (_bio.isNotEmpty) ...[
                    Text(
                      _bio,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Edit Profile button
                  SizedBox(
                    width: double.infinity,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showEditModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: t.surface2,
                            border: Border.all(color: t.border2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Edit profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 20),

                  // Stats
                  _ProfileStat(
                    icon: Icons.upload_file_outlined,
                    label: 'uploads',
                    value: '${_myUploads.length}',
                    t: t,
                  ),
                  const SizedBox(height: 10),
                  _ProfileStat(
                    icon: Icons.folder_outlined,
                    label: 'categories',
                    value: '${widget.state.categories.length}',
                    t: t,
                  ),
                  const SizedBox(height: 10),
                  _ProfileStat(
                    icon: Icons.people_outline,
                    label: 'users',
                    value: '${widget.state.totalUsers}',
                    t: t,
                  ),
                  const SizedBox(height: 20),

                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 20),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: t.surface2,
                            border: Border.all(color: t.border2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Delete Account
                  if (!_showDeleteConfirm)
                    SizedBox(
                      width: double.infinity,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showDeleteConfirm = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1010),
                              border: Border.all(
                                color: const Color(0xFF4A1A1A),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Delete account',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      'This permanently deletes your Firebase Auth account. Cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _HoverBtn(
                            label: 'Cancel',
                            t: t,
                            primary: false,
                            onTap: () =>
                                setState(() => _showDeleteConfirm = false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _deleteAccount,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC3333),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Yes, Delete',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );

              // ── RIGHT COLUMN — month-grouped uploads ────────────────
              final rightCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.isEmpty
                    ? [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.upload_file_outlined,
                                  size: 36,
                                  color: t.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No uploads yet.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: t.textSub,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Go to Global Resources to upload.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    : grouped.entries.map((entry) {
                        final monthLabel = entry.key;
                        final resources = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Month divider — like GitHub activity
                              Row(
                                children: [
                                  Text(
                                    monthLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: t.textSub,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Divider(
                                      color: t.border,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Rows for this month
                              Container(
                                decoration: BoxDecoration(
                                  color: t.surface,
                                  border: Border.all(color: t.border),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Column(
                                    children: resources.asMap().entries.map((
                                      e,
                                    ) {
                                      final isLast =
                                          e.key == resources.length - 1;
                                      return Column(
                                        children: [
                                          _RecentUploadRow(
                                            resource: e.value,
                                            t: t,
                                            formattedDate: _formatDate(
                                              e.value.uploadedAt,
                                            ),
                                          ),
                                          if (!isLast)
                                            Divider(
                                              color: t.border,
                                              height: 1,
                                              thickness: 1,
                                            ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              );

              // Assemble layout
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: leftCol),
                    const SizedBox(width: 32),
                    Expanded(child: rightCol),
                  ],
                );
              }
              return Column(
                children: [leftCol, const SizedBox(height: 24), rightCol],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Profile stat row (icon + value + label) ───────────────────────────────────
class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final _T t;
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: t.textMuted),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: t.textSub)),
      ],
    );
  }
}

// ── Recent upload row ─────────────────────────────────────────────────────────
class _RecentUploadRow extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  final String formattedDate;
  const _RecentUploadRow({
    required this.resource,
    required this.t,
    required this.formattedDate,
  });

  @override
  State<_RecentUploadRow> createState() => _RecentUploadRowState();
}

class _RecentUploadRowState extends State<_RecentUploadRow> {
  bool _hover = false;

  (Color, Color) get _typeColors {
    switch (widget.resource.type) {
      case ResourceType.pdf:
        return (const Color(0xFF3A1010), const Color(0xFFFF6B6B));
      case ResourceType.word:
        return (const Color(0xFF0F2040), const Color(0xFF60A5FA));
      case ResourceType.ppt:
        return (const Color(0xFF3A1F05), const Color(0xFFFB923C));
      case ResourceType.excel:
        return (const Color(0xFF0A2A18), const Color(0xFF34D399));
      default:
        return (const Color(0xFF1A2A0A), const Color(0xFFA3E635));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;
    final (badgeBg, badgeFg) = _typeColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        color: _hover ? t.surface2 : Colors.transparent,
        child: Row(
          children: [
            // Fixed-width badge so titles always align
            SizedBox(
              width: 58,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    r.typeLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeFg,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
            // Title + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    r.categoryName,
                    style: TextStyle(fontSize: 11, color: t.textMuted),
                  ),
                ],
              ),
            ),
            // Date (day + month only, year shown in the group header)
            Text(
              widget.formattedDate,
              style: TextStyle(fontSize: 11, color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int colorIndex;
  final double width;
  final _T t;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AdminCategoryCard({
    required this.category,
    required this.colorIndex,
    required this.width,
    required this.t,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AdminCategoryCard> createState() => _AdminCategoryCardState();
}

class _AdminCategoryCardState extends State<_AdminCategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.category;
    final t = widget.t;
    final cc = _cc(widget.colorIndex, t.isDark);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hover ? cc.bg : t.surface,
          border: Border.all(
            color: _hover ? cc.border : t.border,
            width: _hover ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: cc.icon,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(c.emoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: t.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: t.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              c.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: t.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c.description,
              style: TextStyle(fontSize: 12, color: t.textSub, height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              '${c.resourceCount} resources',
              style: TextStyle(
                fontSize: 11,
                color: cc.border.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN UPLOAD FORM (inline) — UPDATED with preselectedCategoryId
// ─────────────────────────────────────────────────────────────────────────────
// REPLACE entire _AdminUploadForm StatefulWidget + State:

class _AdminUploadForm extends StatefulWidget {
  final _T t;
  final String? preselectedCategoryId;
  final ResourceScope defaultScope;
  final List<CategoryModel> categories;
  final bool isLoading;
  final Function(Map<String, String>) onSubmit;
  const _AdminUploadForm({
    required this.t,
    this.preselectedCategoryId,
    required this.categories,
    required this.isLoading,
    required this.onSubmit,
    required this.defaultScope,
  });

  @override
  State<_AdminUploadForm> createState() => _AdminUploadFormState();
}

class _AdminUploadFormState extends State<_AdminUploadForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _categoryId = '';
  String _difficulty = '';
  late ResourceScope _scope;
  String _errorMsg = '';

  // 🔥 FIREBASE-READY: these hold the actual picked file info
  String? _pickedFileName; // e.g. "lecture1.pdf"
  String? _pickedFilePath; // full local path — used for Firebase Storage upload
  String? _pickedFileType; // 'pdf' | 'word' | 'ppt' | 'excel'
  int? _pickedFileBytes; // size in bytes, shown to user
  bool _isPicking = false;

  // Maps extension → our internal type key
  static const _extToType = {
    'pdf': 'pdf',
    'doc': 'word',
    'docx': 'word',
    'ppt': 'ppt',
    'pptx': 'ppt',
    'xls': 'excel',
    'xlsx': 'excel',
  };

  static const _typeEmoji = {
    'pdf': '📄',
    'word': '📝',
    'ppt': '📑',
    'excel': '📊',
  };

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  void initState() {
    super.initState();
    _scope = widget.defaultScope;
    if (widget.preselectedCategoryId != null) {
      _categoryId = widget.preselectedCategoryId!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  // 🔥 FIREBASE: when backend team plugs in storage, they replace _pickedFilePath
  // with an actual upload call here before calling onSubmit
  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
        withData: true,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = (file.extension ?? '').toLowerCase();
        final type = _extToType[ext];

        if (type == null) {
          setState(() => _errorMsg = 'Unsupported file type: .$ext');
        } else {
          setState(() {
            _pickedFileName = file.name;
            _pickedFilePath =
                file.path; // 🔥 FIREBASE: pass this to StorageService.upload()
            //  _pickedFileData = file.bytes; // non-null on web, null on desktop
            _pickedFileType = type;
            _pickedFileBytes = file.size;
            _errorMsg = '';

            // Auto-fill title if empty
            if (_titleCtrl.text.trim().isEmpty) {
              // Strip extension and prettify: "lecture_1.pdf" → "lecture 1"
              final nameNoExt = file.name.contains('.')
                  ? file.name.substring(0, file.name.lastIndexOf('.'))
                  : file.name;
              _titleCtrl.text = nameNoExt
                  .replaceAll('_', ' ')
                  .replaceAll('-', ' ');
            }
          });
        }
      }
    } catch (e) {
      setState(() => _errorMsg = 'Could not open file picker: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _submit() {
    setState(() => _errorMsg = '');

    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Please enter a title.');
      return;
    }
    if (_pickedFileName == null) {
      setState(() => _errorMsg = 'Please select a file.');
      return;
    }
    if (_categoryId.isEmpty) {
      setState(() => _errorMsg = 'Please select a category.');
      return;
    }
    if (_difficulty.isEmpty) {
      setState(() => _errorMsg = 'Please select a difficulty.');
      return;
    }

    // 🔥 FIREBASE: backend team should upload file here first:
    //   final downloadUrl = await StorageService.upload(
    //     path: 'resources/$_categoryId/${DateTime.now().millisecondsSinceEpoch}_$_pickedFileName',
    //     localPath: _pickedFilePath!,
    //   );
    // Then pass downloadUrl in the map below as 'fileUrl'

    // 🔥 FIREBASE web upload:
    // await FirebaseStorage.instance
    //   .ref('resources/$_categoryId/$_pickedFileName')
    //   .putData(_pickedFileData!); // use this on web
    //
    // 🔥 FIREBASE desktop upload:
    // await FirebaseStorage.instance
    //   .ref('resources/$_categoryId/$_pickedFileName')
    //   .putFile(File(_pickedFilePath!)); // use this on desktop

    widget.onSubmit({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'categoryId': _categoryId,
      'difficulty': _difficulty,
      'tags': _tagsCtrl.text.trim(),
      'fileName': _pickedFileName!,
      'fileType': _pickedFileType!,
      'filePath': _pickedFilePath ?? '', // 🔥 FIREBASE: local path for upload
      // 'fileUrl'  : downloadUrl,             // 🔥 FIREBASE: uncomment after upload
      'scope': _scope == ResourceScope.private ? 'private' : 'global',
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Resource',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
          ),
          const SizedBox(height: 20),

          // ── File picker (moved to TOP so title can auto-fill) ──────
          _Label('File', required: true, t: t),
          const SizedBox(height: 8),
          _FilePicker(
            t: t,
            isPicking: _isPicking,
            fileName: _pickedFileName,
            fileType: _pickedFileType,
            fileBytes: _pickedFileBytes,
            onPick: _pickFile,
            onClear: () => setState(() {
              _pickedFileName = null;
              _pickedFilePath = null;
              _pickedFileType = null;
              _pickedFileBytes = null;
            }),
            typeEmoji: _typeEmoji,
          ),
          const SizedBox(height: 16),
          // ADD after the file picker SizedBox(height: 16):
          _Label('Visibility', required: true, t: t),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(
                label: '🔒  Private',
                selected: _scope == ResourceScope.private,
                t: t,
                onTap: () => setState(() => _scope = ResourceScope.private),
              ),
              _Chip(
                label: '🌐  Global',
                selected: _scope == ResourceScope.global,
                t: t,
                onTap: () => setState(() => _scope = ResourceScope.global),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _scope == ResourceScope.private
                ? 'Only visible to you in My Resources.'
                : 'Visible to all users in Global Resources.',
            style: TextStyle(fontSize: 11, color: t.textMuted),
          ),
          const SizedBox(height: 16),

          // ── Title ─────────────────────────────────────────────────
          _Label('Title', required: true, t: t),
          const SizedBox(height: 8),
          _Field(ctrl: _titleCtrl, hint: 'e.g. HTML Basics', t: t),
          const SizedBox(height: 16),

          // ── Category + Difficulty ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Category', required: true, t: t),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: t.surface2,
                        border: Border.all(color: t.border2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _categoryId.isEmpty ? null : _categoryId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: t.surface,
                        hint: Text(
                          'Select category',
                          style: TextStyle(fontSize: 13, color: t.textMuted),
                        ),
                        style: TextStyle(fontSize: 13, color: t.text),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: t.textMuted,
                        ),
                        items: widget.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  '${c.emoji}  ${c.name}',
                                  style: TextStyle(fontSize: 13, color: t.text),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Difficulty', required: true, t: t),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Beginner', 'Intermediate']
                          .map(
                            (d) => _Chip(
                              label: d,
                              selected: _difficulty == d.toLowerCase(),
                              t: t,
                              onTap: () =>
                                  setState(() => _difficulty = d.toLowerCase()),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Description ───────────────────────────────────────────
          _Label('Description', required: false, t: t),
          const SizedBox(height: 8),
          _Field(
            ctrl: _descCtrl,
            hint: 'Brief description of this resource...',
            t: t,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // ── Tags ──────────────────────────────────────────────────
          _Label('Tags', required: false, t: t),
          const SizedBox(height: 8),
          _Field(ctrl: _tagsCtrl, hint: 'e.g. HTML, CSS, beginner', t: t),

          // ── Error ─────────────────────────────────────────────────
          if (_errorMsg.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1010),
                border: Border.all(color: const Color(0xFF4A2020)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _errorMsg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _SubmitBtn(
              isLoading: widget.isLoading,
              t: t,
              label: 'Upload Resource',
              onTap: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

// ── File picker widget ────────────────────────────────────────────────────────
class _FilePicker extends StatelessWidget {
  final _T t;
  final bool isPicking;
  final String? fileName;
  final String? fileType;
  final int? fileBytes;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final Map<String, String> typeEmoji;

  const _FilePicker({
    required this.t,
    required this.isPicking,
    required this.fileName,
    required this.fileType,
    required this.fileBytes,
    required this.onPick,
    required this.onClear,
    required this.typeEmoji,
  });

  String _fmt(int b) {
    if (b < 1024) return '${b}B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)}KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    // File already picked — show file info pill
    if (fileName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface2,
          border: Border.all(color: t.border2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              typeEmoji[fileType] ?? '📄',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileBytes != null)
                    Text(
                      _fmt(fileBytes!),
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                ],
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: t.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    // No file yet — show drop zone / pick button
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isPicking ? null : onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: t.surface2,
            border: Border.all(
              color: t.border2,
              // dashed effect via strokeAlign won't work in Flutter,
              // so just use a slightly different color
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isPicking
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.textMuted,
                    ),
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        size: 28,
                        color: t.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to select a file',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: t.textSub,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, Word, PowerPoint, Excel',
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────
void _showConfirmDialog({
  required BuildContext context,
  required _T t,
  required String title,
  required String body,
  required String confirmLabel,
  required bool isDestructive,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => Dialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: t.border),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(fontSize: 13, color: t.textSub, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HoverBtn(
                    label: 'Cancel',
                    t: t,
                    primary: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? const Color(0xFFCC3333)
                              : (t.isDark ? Colors.white : Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            confirmLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDestructive
                                  ? Colors.white
                                  : (t.isDark ? Colors.black : Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED PAGE SWITCHER
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedPageSwitcher extends StatefulWidget {
  final int index;
  final List<Widget> pages;
  const _AnimatedPageSwitcher({required this.index, required this.pages});

  @override
  State<_AnimatedPageSwitcher> createState() => _AnimatedPageSwitcherState();
}

class _AnimatedPageSwitcherState extends State<_AnimatedPageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _cur = 0;

  @override
  void initState() {
    super.initState();
    _cur = widget.index;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPageSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _ctrl.reverse().then((_) {
        setState(() => _cur = widget.index);
        _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.pages[_cur]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final _T t;
  const _SectionHeader({required this.title, required this.t});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: t.textSub,
      ),
    );
  }
}

// ── Search field with external controller (used by User Uploads pre-filter) ──
// ✅ FIX: converted to StatefulWidget so clear button
// can reactively show/hide as user types
// 🔥 FIREBASE: no changes needed here for Firebase integration
// this is purely a UI/state fix
class _SearchFieldWithController extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final _T t;
  final ValueChanged<String> onChanged;
  const _SearchFieldWithController({
    required this.hint,
    required this.controller,
    required this.t,
    required this.onChanged,
  });

  @override
  State<_SearchFieldWithController> createState() =>
      _SearchFieldWithControllerState();
}

class _SearchFieldWithControllerState
    extends State<_SearchFieldWithController> {
  @override
  void initState() {
    super.initState();
    // ✅ listen to controller so clear button rebuilds on every keystroke
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: t.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: TextStyle(fontSize: 13, color: t.text),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(fontSize: 13, color: t.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // ✅ now correctly rebuilds when controller text changes
          if (widget.controller.text.isNotEmpty)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                child: Icon(Icons.close, size: 14, color: t.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String hint;
  final _T t;
  final ValueChanged<String> onChanged;
  const _SearchField({
    required this.hint,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: t.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, color: t.text),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: t.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<(String, String)> items;
  final _T t;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: t.surface,
        hint: Text(hint, style: TextStyle(fontSize: 13, color: t.textMuted)),
        style: TextStyle(fontSize: 13, color: t.text),
        icon: Icon(Icons.keyboard_arrow_down, size: 16, color: t.textMuted),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              hint,
              style: TextStyle(fontSize: 13, color: t.textMuted),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem(
              value: item.$1,
              child: Text(
                item.$2,
                style: TextStyle(fontSize: 13, color: t.text),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ModalTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final _T t;
  const _ModalTextField({
    required this.ctrl,
    required this.hint,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: t.text),
      cursorColor: t.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: t.textMuted),
        filled: true,
        fillColor: t.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: t.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: t.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: t.isDark ? Colors.white54 : Colors.black38,
          ),
        ),
      ),
    );
  }
}

class _ModalRow extends StatelessWidget {
  final String label, value;
  final _T t;
  const _ModalRow({required this.label, required this.value, required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: t.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: t.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final _T t;
  final VoidCallback onTap;
  const _ModalBtn({
    required this.label,
    required this.primary,
    required this.t,
    required this.onTap,
  });

  @override
  State<_ModalBtn> createState() => _ModalBtnState();
}

class _ModalBtnState extends State<_ModalBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? (widget.t.isDark ? Colors.white : Colors.black)
        : widget.t.surface2;
    final fg = widget.primary
        ? (widget.t.isDark ? Colors.black : Colors.white)
        : widget.t.text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _hover
                ? (widget.primary
                      ? (widget.t.isDark
                            ? const Color(0xFFDDDDDD)
                            : const Color(0xFF222222))
                      : widget.t.hover)
                : bg,
            border: Border.all(color: widget.t.border2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverBtn extends StatefulWidget {
  final String label;
  final _T t;
  final bool primary;
  final VoidCallback onTap;
  const _HoverBtn({
    required this.label,
    required this.t,
    this.primary = true,
    required this.onTap,
  });

  @override
  State<_HoverBtn> createState() => _HoverBtnState();
}

class _HoverBtnState extends State<_HoverBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final bg = widget.primary
        ? (t.isDark ? Colors.white : Colors.black)
        : t.surface2;
    final fg = widget.primary
        ? (t.isDark ? Colors.black : Colors.white)
        : t.text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hover
                ? (widget.primary
                      ? (t.isDark
                            ? const Color(0xFFDDDDDD)
                            : const Color(0xFF222222))
                      : t.surface2)
                : bg,
            border: Border.all(color: t.border2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatefulWidget {
  final Widget child;
  final _T t;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.t, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hover ? widget.t.hover : Colors.transparent,
            border: Border.all(color: widget.t.border),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final bool required;
  final _T t;
  const _Label(this.label, {required this.required, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: t.text,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          required ? '*' : 'optional',
          style: TextStyle(fontSize: required ? 13 : 11, color: t.textMuted),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final _T t;
  final int maxLines;
  final bool obscure;
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.t,
    this.maxLines = 1,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      obscureText: obscure,
      style: TextStyle(fontSize: 13, color: t.text),
      cursorColor: t.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: t.textMuted),
        filled: true,
        fillColor: t.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: t.border2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: t.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: t.isDark ? Colors.white54 : Colors.black38,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatefulWidget {
  final String label;
  final bool selected;
  final _T t;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.t,
    required this.onTap,
  });

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.selected
                ? (t.isDark ? Colors.white : Colors.black)
                : _hover
                ? t.surface2
                : Colors.transparent,
            border: Border.all(
              color: widget.selected
                  ? (t.isDark ? Colors.white : Colors.black)
                  : t.border2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: widget.selected
                  ? (t.isDark ? Colors.black : Colors.white)
                  : t.textSub,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitBtn extends StatefulWidget {
  final bool isLoading;
  final _T t;
  final String label;
  final VoidCallback onTap;
  const _SubmitBtn({
    required this.isLoading,
    required this.t,
    this.label = 'Upload Resource',
    required this.onTap,
  });

  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          decoration: BoxDecoration(
            color: widget.isLoading
                ? t.surface2
                : _hover
                ? (t.isDark ? const Color(0xFFDDDDDD) : const Color(0xFF222222))
                : (t.isDark ? Colors.white : Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.textMuted,
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: t.isDark ? Colors.black : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
