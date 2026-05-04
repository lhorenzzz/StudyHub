import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';

// ─── THEME HELPER ─────────────────────────────────────────────────────────────
// Bundles all color values so we don't pass 10 params everywhere
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

  // Hover overlay color
  Color get hover =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04);
}

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE
// ─────────────────────────────────────────────────────────────────────────────
class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(DashboardStarted()),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Scaffold(
              backgroundColor: AppColors.darkBg,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final t = _T(state.isDarkMode);
            return Scaffold(
              backgroundColor: t.bg,
              body: Column(
                children: [
                  _Navbar(t: t),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last opened bar
                          if (state.lastOpened != null) ...[
                            _LastOpenedBar(resource: state.lastOpened!, t: t),
                            const SizedBox(height: 24),
                          ],
                          _QuickTabs(activeTab: state.activeTab, t: t),
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Categories', t: t),
                          const SizedBox(height: 12),
                          _CategoriesGrid(
                            categories: state.categories,
                            selectedCategoryId: state.selectedCategoryId,
                            t: t,
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            title: _resourceSectionTitle(state.activeTab),
                            t: t,
                          ),
                          const SizedBox(height: 12),
                          _ResourcesGrid(
                            resources: state.filteredResources,
                            t: t,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Something went wrong.')),
          );
        },
      ),
    );
  }

  String _resourceSectionTitle(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.starred:
        return 'Starred';
      case DashboardTab.pinned:
        return 'Pinned';
      case DashboardTab.recent:
        return 'Recently Opened';
      default:
        return 'All Resources';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVBAR
// ─────────────────────────────────────────────────────────────────────────────
class _Navbar extends StatelessWidget {
  final _T t;
  const _Navbar({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          _Logo(t: t),
          const SizedBox(width: 24),
          _NavLink(label: 'Browse', active: true, t: t),
          _NavLink(label: 'My Resources', active: false, t: t),
          _NavLink(label: 'Upload', active: false, t: t),
          _NavLink(label: 'Profile', active: false, t: t),
          const Spacer(),
          _SearchBar(t: t),
          const SizedBox(width: 10),
          // Theme toggle
          _IconBtn(
            child: Text(
              t.isDark ? '☀' : '🌙',
              style: const TextStyle(fontSize: 13),
            ),
            t: t,
            onTap: () => context.read<DashboardBloc>().add(ThemeToggled()),
          ),
          const SizedBox(width: 10),
          // Avatar
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: t.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: t.border),
              ),
              child: Center(
                child: Text(
                  'LM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final _T t;
  const _Logo({required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final bool active;
  final _T t;
  const _NavLink({required this.label, required this.active, required this.t});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.active || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isHighlighted ? widget.t.hover : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isHighlighted ? widget.t.text : widget.t.textSub,
            fontWeight: widget.active ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  String get label => widget.label;
}

class _SearchBar extends StatelessWidget {
  final _T t;
  const _SearchBar({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 14, color: t.textMuted),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              onChanged: (q) =>
                  context.read<DashboardBloc>().add(DashboardSearchChanged(q)),
              style: TextStyle(fontSize: 13, color: t.text),
              decoration: InputDecoration(
                hintText: 'Search resources...',
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
          curve: Curves.easeOut,
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

// ─────────────────────────────────────────────────────────────────────────────
// LAST OPENED BAR
// ─────────────────────────────────────────────────────────────────────────────
class _LastOpenedBar extends StatelessWidget {
  final ResourceModel resource;
  final _T t;
  const _LastOpenedBar({required this.resource, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                resource.typeEmoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST OPENED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: t.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  resource.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${resource.categoryName} · ${resource.difficultyLabel}',
                  style: TextStyle(fontSize: 12, color: t.textSub),
                ),
              ],
            ),
          ),
          // Open button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.read<DashboardBloc>().add(ResourceOpened(resource.id));
                _showResourceModal(context, resource, t);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: t.isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Open →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK TABS
// ─────────────────────────────────────────────────────────────────────────────
class _QuickTabs extends StatelessWidget {
  final DashboardTab activeTab;
  final _T t;
  const _QuickTabs({required this.activeTab, required this.t});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (DashboardTab.all, 'All'),
      (DashboardTab.starred, '⭐  Starred'),
      (DashboardTab.pinned, '📌  Pinned'),
      (DashboardTab.recent, '🕐  Recently Opened'),
    ];

    return Wrap(
      spacing: 6,
      children: tabs.map((tab) {
        final isActive = activeTab == tab.$1;
        return _TabChip(
          label: tab.$2,
          isActive: isActive,
          t: t,
          onTap: () =>
              context.read<DashboardBloc>().add(DashboardTabChanged(tab.$1)),
        );
      }).toList(),
    );
  }
}

class _TabChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final _T t;
  final VoidCallback onTap;
  const _TabChip({
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    final hovered = _hover && !active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? (widget.t.isDark ? Colors.white : Colors.black)
                : hovered
                ? widget.t.hover
                : Colors.transparent,
            border: Border.all(
              color: active
                  ? (widget.t.isDark ? Colors.white : Colors.black)
                  : widget.t.border2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? (widget.t.isDark ? Colors.black : Colors.white)
                  : widget.t.textSub,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final _T t;
  const _SectionHeader({required this.title, required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: t.textSub,
          ),
        ),
        const Spacer(),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            'See all →',
            style: TextStyle(fontSize: 12, color: t.textMuted),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES GRID
// ─────────────────────────────────────────────────────────────────────────────
class _CategoriesGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final _T t;
  const _CategoriesGrid({
    required this.categories,
    required this.selectedCategoryId,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 900
            ? 4
            : w > 600
            ? 3
            : 2;
        final cardW = (w - (10 * (cols - 1))) / cols;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...categories.map(
              (cat) => _CategoryCard(
                category: cat,
                width: cardW,
                isSelected: selectedCategoryId == cat.id,
                t: t,
                onTap: () =>
                    context.read<DashboardBloc>().add(CategorySelected(cat.id)),
              ),
            ),
            _AddCategoryCard(width: cardW, t: t),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final CategoryModel category;
  final double width;
  final bool isSelected;
  final _T t;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.category,
    required this.width,
    required this.isSelected,
    required this.t,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? (widget.t.isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFEEEEEE))
                : _hover
                ? (widget.t.isDark
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFEBEBEB))
                : widget.t.surface,
            border: Border.all(
              color: selected
                  ? (widget.t.isDark ? Colors.white54 : Colors.black38)
                  : _hover
                  ? widget.t.border2
                  : widget.t.border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.t.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.category.description,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.t.textSub,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.category.resourceCount} resources',
                style: TextStyle(fontSize: 11, color: widget.t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategoryCard extends StatefulWidget {
  final double width;
  final _T t;
  const _AddCategoryCard({required this.width, required this.t});

  @override
  State<_AddCategoryCard> createState() => _AddCategoryCardState();
}

class _AddCategoryCardState extends State<_AddCategoryCard> {
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
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: _hover ? widget.t.hover : Colors.transparent,
            border: Border.all(
              color: _hover ? widget.t.border2 : widget.t.border,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 24, color: widget.t.textMuted),
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
// RESOURCES GRID
// ─────────────────────────────────────────────────────────────────────────────
class _ResourcesGrid extends StatelessWidget {
  final List<ResourceModel> resources;
  final _T t;
  const _ResourcesGrid({required this.resources, required this.t});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'No resources found.',
            style: TextStyle(fontSize: 14, color: t.textSub),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 700 ? 2 : 1;
        final cardW = (constraints.maxWidth - (cols == 2 ? 10 : 0)) / cols;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: resources
              .map((r) => _ResourceCard(resource: r, width: cardW, t: t))
              .toList(),
        );
      },
    );
  }
}

class _ResourceCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final _T t;
  const _ResourceCard({
    required this.resource,
    required this.width,
    required this.t,
  });

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final bloc = context.read<DashboardBloc>();
    final t = widget.t;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () {
          bloc.add(ResourceOpened(r.id));
          _showResourceModal(context, r, t);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hover
                ? (t.isDark ? const Color(0xFF161616) : const Color(0xFFF0F0F0))
                : t.surface,
            border: Border.all(color: _hover ? t.border2 : t.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: t.surface2,
                  border: Border.all(color: t.border2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    r.typeEmoji,
                    style: const TextStyle(fontSize: 16),
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
                    const SizedBox(height: 3),
                    Text(
                      '${r.categoryName} · ${r.difficultyLabel}',
                      style: TextStyle(fontSize: 12, color: t.textSub),
                    ),
                    const SizedBox(height: 10),

                    // Bottom row: tags + actions
                    Row(
                      children: [
                        _Tag(label: r.typeLabel, t: t),
                        const SizedBox(width: 4),
                        if (r.isDone) _Tag(label: '✓ Done', t: t),
                        const Spacer(),

                        // Mark done
                        if (!r.isDone)
                          _ActionText(
                            label: 'Mark done',
                            t: t,
                            onTap: () => bloc.add(ResourceMarkedDone(r.id)),
                          ),
                        const SizedBox(width: 10),

                        // Pin
                        _ActionIcon(
                          icon: r.isPinned ? '📌' : '📍',
                          active: r.isPinned,
                          t: t,
                          onTap: () => bloc.add(ResourcePinToggled(r.id)),
                        ),
                        const SizedBox(width: 8),

                        // Star
                        _ActionIcon(
                          icon: r.isStarred ? '⭐' : '☆',
                          active: r.isStarred,
                          t: t,
                          onTap: () => bloc.add(ResourceStarToggled(r.id)),
                        ),
                      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final _T t;
  const _Tag({required this.label, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: t.textSub,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionText extends StatefulWidget {
  final String label;
  final _T t;
  final VoidCallback onTap;
  const _ActionText({
    required this.label,
    required this.t,
    required this.onTap,
  });

  @override
  State<_ActionText> createState() => _ActionTextState();
}

class _ActionTextState extends State<_ActionText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            color: _hover ? widget.t.text : widget.t.textMuted,
            decoration: TextDecoration.underline,
            decorationColor: _hover ? widget.t.text : widget.t.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final String icon;
  final bool active;
  final _T t;
  final VoidCallback onTap;
  const _ActionIcon({
    required this.icon,
    required this.active,
    required this.t,
    required this.onTap,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: widget.active || _hover ? 1.0 : 0.4,
          child: Text(widget.icon, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODALS
// ─────────────────────────────────────────────────────────────────────────────

// Resource detail modal — shown when user opens a resource
void _showResourceModal(BuildContext context, ResourceModel r, _T t) {
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
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                      const SizedBox(height: 3),
                      Text(
                        '${r.categoryName} · ${r.difficultyLabel}',
                        style: TextStyle(fontSize: 12, color: t.textSub),
                      ),
                    ],
                  ),
                ),
                // Close button
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

            // Details
            _ModalRow(label: 'File Type', value: r.typeLabel, t: t),
            _ModalRow(label: 'Category', value: r.categoryName, t: t),
            _ModalRow(label: 'Difficulty', value: r.difficultyLabel, t: t),
            _ModalRow(
              label: 'Uploaded',
              value:
                  '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
              t: t,
            ),
            _ModalRow(
              label: 'Status',
              value: r.isDone ? '✓ Done' : 'Not done',
              t: t,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Download placeholder
                Expanded(
                  child: _ModalBtn(
                    label: '↓  Download',
                    primary: true,
                    t: t,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: t.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: t.border),
                          ),
                          content: Text(
                            'Download will be available once backend is connected.',
                            style: TextStyle(fontSize: 12, color: t.text),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Mark done
                if (!r.isDone)
                  Expanded(
                    child: _ModalBtn(
                      label: '✓  Mark as Done',
                      primary: false,
                      t: t,
                      onTap: () {
                        context.read<DashboardBloc>().add(
                          ResourceMarkedDone(r.id),
                        );
                        Navigator.pop(context);
                      },
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
    final fgColor = widget.primary
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
          curve: Curves.easeOut,
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
                color: fgColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add Category modal
void _showAddCategoryModal(BuildContext context, _T t) {
  final nameCtrl = TextEditingController();
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
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setModalState) => Dialog(
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
              // Title
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
                      onTap: () => Navigator.pop(dialogContext),
                      child: Icon(Icons.close, size: 18, color: t.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Emoji picker
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
                  final isSelected = selectedEmoji == e;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (t.isDark ? Colors.white : Colors.black)
                              : t.surface2,
                          border: Border.all(
                            color: isSelected
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

              // Name field
              Text(
                'Category Name',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: t.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: 13, color: t.text),
                cursorColor: t.text,
                decoration: InputDecoration(
                  hintText: 'e.g. Mathematics',
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
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                child: _ModalBtn(
                  label: 'Add Category',
                  primary: true,
                  t: t,
                  onTap: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<DashboardBloc>().add(
                      CategoryAdded(name: name, emoji: selectedEmoji),
                    );
                    Navigator.pop(dialogContext);
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
