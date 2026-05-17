import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_dialogs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// resource_widgets.dart
//
// Widgets:
//   LastOpenedBar    — banner showing the most recently opened resource
//   ResourcesGrid    — responsive 2-col grid of ResourceCards
//   ResourceCard     — single resource tile with star/pin/mark-done
//   MyResourceCard   — resource tile used in My Resources tab (with delete)
// ─────────────────────────────────────────────────────────────────────────────

// ─── LastOpenedBar ────────────────────────────────────────────────────────────
class LastOpenedBar extends StatelessWidget {
  final ResourceModel resource;
  final UserTheme t;
  const LastOpenedBar({super.key, required this.resource, required this.t});

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
          // ── File type icon ─────────────────────────────────────────────────
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

          // ── Info ───────────────────────────────────────────────────────────
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

          // ── Open button ────────────────────────────────────────────────────
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.read<DashboardBloc>().add(ResourceOpened(resource.id));
                showResourceModal(context, resource, t);
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

// ─── ResourcesGrid ────────────────────────────────────────────────────────────
class ResourcesGrid extends StatelessWidget {
  final List<ResourceModel> resources;
  final UserTheme t;
  const ResourcesGrid({super.key, required this.resources, required this.t});

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
              .map((r) => ResourceCard(resource: r, width: cardW, t: t))
              .toList(),
        );
      },
    );
  }
}

// ─── ResourceCard ─────────────────────────────────────────────────────────────
class ResourceCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final UserTheme t;
  const ResourceCard({
    super.key,
    required this.resource,
    required this.width,
    required this.t,
  });

  @override
  State<ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<ResourceCard> {
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
          showResourceModal(context, r, t);
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
              // ── File type icon ───────────────────────────────────────────
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

              // ── Info + actions ──────────────────────────────────────────
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
                        ResourceTag(label: r.typeLabel, t: t),
                        const SizedBox(width: 4),
                        if (r.isDone) ResourceTag(label: '✓ Done', t: t),
                        const Spacer(),
                        if (!r.isDone)
                          ActionText(
                            label: 'Mark done',
                            t: t,
                            onTap: () => bloc.add(ResourceMarkedDone(r.id)),
                          ),
                        const SizedBox(width: 10),
                        ActionIcon(
                          icon: r.isPinned ? '📌' : '📍',
                          active: r.isPinned,
                          t: t,
                          onTap: () => bloc.add(ResourcePinToggled(r.id)),
                        ),
                        const SizedBox(width: 8),
                        ActionIcon(
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

// ─── MyResourceCard ───────────────────────────────────────────────────────────
class MyResourceCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final UserTheme t;
  const MyResourceCard({
    super.key,
    required this.resource,
    required this.width,
    required this.t,
  });

  @override
  State<MyResourceCard> createState() => _MyResourceCardState();
}

class _MyResourceCardState extends State<MyResourceCard> {
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
            // ── Icon ────────────────────────────────────────────────────────
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

            // ── Info + date + delete ─────────────────────────────────────
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: t.surface2,
                          border: Border.all(color: t.border2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r.typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: t.textSub,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                      const SizedBox(width: 12),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _showDeleteDialog(context, r, t),
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

  void _showDeleteDialog(BuildContext context, ResourceModel r, UserTheme t) {
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
                    child: HoverBtn(
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

                          // ── TODO (Backend Team) ──────────────────────────
                          // Delete from Firestore + Firebase Storage:
                          //
                          //   // Delete Firestore doc:
                          //   await FirebaseFirestore.instance
                          //       .collection('resources')
                          //       .doc(r.id)
                          //       .delete();
                          //
                          //   // Delete file from Storage (if fileUrl exists):
                          //   if (r.fileUrl != null) {
                          //     await FirebaseStorage.instance
                          //         .refFromURL(r.fileUrl!)
                          //         .delete();
                          //   }
                          //
                          //   // Dispatch BLoC event (add ResourceDeleted event):
                          //   context.read<DashboardBloc>()
                          //       .add(ResourceDeleted(r.id));
                          // ────────────────────────────────────────────────
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC3333),
                            border: Border.all(color: t.border2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
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
          ),
        ),
      ),
    );
  }
}
