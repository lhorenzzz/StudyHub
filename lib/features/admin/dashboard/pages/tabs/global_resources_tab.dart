import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../widgets/theme_helper.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_dialogs.dart';
import 'upload_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GLOBAL RESOURCES TAB
// ─────────────────────────────────────────────────────────────────────────────
class GlobalResourcesTab extends StatefulWidget {
  final AdminLoaded state;
  final AdminTheme t;
  const GlobalResourcesTab({super.key, required this.state, required this.t});

  @override
  State<GlobalResourcesTab> createState() => _GlobalResourcesTabState();
}

class _GlobalResourcesTabState extends State<GlobalResourcesTab> {
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _typeFilter = '';

  void _showUploadModal(BuildContext context, AdminTheme t) {
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
            child: AdminUploadForm(
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
    return widget.state.resources
        .where((r) => r.categoryId == categoryId && r.isGlobal)
        .toList();
  }

  List<ResourceModel> get _filteredFiles {
    final files = _getFilesForCategory(_selectedCategoryId ?? '');
    if (_typeFilter.isEmpty) return files;
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
                AdminHoverBtn(
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
                                AdminResourceSavedToMyResources(
                                  resourceId: r.id,
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

  void _confirmDelete(BuildContext context, ResourceModel r, AdminTheme t) {
    showAdminConfirmDialog(
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

  void _showViewModal(BuildContext context, ResourceModel r, AdminTheme t) {
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
              AdminModalRow(label: 'File Type', value: r.typeLabel, t: t),
              AdminModalRow(label: 'Category', value: r.categoryName, t: t),
              AdminModalRow(
                label: 'Difficulty',
                value: r.difficultyLabel,
                t: t,
              ),
              AdminModalRow(
                label: 'Uploaded',
                value:
                    '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
                t: t,
              ),
              AdminModalRow(label: 'Uploaded by', value: r.uploadedBy, t: t),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── BREADCRUMB ───────────────────────────────────────────────────────────────
class _Breadcrumb extends StatelessWidget {
  final String? categoryName;
  final AdminTheme t;
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

// ─── TYPE FILTER CHIPS ────────────────────────────────────────────────────────
class _TypeFilterChips extends StatelessWidget {
  final String selected;
  final AdminTheme t;
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
            child: AdminChip(
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

// ─── COMPACT FILE CARD ────────────────────────────────────────────────────────
class _CompactFileCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final AdminTheme t;
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
                  Tooltip(
                    message: 'Add to My Resources',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onSave,
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
                  Tooltip(
                    message: 'Delete',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDelete,
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

// ─── GLOBAL CATEGORY CARD ─────────────────────────────────────────────────────
class _GlobalCategoryCard extends StatefulWidget {
  final CategoryModel category;
  final int resourceCount;
  final int colorIndex;
  final double width;
  final AdminTheme t;
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
    final cc = resolveCatColor(widget.colorIndex, t.isDark);

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

// ─── ADD CATEGORY MINI CARD ───────────────────────────────────────────────────
class _AddCategoryMiniCard extends StatefulWidget {
  final double width;
  final AdminTheme t;
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
        onTap: () => showAddCategoryModal(context, widget.t),
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
