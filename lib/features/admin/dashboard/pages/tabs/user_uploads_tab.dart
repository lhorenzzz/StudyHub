import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../widgets/theme_helper.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_dialogs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USER UPLOADS TAB
// ─────────────────────────────────────────────────────────────────────────────
class UserUploadsTab extends StatefulWidget {
  final AdminLoaded state;
  final AdminTheme t;
  const UserUploadsTab({super.key, required this.state, required this.t});

  @override
  State<UserUploadsTab> createState() => _UserUploadsTabState();
}

class _UserUploadsTabState extends State<UserUploadsTab> {
  static const _pageSize = 20;
  int _page = 0;

  String _search = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _search = widget.state.userUploadsFilter;
    _searchCtrl = TextEditingController(text: _search);
  }

  @override
  void didUpdateWidget(UserUploadsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  List<ResourceModel> get _allUploads =>
      widget.state.resources.where((r) => r.uploadedBy != 'admin').toList();

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

          // Header
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

          // Search + Filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 240,
                child: AdminSearchFieldWithController(
                  hint: 'Search title or uploader...',
                  controller: _searchCtrl,
                  t: t,
                  onChanged: (q) => setState(() {
                    _search = q;
                    _page = 0;
                  }),
                ),
              ),
              AdminFilterDropdown(
                hint: 'All categories',
                value: _categoryFilter.isEmpty ? null : _categoryFilter,
                items: state.categories.map((c) => (c.id, c.name)).toList(),
                t: t,
                onChanged: (v) => setState(() {
                  _categoryFilter = v ?? '';
                  _page = 0;
                }),
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

          // Table
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
                            const SizedBox(width: 32),
                          ],
                        ),
                      ),
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

          // Pagination
          if (_totalPages > 1) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AdminHoverBtn(
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
                AdminHoverBtn(
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
                value: _formatDate(r.uploadedAt),
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

// ─── UPLOAD ROW ───────────────────────────────────────────────────────────────
class _UploadRow extends StatefulWidget {
  final ResourceModel resource;
  final AdminTheme t;
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
              ? Row(
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
                    const SizedBox(width: 10),
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
              : Row(
                  children: [
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
                        style: TextStyle(fontSize: 14, color: t.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                    SizedBox(
                      width: 100,
                      child: Text(
                        widget.formattedDate,
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ),
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
