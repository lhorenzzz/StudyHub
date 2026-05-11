import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../widgets/theme_helper.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_dialogs.dart';
import 'upload_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MY RESOURCES TAB
// ─────────────────────────────────────────────────────────────────────────────
class MyResourcesTab extends StatefulWidget {
  final AdminLoaded state;
  final AdminTheme t;
  const MyResourcesTab({super.key, required this.state, required this.t});

  @override
  State<MyResourcesTab> createState() => _MyResourcesTabState();
}

class _MyResourcesTabState extends State<MyResourcesTab> {
  static const _pageSize = 20;
  int _page = 0;
  String _search = '';
  String _typeFilter = '';

  List<ResourceModel> get _myResources {
    final uploaded = widget.state.resources
        .where((r) => r.uploadedBy == widget.state.currentAdminId)
        .toList();
    final saved = widget.state.resources
        .where((r) => widget.state.savedResourceIds.contains(r.id))
        .toList();
    final Map<String, ResourceModel> merged = {
      for (final r in [...uploaded, ...saved]) r.id: r,
    };
    return merged.values.toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

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

  void _makePublic(BuildContext context, ResourceModel r) {
    showAdminConfirmDialog(
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

  void _makePrivate(BuildContext context, ResourceModel r) {
    showAdminConfirmDialog(
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
            child: AdminUploadForm(
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
              AdminModalRow(label: 'File Type', value: r.typeLabel, t: t),
              AdminModalRow(label: 'Category', value: r.categoryName, t: t),
              AdminModalRow(
                label: 'Difficulty',
                value: r.difficultyLabel,
                t: t,
              ),
              AdminModalRow(
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
              if (r.description.isNotEmpty)
                AdminModalRow(label: 'Description', value: r.description, t: t),
              if (r.tags.isNotEmpty)
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
              const SizedBox(height: 4),
              // Open File button
              SizedBox(
                width: double.infinity,
                child: r.fileUrl.isNotEmpty
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {},
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

  void _confirmDelete(BuildContext context, ResourceModel r) {
    showAdminConfirmDialog(
      context: context,
      t: widget.t,
      title: 'Delete Resource',
      body: 'Delete "${r.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
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
          // Header
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
              AdminHoverBtn(
                label: '↑  Upload',
                t: t,
                primary: true,
                onTap: () => _showUploadModal(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search + filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 260,
                child: AdminSearchField(
                  hint: 'Search by title or category...',
                  t: t,
                  onChanged: (q) => setState(() {
                    _search = q;
                    _page = 0;
                  }),
                ),
              ),
              AdminFilterDropdown(
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

          // Table
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
                            const SizedBox(width: 58),
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
                            const SizedBox(width: 80),
                          ],
                        ),
                      ),
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

          // Pagination
          if (_totalPages > 1) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: _page > 0 ? 1.0 : 0.35,
                  child: AdminHoverBtn(
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
                  child: AdminHoverBtn(
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

// ─── MY RESOURCE ROW ──────────────────────────────────────────────────────────
class _MyResourceRow extends StatefulWidget {
  final ResourceModel resource;
  final AdminTheme t;
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
              ? Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _TypeBadge(
                          label: r.typeLabel,
                          bg: badgeBg,
                          fg: badgeFg,
                        ),
                      ),
                    ),
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
                    _ScopePill(isGlobal: isGlobal, t: t),
                    const SizedBox(width: 8),
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
              : Row(
                  children: [
                    SizedBox(
                      width: 58,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _TypeBadge(
                          label: r.typeLabel,
                          bg: badgeBg,
                          fg: badgeFg,
                        ),
                      ),
                    ),
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
                    Expanded(
                      flex: 2,
                      child: Text(
                        r.categoryName,
                        style: TextStyle(fontSize: 13, color: t.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _ScopePill(isGlobal: isGlobal, t: t),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        widget.formattedDate,
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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

// ─── TYPE BADGE ───────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _TypeBadge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── SCOPE PILL ───────────────────────────────────────────────────────────────
class _ScopePill extends StatelessWidget {
  final bool isGlobal;
  final AdminTheme t;
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
