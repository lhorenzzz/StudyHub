import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';

// My Resources page — shows only resources uploaded by the current user
// Reuses DashboardBloc since resources are already loaded there
class MyResourcesPage extends StatelessWidget {
  final _T t;
  const MyResourcesPage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return Center(child: CircularProgressIndicator(color: t.text));
        }

        // Filter: only show resources uploaded by current user
        // 'admin' is the dummy uploadedBy value for now
        final myResources = state.resources
            .where((r) => r.uploadedBy == 'admin')
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Empty state
              if (myResources.isEmpty)
                _EmptyState(t: t)
              else
                _MyResourcesList(resources: myResources, t: t),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _T t;
  const _EmptyState({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.upload_file_outlined, size: 48, color: t.textMuted),
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
              'Go to Upload to share resources with others.',
              style: TextStyle(fontSize: 13, color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyResourcesList extends StatelessWidget {
  final List<ResourceModel> resources;
  final _T t;
  const _MyResourcesList({required this.resources, required this.t});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 700 ? 2 : 1;
        final cardW = (constraints.maxWidth - (cols == 2 ? 10 : 0)) / cols;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: resources
              .map((r) => _MyResourceCard(resource: r, width: cardW, t: t))
              .toList(),
        );
      },
    );
  }
}

class _MyResourceCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final _T t;
  const _MyResourceCard({
    required this.resource,
    required this.width,
    required this.t,
  });

  @override
  State<_MyResourceCard> createState() => _MyResourceCardState();
}

class _MyResourceCardState extends State<_MyResourceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.resource;
    final t = widget.t;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: widget.width,
        padding: const EdgeInsets.all(16),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: t.surface2,
                border: Border.all(color: t.border2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(r.typeEmoji, style: const TextStyle(fontSize: 16)),
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

                  Row(
                    children: [
                      _Tag(label: r.typeLabel, t: t),
                      const Spacer(),
                      // Uploaded date
                      Text(
                        '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                      const SizedBox(width: 12),
                      // Delete button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _confirmDelete(context, r, t),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Confirm delete dialog
void _confirmDelete(BuildContext context, ResourceModel r, _T t) {
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
              'Delete Resource',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Are you sure you want to delete "${r.title}"? This cannot be undone.',
              style: TextStyle(fontSize: 13, color: t.textSub, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Cancel',
                    primary: false,
                    t: t,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogBtn(
                    label: 'Delete',
                    primary: true,
                    isDanger: true,
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
                            'Deleted "${r.title}"',
                            style: TextStyle(fontSize: 12, color: t.text),
                          ),
                        ),
                      );
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

// ── Shared small widgets ──────────────────────────────────────────────────────
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

class _DialogBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final bool isDanger;
  final _T t;
  final VoidCallback onTap;
  const _DialogBtn({
    required this.label,
    required this.primary,
    required this.t,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  State<_DialogBtn> createState() => _DialogBtnState();
}

class _DialogBtnState extends State<_DialogBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDanger
        ? const Color(0xFFCC3333)
        : widget.primary
        ? (widget.t.isDark ? Colors.white : Colors.black)
        : widget.t.surface2;

    final fg = widget.isDanger
        ? Colors.white
        : widget.primary
        ? (widget.t.isDark ? Colors.black : Colors.white)
        : widget.t.text;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _hover
                ? (widget.isDanger ? const Color(0xFFAA2222) : bg)
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

// Theme helper — same as dashboard, kept here for independence
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
}
