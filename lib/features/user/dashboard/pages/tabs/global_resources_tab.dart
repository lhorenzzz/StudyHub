import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_dialogs.dart';

class GlobalResourcesTab extends StatefulWidget {
  final DashboardLoaded state;
  final UserTheme t;
  const GlobalResourcesTab({super.key, required this.state, required this.t});

  @override
  State<GlobalResourcesTab> createState() => _GlobalResourcesTabState();
}

class _GlobalResourcesTabState extends State<GlobalResourcesTab> {
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String _typeFilter = '';

  // ── TODO (Backend Team) ───────────────────────────────────────────────────
  // Replace with real uid from FirebaseAuth:
  //   final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  // ─────────────────────────────────────────────────────────────────────────
  final String _currentUid = '';

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

  void _showUploadModal(BuildContext context) {
    final t = widget.t;
    final categories = widget.state.categories;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    String selectedCategoryId = _selectedCategoryId ?? '';
    String selectedCategoryName = _selectedCategoryName ?? '';
    String selectedDifficulty = '';
    String fileName = '';
    String fileType = '';
    final fileTypes = {'pdf': '📄', 'excel': '📊', 'ppt': '📑', 'word': '📝'};
    bool isLoading = false;

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
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Upload to Global Resources',
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
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your upload will be visible to everyone.',
                    style: TextStyle(fontSize: 12, color: t.textMuted),
                  ),
                  const SizedBox(height: 24),

                  // ── Title ────────────────────────────────────────────────
                  FieldLabel('Title', required: true, t: t),
                  const SizedBox(height: 8),
                  InputField(ctrl: titleCtrl, hint: 'e.g. HTML Basics', t: t),
                  const SizedBox(height: 16),

                  // ── File picker ──────────────────────────────────────────
                  FieldLabel('File', required: true, t: t),
                  const SizedBox(height: 8),
                  FilePickerBox(
                    fileName: fileName,
                    fileType: fileType,
                    fileTypes: fileTypes,
                    t: t,
                    onPicked: (name, type) => setModalState(() {
                      fileName = name;
                      fileType = type;
                    }),
                    onClear: () => setModalState(() {
                      fileName = '';
                      fileType = '';
                    }),
                  ),
                  const SizedBox(height: 16),

                  // ── Category ─────────────────────────────────────────────
                  FieldLabel('Category', required: true, t: t),
                  const SizedBox(height: 8),
                  categories.isEmpty
                      ? Text(
                          'No categories available.',
                          style: TextStyle(fontSize: 13, color: t.textMuted),
                        )
                      : CategoryDropField(
                          hint: 'Select category',
                          value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
                          items: categories
                              .map(
                                (c) => {
                                  'id': c.id,
                                  'name': c.name,
                                  'emoji': c.emoji,
                                },
                              )
                              .toList(),
                          label: (c) => '${c['emoji']}  ${c['name']}',
                          t: t,
                          onChanged: (c) {
                            if (c != null && c.isNotEmpty) {
                              setModalState(() {
                                selectedCategoryId = c['id']!;
                                selectedCategoryName = c['name']!;
                              });
                            }
                          },
                        ),
                  const SizedBox(height: 16),

