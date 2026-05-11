import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../widgets/theme_helper.dart';
import '../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OVERVIEW TAB
// ─────────────────────────────────────────────────────────────────────────────
class OverviewTab extends StatelessWidget {
  final AdminLoaded state;
  final AdminTheme t;
  const OverviewTab({super.key, required this.state, required this.t});

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
            Column(
              children: recentSlice
                  .map(
                    (r) => _RecentResourceRow(
                      resource: r,
                      t: t,
                      onTap: () => context.read<AdminBloc>().add(
                        AdminTabChanged(AdminTab.globalResources),
                      ),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 32),

          AdminSectionHeader(title: 'Top Uploaders', t: t),

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

// ─── STAT CARD ────────────────────────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int value;
  final double width;
  final AdminTheme t;
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

// ─── RECENT RESOURCE ROW ──────────────────────────────────────────────────────
class _RecentResourceRow extends StatefulWidget {
  final ResourceModel resource;
  final AdminTheme t;
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

// ─── UPLOADER ROW ─────────────────────────────────────────────────────────────
class _UploaderRow extends StatefulWidget {
  final String uploadedBy;
  final List<ResourceModel> resources;
  final int maxCount;
  final AdminTheme t;
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
                      Text(
                        '${catResources.first.categoryName.toUpperCase()} · ${catResources.length} FILES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: t.textMuted,
                        ),
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

// ─── FILE CHIP ────────────────────────────────────────────────────────────────
class _FileChip extends StatefulWidget {
  final ResourceModel resource;
  final AdminTheme t;
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
