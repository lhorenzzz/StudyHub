import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import 'package:study_hub/features/admin/repository/admin_repository.dart';

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
                    _Navbar(t: t),
                    _TabBar(activeTab: state.activeTab, t: t),
                    Expanded(
                      child: _AnimatedPageSwitcher(
                        index: state.activeTab.index,
                        pages: [
                          _OverviewTab(state: state, t: t),
                          _GlobalResourcesTab(state: state, t: t),
                          _UserUploadsTab(state: state, t: t),
                          _UsersTab(state: state, t: t),
                          _MyResourcesView(state: state, t: t),
                          _ProfileTab(t: t),
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

// ─── NAVBAR ───────────────────────────────────────────────────────────────────
class _Navbar extends StatelessWidget {
  final _T t;
  const _Navbar({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo
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
            ],
          ),
          const SizedBox(width: 10),
          // Admin badge
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
          const Spacer(),
          // Theme toggle
          _IconBtn(
            child: Text(
              t.isDark ? '☀' : '🌙',
              style: const TextStyle(fontSize: 13),
            ),
            t: t,
            onTap: () => context.read<AdminBloc>().add(AdminThemeToggled()),
          ),
          const SizedBox(width: 10),
          // Avatar
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
                'AD',
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
    );
  }
}

// ─── TAB BAR ──────────────────────────────────────────────────────────────────
// UPDATED: now has 5 tabs — overview, globalResources, userUploads, users, categories
class _TabBar extends StatelessWidget {
  final AdminTab activeTab;
  final _T t;
  const _TabBar({required this.activeTab, required this.t});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (AdminTab.overview, 'Overview'),
      (AdminTab.globalResources, 'Global Resources'),
      (AdminTab.userUploads, 'User Uploads'),
      (AdminTab.users, 'Users'),
      (AdminTab.myResources, 'My Resources'),
      (AdminTab.profile, 'Profile'),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: SingleChildScrollView(
        child: Row(
          children: tabs.map((tab) {
            final isActive = activeTab == tab.$1;
            return _TabItem(
              label: tab.$2,
              isActive: isActive,
              t: t,
              onTap: () =>
                  context.read<AdminBloc>().add(AdminTabChanged(tab.$1)),
            );
          }).toList(),
        ),
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
                    label: 'Total GlobalResources',
                    value: state.totalGlobalResources,
                    width: w,
                    t: t,
                  ),
                  _StatCard(
                    icon: Icons.people_outline,
                    label: 'Total Users',
                    value: state.totalUsers,
                    width: w,
                    t: t,
                  ),
                  _StatCard(
                    icon: Icons.folder_outlined,
                    label: 'Total Categories',
                    value: state.totalCategories,
                    width: w,
                    t: t,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          _SectionHeader(title: 'Top Uploaders', t: t),
          const SizedBox(height: 4),
          Text(
            'Click a user to browse their uploaded files by category.',
            style: TextStyle(fontSize: 12, color: t.textMuted),
          ),
          const SizedBox(height: 12),

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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final double width;
  final _T t;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.surface2,
              border: Border.all(color: t.border2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: t.textSub),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: t.text,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 12, color: t.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentResourceRow extends StatefulWidget {
  final ResourceModel resource;
  final _T t;
  const _RecentResourceRow({required this.resource, required this.t});

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
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
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
                child: Text(r.typeEmoji, style: const TextStyle(fontSize: 15)),
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
  const _CompactFileCard({
    required this.resource,
    required this.width,
    required this.t,
    required this.onView,
    required this.onDelete,
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
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: t.textMuted,
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
  bool _showUpload = false;

  List<ResourceModel> _getFilesForCategory(String categoryId) {
    return widget.state.resources
        .where((r) => r.categoryId == categoryId)
        .toList();
  }

  List<ResourceModel> get _filteredFiles {
    final files = _getFilesForCategory(_selectedCategoryId ?? '');
    if (_typeFilter.isEmpty) return files;
    return files.where((r) => r.type == _typeFilter).toList();
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
                    _showUpload = false;
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
                  label: _showUpload ? 'Cancel' : '↑  Upload to this category',
                  t: t,
                  primary: !_showUpload,
                  onTap: () => setState(() => _showUpload = !_showUpload),
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

          // Inline upload form (only inside a category)
          if (_showUpload && _selectedCategoryId != null) ...[
            _AdminUploadForm(
              t: t,
              preselectedCategoryId: _selectedCategoryId,
              categories: state.categories,
              isLoading: state.isActionLoading,
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
                setState(() => _showUpload = false);
              },
            ),
            const SizedBox(height: 24),
          ],

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
                      final count = state.resources
                          .where((r) => r.categoryId == cat.id)
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
  String _categoryFilter = '';
  String _typeFilter = '';

  List<ResourceModel> get _allUploads => widget.state.resources;

  List<ResourceModel> get _filtered {
    return _allUploads.where((r) {
      final ms =
          _search.isEmpty ||
          r.title.toLowerCase().contains(_search.toLowerCase()) ||
          r.uploadedBy.toLowerCase().contains(_search.toLowerCase());
      final mc = _categoryFilter.isEmpty || r.categoryId == _categoryFilter;
      final mt = _typeFilter.isEmpty || r.type == _typeFilter;
      return ms && mc && mt;
    }).toList();
  }

  List<ResourceModel> get _paginated {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  int get _totalPages => (_filtered.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final state = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Uploads',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All files uploaded by students. You can view or delete.',
            style: TextStyle(fontSize: 13, color: t.textSub),
          ),
          const SizedBox(height: 24),

          // Search + filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 260,
                child: _SearchField(
                  hint: 'Search by title or uploader...',
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

          if (_paginated.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  _filtered.isEmpty && _search.isNotEmpty
                      ? 'No files match your search.'
                      : 'No user uploads yet.',
                  style: TextStyle(color: t.textSub, fontSize: 13),
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
                  children: _paginated
                      .map(
                        (r) => _CompactFileCard(
                          resource: r,
                          width: w,
                          t: t,
                          onView: () => _showViewModal(context, r, t),
                          onDelete: () => _confirmDelete(context, r, t),
                        ),
                      )
                      .toList(),
                );
              },
            ),

          // Pagination controls
          if (_totalPages > 1) ...[
            const SizedBox(height: 24),
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

// ─────────────────────────────────────────────────────────────────────────────
// USERS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final AdminLoaded state;
  final _T t;
  const _UsersTab({required this.state, required this.t});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            'All registered users.',
            style: TextStyle(fontSize: 13, color: t.textSub),
          ),
          const SizedBox(height: 24),

          _SearchField(
            hint: 'Search by name or email...',
            t: t,
            onChanged: (q) =>
                context.read<AdminBloc>().add(AdminUserSearchChanged(q)),
          ),
          const SizedBox(height: 16),

          Text(
            '${state.filteredUsers.length} users',
            style: TextStyle(fontSize: 12, color: t.textMuted),
          ),
          const SizedBox(height: 12),

          if (state.filteredUsers.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'No users found.',
                  style: TextStyle(color: t.textSub, fontSize: 13),
                ),
              ),
            )
          else
            ...state.filteredUsers
                .map(
                  (u) => _UserRow(
                    user: u,
                    t: t,
                    onDelete: () => _confirmDelete(context, u, t),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AdminUser u, _T t) {
    _showConfirmDialog(
      context: ctx,
      t: t,
      title: 'Delete User',
      body:
          'Are you sure you want to delete "${u.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () =>
          ctx.read<AdminBloc>().add(AdminUserDeleteRequested(u.id)),
    );
  }
}

class _UserRow extends StatefulWidget {
  final AdminUser user;
  final _T t;
  final VoidCallback onDelete;
  const _UserRow({required this.user, required this.t, required this.onDelete});

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final t = widget.t;
    final initials = u.name.trim().split(' ').length >= 2
        ? '${u.name.trim().split(' ')[0][0]}${u.name.trim().split(' ')[1][0]}'
              .toUpperCase()
        : u.name[0].toUpperCase();

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hover
              ? (t.isDark ? const Color(0xFF161616) : const Color(0xFFF0F0F0))
              : t.surface,
          border: Border.all(color: _hover ? t.border2 : t.border),
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
                  initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                  ),
                  Text(
                    u.email,
                    style: TextStyle(fontSize: 12, color: t.textSub),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: t.surface2,
                border: Border.all(color: t.border2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                u.role.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: t.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${u.createdAt.day}/${u.createdAt.month}/${u.createdAt.year}',
              style: TextStyle(fontSize: 11, color: t.textMuted),
            ),
            const SizedBox(width: 16),
            if (u.role != 'admin')
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: t.textMuted,
                  ),
                ),
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

// ─── ADMIN MY RESOURCES TAB ───────────────────────────────────────────────────
class _MyResourcesView extends StatelessWidget {
  final AdminLoaded state;
  final _T t;
  const _MyResourcesView({required this.state, required this.t});

  @override
  Widget build(BuildContext context) {
    // 🗑️ DUMMY: filter by 'admin' — delete when Firebase connected
    // 🔥 FIREBASE: query where uploaded_by == current_user_id
    final myResources = state.resources
        .where((r) => r.uploadedBy == 'admin')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Spacer(),
              Text(
                '${myResources.length} uploaded',
                style: TextStyle(fontSize: 13, color: t.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Resources you have uploaded.',
            style: TextStyle(fontSize: 13, color: t.textSub),
          ),
          const SizedBox(height: 28),
          if (myResources.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 48,
                      color: t.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You haven't uploaded anything yet.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textSub,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Go to Global Resources to upload.',
                      style: TextStyle(fontSize: 13, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (_, c) {
                final cols = c.maxWidth > 700 ? 3 : 2;
                final w = (c.maxWidth - (10.0 * (cols - 1))) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: myResources
                      .map(
                        (r) => _CompactFileCard(
                          resource: r,
                          width: w,
                          t: t,
                          onView: () {},
                          onDelete: () => _showConfirmDialog(
                            context: context,
                            t: t,
                            title: 'Delete Resource',
                            body: 'Delete "${r.title}"? Cannot be undone.',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                            onConfirm: () => context.read<AdminBloc>().add(
                              AdminResourceDeleteRequested(r.id),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ─── ADMIN PROFILE TAB ────────────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  final _T t;
  const _ProfileTab({required this.t});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _isEditing = false;
  bool _isSaving = false;

  // 🗑️ DUMMY — delete when Firebase connected
  // 🔥 FIREBASE: load from FirebaseAuth.instance.currentUser
  //   + FirebaseFirestore.instance.collection('users').doc(uid).get()
  String _name = 'Admin User';
  String _email = 'admin@studyhub.com';
  String _bio = 'StudyHub administrator.';

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _currPassCtrl;
  late TextEditingController _newPassCtrl;

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _emailCtrl = TextEditingController(text: _email);
    _bioCtrl = TextEditingController(text: _bio);
    _currPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _currPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // 🔥 FIREBASE: await FirebaseFirestore.instance
    //   .collection('users').doc(uid).update({...})
    setState(() {
      _name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : _name;
      _email = _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : _email;
      _bio = _bioCtrl.text.trim();
      _isEditing = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: t.text,
                    ),
                  ),
                  const Spacer(),
                  _HoverBtn(
                    label: _isEditing ? 'Cancel' : 'Edit Profile',
                    t: t,
                    primary: !_isEditing,
                    onTap: () => setState(() => _isEditing = !_isEditing),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Avatar card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: t.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.border2),
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _email,
                          style: TextStyle(fontSize: 13, color: t.textSub),
                        ),
                        const SizedBox(height: 4),
                        // Admin role badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
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
                              letterSpacing: 0.6,
                              color: t.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Edit form
              if (_isEditing) ...[
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('Name', required: true, t: t),
                const SizedBox(height: 8),
                _Field(ctrl: _nameCtrl, hint: 'Full name', t: t),
                const SizedBox(height: 16),
                _Label('Email', required: true, t: t),
                const SizedBox(height: 8),
                _Field(ctrl: _emailCtrl, hint: 'Email address', t: t),
                const SizedBox(height: 16),
                _Label('Bio', required: false, t: t),
                const SizedBox(height: 8),
                _Field(ctrl: _bioCtrl, hint: 'About you...', t: t, maxLines: 3),
                const SizedBox(height: 24),
                Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 16),
                _Label('Current Password', required: false, t: t),
                const SizedBox(height: 8),
                _Field(
                  ctrl: _currPassCtrl,
                  hint: '••••••••',
                  t: t,
                  obscure: true,
                ),
                const SizedBox(height: 16),
                _Label('New Password', required: false, t: t),
                const SizedBox(height: 8),
                _Field(
                  ctrl: _newPassCtrl,
                  hint: '••••••••',
                  t: t,
                  obscure: true,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: _SubmitBtn(
                    isLoading: _isSaving,
                    t: t,
                    label: 'Save Changes',
                    onTap: _save,
                  ),
                ),
              ],
            ],
          ),
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
class _AdminUploadForm extends StatefulWidget {
  final _T t;
  final String? preselectedCategoryId; // NEW
  final List<CategoryModel> categories;
  final bool isLoading;
  final Function(Map<String, String>) onSubmit;
  const _AdminUploadForm({
    required this.t,
    this.preselectedCategoryId, // NEW
    required this.categories,
    required this.isLoading,
    required this.onSubmit,
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
  String _fileName = '';
  String _fileType = '';
  String _errorMsg = '';

  final _fileTypes = {'pdf': '📄', 'excel': '📊', 'ppt': '📑', 'word': '📝'};

  @override
  void initState() {
    super.initState();
    // Pre-select category if provided
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

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty ||
        _fileName.isEmpty ||
        _categoryId.isEmpty ||
        _difficulty.isEmpty) {
      setState(() => _errorMsg = 'Please fill in all required fields.');
      return;
    }
    widget.onSubmit({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'categoryId': _categoryId,
      'difficulty': _difficulty,
      'tags': _tagsCtrl.text.trim(),
      'fileName': _fileName,
      'fileType': _fileType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Container(
      padding: const EdgeInsets.all(20),
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

          _Label('Title', required: true, t: t),
          const SizedBox(height: 8),
          _Field(ctrl: _titleCtrl, hint: 'e.g. HTML Basics', t: t),
          const SizedBox(height: 16),

          Row(
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
                          'Select',
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
              const SizedBox(width: 12),
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

          _Label('File', required: true, t: t),
          const SizedBox(height: 8),
          Row(
            children: _fileTypes.entries.map((e) {
              final selected = _fileType == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _fileType = e.key;
                      _fileName =
                          'file.${e.key == 'word'
                              ? 'docx'
                              : e.key == 'ppt'
                              ? 'pptx'
                              : e.key == 'excel'
                              ? 'xlsx'
                              : 'pdf'}';
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? (t.isDark ? Colors.white : Colors.black)
                            : t.surface2,
                        border: Border.all(
                          color: selected
                              ? (t.isDark ? Colors.white : Colors.black)
                              : t.border2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(e.value, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            e.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? (t.isDark ? Colors.black : Colors.white)
                                  : t.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          _Label('Description', required: false, t: t),
          const SizedBox(height: 8),
          _Field(
            ctrl: _descCtrl,
            hint: 'Brief description...',
            t: t,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _Label('Tags', required: false, t: t),
          const SizedBox(height: 8),
          _Field(ctrl: _tagsCtrl, hint: 'e.g. HTML, CSS', t: t),

          if (_errorMsg.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _errorMsg,
              style: const TextStyle(fontSize: 12, color: Color(0xFFFF6B6B)),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _SubmitBtn(
              isLoading: widget.isLoading,
              t: t,
              onTap: _submit,
            ),
          ),
        ],
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