                  // ── Difficulty ───────────────────────────────────────────
                  FieldLabel('Difficulty', required: true, t: t),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Beginner', 'Intermediate']
                        .map(
                          (d) => DifficultyChip(
                            label: d,
                            selected: selectedDifficulty == d,
                            t: t,
                            onTap: () =>
                                setModalState(() => selectedDifficulty = d),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Description ──────────────────────────────────────────
                  FieldLabel('Description', required: false, t: t),
                  const SizedBox(height: 8),
                  InputField(
                    ctrl: descCtrl,
                    hint: 'Brief description...',
                    t: t,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // ── Tags ─────────────────────────────────────────────────
                  FieldLabel('Tags', required: false, t: t),
                  const SizedBox(height: 8),
                  InputField(
                    ctrl: tagsCtrl,
                    hint: 'e.g. HTML, CSS, beginner',
                    t: t,
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ───────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: SubmitBtn(
                      isLoading: isLoading,
                      t: t,
                      label: 'Upload to Global Resources',
                      onTap: () {
                        final isValid =
                            titleCtrl.text.trim().isNotEmpty &&
                            fileName.isNotEmpty &&
                            selectedCategoryId.isNotEmpty &&
                            selectedDifficulty.isNotEmpty;

                        if (!isValid) return;

                        // ── TODO (Backend Team) ──────────────────────────
                        // Wire real upload here — same as upload_tab.dart
                        // STEP 1: upload file to Firebase Storage
                        // STEP 2: write to /resources with isGlobal: true
                        //   'uploadedBy': FirebaseAuth.instance.currentUser!.uid
                        //   'scope': 'global'
                        // ─────────────────────────────────────────────────

                        // Dispatch BLoC event (mock for now)
                        context.read<DashboardBloc>().add(
                          GlobalResourceUploadSubmitted(
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            categoryId: selectedCategoryId,
                            categoryName: selectedCategoryName,
                            difficulty: selectedDifficulty,
                            tags: tagsCtrl.text.trim(),
                            fileName: fileName,
                            fileType: fileType,
                          ),
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
      ),
    );
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
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              if (_selectedCategoryId != null)
                _UserBreadcrumb(
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
              HoverBtn(
                label: '↑  Upload',
                t: t,
                primary: true,
                onTap: () => _showUploadModal(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_selectedCategoryId == null)
            Text(
              'Browse and share learning resources with everyone.',
              style: TextStyle(fontSize: 13, color: t.textSub),
            ),
          const SizedBox(height: 24),

          // ── LEVEL 1: Category grid ────────────────────────────────────────
          if (_selectedCategoryId == null)
            LayoutBuilder(
              builder: (_, constraints) {
                final w = constraints.maxWidth;
                final cols = w > 900
                    ? 4
                    : w > 600
                    ? 3
                    : 2;
                final cardW = (w - (10.0 * (cols - 1))) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: state.categories.map((cat) {
                    final count = state.resources
                        .where((r) => r.categoryId == cat.id && r.isGlobal)
                        .length;
                    return _UserCategoryCard(
                      category: cat,
                      resourceCount: count,
                      width: cardW,
                      t: t,
                      onTap: () => setState(() {
                        _selectedCategoryId = cat.id;
                        _selectedCategoryName = cat.name;
                        _typeFilter = '';
                      }),
                    );
                  }).toList(),
                );
              },
            ),

          // ── LEVEL 2: Files in selected category ───────────────────────────
          if (_selectedCategoryId != null) ...[
            _UserTypeFilterChips(
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
                        'Be the first to upload!',
                        style: TextStyle(color: t.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (_, constraints) {
                  final cols = constraints.maxWidth > 800
                      ? 3
                      : constraints.maxWidth > 500
                      ? 2
                      : 1;
                  final w = (constraints.maxWidth - (10.0 * (cols - 1))) / cols;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _filteredFiles
                        .map(
                          (r) => _UserFileCard(
                            resource: r,
                            width: w,
                            t: t,
                            isOwner: r.uploadedBy == _currentUid,
                            onView: () => showResourceModal(context, r, t),
                            onDelete: () => _confirmDelete(context, r, t),
                            onSave: () => _saveToMyResources(context, r),
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

  void _saveToMyResources(BuildContext context, ResourceModel r) {
    // ── TODO (Backend Team) ─────────────────────────────────────────────────
    // Write a copy to /users/{uid}/saved/{resourceId} or
    // duplicate the resource doc with uploadedBy = uid, isGlobal = false
    // ─────────────────────────────────────────────────────────────────────────
    context.read<DashboardBloc>().add(
      ResourceSavedToMyResources(resourceId: r.id),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: widget.t.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: widget.t.border),
        ),
        content: Text(
          'Saved to My Resources.',
          style: TextStyle(fontSize: 12, color: widget.t.text),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ResourceModel r, UserTheme t) {
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
                'Delete "${r.title}"? This cannot be undone.',
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
                          // Delete from Firestore + Storage:
                          //   await FirebaseFirestore.instance
                          //       .collection('resources').doc(r.id).delete();
                          //   if (r.fileUrl != null)
                          //     await FirebaseStorage.instance
                          //         .refFromURL(r.fileUrl!).delete();
                          // ─────────────────────────────────────────────────
                          context.read<DashboardBloc>().add(
                            GlobalResourceDeleted(resourceId: r.id),
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

// ─── BREADCRUMB ───────────────────────────────────────────────────────────────
class _UserBreadcrumb extends StatelessWidget {
  final String? categoryName;
  final UserTheme t;
  final VoidCallback onBack;
  const _UserBreadcrumb({
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
class _UserTypeFilterChips extends StatelessWidget {
  final String selected;
  final UserTheme t;
  final ValueChanged<String> onChanged;
  const _UserTypeFilterChips({
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
            child: _FilterChip(
              label: type.$2,
              isActive: isActive,
              t: t,
              onTap: () => onChanged(type.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final UserTheme t;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? (widget.t.isDark ? Colors.white : Colors.black)
                : _hover
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
              fontSize: 12,
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

// ─── CATEGORY CARD ────────────────────────────────────────────────────────────
class _UserCategoryCard extends StatefulWidget {
  final dynamic category;
  final int resourceCount;
  final double width;
  final UserTheme t;
  final VoidCallback onTap;
  const _UserCategoryCard({
    required this.category,
    required this.resourceCount,
    required this.width,
    required this.t,
    required this.onTap,
  });

  @override
  State<_UserCategoryCard> createState() => _UserCategoryCardState();
}

class _UserCategoryCardState extends State<_UserCategoryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final t = widget.t;

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
            color: _hover
                ? (t.isDark ? const Color(0xFF1A1A1A) : const Color(0xFFEBEBEB))
                : t.surface,
            border: Border.all(color: _hover ? t.border2 : t.border),
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
                    cat.emoji.isNotEmpty ? cat.emoji : '📁',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cat.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cat.description,
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

// ─── FILE CARD ────────────────────────────────────────────────────────────────
class _UserFileCard extends StatefulWidget {
  final ResourceModel resource;
  final double width;
  final UserTheme t;
  final bool isOwner;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  const _UserFileCard({
    required this.resource,
    required this.width,
    required this.t,
    required this.isOwner,
    required this.onView,
    required this.onDelete,
    required this.onSave,
  });

  @override
  State<_UserFileCard> createState() => _UserFileCardState();
}

class _UserFileCardState extends State<_UserFileCard> {
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
                  // ── File type badge ────────────────────────────────────
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
                  // ── Save to My Resources ───────────────────────────────
                  Tooltip(
                    message: 'Save to My Resources',
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
                  // ── Delete only if owner ───────────────────────────────
                  if (widget.isOwner) ...[
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
                      r.uploadedBy.isEmpty ? 'Unknown' : r.uploadedBy,
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
