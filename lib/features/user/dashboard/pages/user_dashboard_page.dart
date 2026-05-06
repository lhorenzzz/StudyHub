import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// user_dashboard_page.dart
//
// PAGES (wired in _AnimatedPageSwitcher):
//   0 — _BrowsePage        Browse all resources and categories
//   1 — _MyResourcesView   Resources uploaded by the current user
//   2 — _UploadView        Upload a new resource
//   3 — _ProfileView       User profile, stats, edit, logout
//
// SHARED WIDGETS (bottom of file):
//   _HoverBtn, _Label, _Field, _SubmitBtn, _Chip,
//   _FilePickerBox, _DropField, _Tag, _ActionIcon, _ActionText
//
// MODALS:
//   _showResourceModal, _showAddCategoryModal
// ─────────────────────────────────────────────────────────────────────────────

// ─── THEME HELPER ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// ROOT PAGE
// ─────────────────────────────────────────────────────────────────────────────
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              key: _scaffoldKey,
              backgroundColor: t.bg,
              drawer: _MobileDrawer(
                t: t,
                currentIndex: _currentIndex,
                onNavTap: (i) {
                  setState(() => _currentIndex = i);
                  _scaffoldKey.currentState?.closeEndDrawer();
                },
              ),
              body: Column(
                children: [
                  _Navbar(
                    t: t,
                    currentIndex: _currentIndex,
                    onNavTap: (i) => setState(() => _currentIndex = i),
                    onLogoTap: () {}, // no-op, logo no longer opens sidebar
                    scaffoldKey: _scaffoldKey,
                  ),
                  Expanded(
                    child: _AnimatedPageSwitcher(
                      index: _currentIndex,
                      pages: [
                        _BrowsePage(state: state, t: t),
                        _MyResourcesView(state: state, t: t),
                        _UploadView(t: t),
                        _ProfileView(t: t),
                      ],
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
}

// ─────────────────────────────────────────────────────────────────────────────
// BROWSE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _BrowsePage extends StatelessWidget {
  final DashboardLoaded state;
  final _T t;
  const _BrowsePage({required this.state, required this.t});

  String _sectionTitle(DashboardTab tab) {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _SectionHeader(title: _sectionTitle(state.activeTab), t: t),
          const SizedBox(height: 12),
          _ResourcesGrid(resources: state.filteredResources, t: t),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MY RESOURCES VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _MyResourcesView extends StatelessWidget {
  final DashboardLoaded state;
  final _T t;
  const _MyResourcesView({required this.state, required this.t});

  @override
  Widget build(BuildContext context) {
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
                      'Go to Upload to share resources.',
                      style: TextStyle(fontSize: 13, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 700 ? 2 : 1;
                final cardW =
                    (constraints.maxWidth - (cols == 2 ? 10 : 0)) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: myResources
                      .map(
                        (r) => _MyResourceCard(resource: r, width: cardW, t: t),
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

// ─────────────────────────────────────────────────────────────────────────────
// UPLOAD VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _UploadView extends StatefulWidget {
  final _T t;
  const _UploadView({required this.t});

  @override
  State<_UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<_UploadView> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String _selectedDifficulty = '';
  String _fileName = '';
  String _fileType = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  String _errorMsg = '';

  final _categories = [
    {'id': 'it', 'name': 'Information Technology', 'emoji': '💻'},
    {'id': 'science', 'name': 'Science', 'emoji': '🧪'},
    {'id': 'cookery', 'name': 'Cookery', 'emoji': '🍳'},
  ];

  final _fileTypes = {'pdf': '📄', 'excel': '📊', 'ppt': '📑', 'word': '📝'};

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _fileName.isNotEmpty &&
      _selectedCategoryId.isNotEmpty &&
      _selectedDifficulty.isNotEmpty;

  void _reset() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _tagsCtrl.clear();
    setState(() {
      _selectedCategoryId = '';
      _selectedCategoryName = '';
      _selectedDifficulty = '';
      _fileName = '';
      _fileType = '';
      _isSuccess = false;
      _errorMsg = '';
    });
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(() => _errorMsg = 'Please fill in all required fields.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Resource',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Share learning materials with everyone instantly.',
                style: TextStyle(fontSize: 13, color: t.textSub),
              ),
              const SizedBox(height: 32),

              if (_isSuccess) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border.all(color: t.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 16),
                      Text(
                        'Uploaded Successfully!',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${_titleCtrl.text}" is now live.',
                        style: TextStyle(fontSize: 13, color: t.textSub),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _HoverBtn(label: 'Upload Another', t: t, onTap: _reset),
                    ],
                  ),
                ),
              ] else ...[
                _Label('Title', required: true, t: t),
                const SizedBox(height: 8),
                _Field(ctrl: _titleCtrl, hint: 'e.g. HTML Basics', t: t),
                const SizedBox(height: 20),

                _Label('File', required: true, t: t),
                const SizedBox(height: 8),
                _FilePickerBox(
                  fileName: _fileName,
                  fileType: _fileType,
                  fileTypes: _fileTypes,
                  t: t,
                  onPicked: (name, type) => setState(() {
                    _fileName = name;
                    _fileType = type;
                  }),
                  onClear: () => setState(() {
                    _fileName = '';
                    _fileType = '';
                  }),
                ),
                const SizedBox(height: 20),

                _Label('Category', required: true, t: t),
                const SizedBox(height: 8),
                _DropField(
                  hint: 'Select category',
                  value: _selectedCategoryId.isNotEmpty
                      ? _categories.firstWhere(
                          (c) => c['id'] == _selectedCategoryId,
                          orElse: () => <String, String>{},
                        )
                      : null,
                  items: _categories,
                  label: (c) => '${c['emoji']}  ${c['name']}',
                  t: t,
                  onChanged: (c) {
                    if (c != null && c.isNotEmpty)
                      setState(() {
                        _selectedCategoryId = c['id']!;
                        _selectedCategoryName = c['name']!;
                      });
                  },
                ),
                const SizedBox(height: 20),

                _Label('Difficulty', required: true, t: t),
                const SizedBox(height: 8),
                Row(
                  children: ['Beginner', 'Intermediate']
                      .map(
                        (d) => _Chip(
                          label: d,
                          selected: _selectedDifficulty == d,
                          t: t,
                          onTap: () => setState(() => _selectedDifficulty = d),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                _Label('Description', required: false, t: t),
                const SizedBox(height: 8),
                _Field(
                  ctrl: _descCtrl,
                  hint: 'Brief description of this resource...',
                  t: t,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                _Label('Tags', required: false, t: t),
                const SizedBox(height: 8),
                _Field(ctrl: _tagsCtrl, hint: 'e.g. HTML, CSS, beginner', t: t),
                const SizedBox(height: 28),

                if (_errorMsg.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1010),
                      border: Border.all(color: const Color(0xFF4A1A1A)),
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
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: _SubmitBtn(
                    isLoading: _isLoading,
                    t: t,
                    onTap: _submit,
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

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileView extends StatefulWidget {
  final _T t;
  const _ProfileView({required this.t});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _isEditing = false;
  bool _isSaving = false;

  String _name = 'Lhorenz Magtibay';
  String _email = 'lhorenz@email.com';
  String _bio = 'IT student at CatSU. Loves coding and learning new things.';

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _currPassCtrl;
  late TextEditingController _newPassCtrl;

  final int _uploaded = 6;
  final int _done = 2;
  final int _starred = 3;
  final int _pinned = 1;

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

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _nameCtrl.text = _name;
        _emailCtrl.text = _email;
        _bioCtrl.text = _bio;
        _currPassCtrl.clear();
        _newPassCtrl.clear();
      }
      _isEditing = !_isEditing;
    });
  }

  // Add these two methods to _ProfileViewState:

  void _showLogoutDialog(BuildContext context) {
    final t = widget.t;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border),
        ),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to log out of your account?',
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
                    child: _HoverBtn(
                      label: 'Log out',
                      t: t,
                      primary: true,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: dispatch logout event / navigate to login
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

  void _showDeleteAccountDialog(BuildContext context) {
    final t = widget.t;
    final confirmCtrl = TextEditingController();
    const confirmPhrase = 'delete my account';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => StatefulBuilder(
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
                Row(
                  children: [
                    Text(
                      'Delete Account',
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1010),
                    border: Border.all(color: const Color(0xFF4A1A1A)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: Color(0xFFFF6B6B),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will permanently delete your account and all uploaded resources. This action cannot be undone.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF6B6B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Type "$confirmPhrase" to confirm',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: t.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmCtrl,
                  style: TextStyle(fontSize: 13, color: t.text),
                  cursorColor: t.text,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: confirmPhrase,
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
                      borderSide: const BorderSide(color: Color(0xFFCC3333)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _HoverBtn(
                        label: 'Cancel',
                        t: t,
                        primary: false,
                        onTap: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MouseRegion(
                        cursor: confirmCtrl.text.trim() == confirmPhrase
                            ? SystemMouseCursors.click
                            : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: confirmCtrl.text.trim() == confirmPhrase
                              ? () {
                                  Navigator.pop(dialogContext);
                                  // TODO: dispatch delete account event
                                }
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: confirmCtrl.text.trim() == confirmPhrase
                                  ? const Color(0xFFCC3333)
                                  : t.surface2,
                              border: Border.all(color: t.border2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      confirmCtrl.text.trim() == confirmPhrase
                                      ? Colors.white
                                      : t.textMuted,
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
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _name = _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : _name;
      _email = _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : _email;
      _bio = _bioCtrl.text.trim();
      _isEditing = false;
      _isSaving = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: widget.t.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: widget.t.border),
          ),
          content: Text(
            'Profile saved.',
            style: TextStyle(fontSize: 12, color: widget.t.text),
          ),
        ),
      );
    }
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
                    onTap: _toggleEdit,
                  ),
                ],
              ),
              const SizedBox(height: 28),

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
                        color: t.isDark
                            ? const Color(0xFF222222)
                            : const Color(0xFFE5E5E5),
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
                        Text(
                          _bio,
                          style: TextStyle(fontSize: 12, color: t.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatCard(
                        label: 'Uploaded',
                        value: _uploaded,
                        width: cardW,
                        t: t,
                      ),
                      _StatCard(
                        label: 'Done',
                        value: _done,
                        width: cardW,
                        t: t,
                      ),
                      _StatCard(
                        label: 'Starred',
                        value: _starred,
                        width: cardW,
                        t: t,
                      ),
                      _StatCard(
                        label: 'Pinned',
                        value: _pinned,
                        width: cardW,
                        t: t,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

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
                _Field(
                  ctrl: _bioCtrl,
                  hint: 'Tell us about yourself...',
                  t: t,
                  maxLines: 3,
                ),
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

                // ── Account actions ─────────────────────────────────
                const SizedBox(height: 12),
                Divider(color: t.border, height: 1),
                const SizedBox(height: 20),

                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: _SubmitBtn(
                    isLoading: _isSaving,
                    t: t,
                    label: 'Save Changes',
                    onTap: _save,
                  ),
                ),
              ], // <-- close _isEditing block HERE
              // ── Account actions ─────────────────────────────────
              const SizedBox(height: 12),
              Divider(color: t.border, height: 1),
              const SizedBox(height: 20),

              Text(
                'Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: _HoverBtn(
                  label: 'Log out',
                  t: t,
                  primary: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _showDeleteAccountDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: const Color(0xFF4A1A1A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCC3333),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final double width;
  final _T t;
  const _StatCard({
    required this.label,
    required this.value,
    required this.width,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: t.textMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVBAR
// ─────────────────────────────────────────────────────────────────────────────
class _Navbar extends StatelessWidget {
  final _T t;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback onLogoTap;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const _Navbar({
    required this.t,
    required this.currentIndex,
    required this.onNavTap,
    required this.onLogoTap,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 800;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          _Logo(t: t, onTap: onLogoTap),
          if (!isNarrow) ...[
            const SizedBox(width: 24),
            _NavLink(
              label: 'Browse',
              index: 0,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            _NavLink(
              label: 'My Resources',
              index: 1,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            _NavLink(
              label: 'Upload',
              index: 2,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            _NavLink(
              label: 'Profile',
              index: 3,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
          ],
          const Spacer(),
          if (!isNarrow) ...[_SearchBar(t: t), const SizedBox(width: 10)],
          _IconBtn(
            child: Text(
              t.isDark ? '☀' : '🌙',
              style: const TextStyle(fontSize: 13),
            ),
            t: t,
            onTap: () => context.read<DashboardBloc>().add(ThemeToggled()),
          ),
          const SizedBox(width: 10),
          if (!isNarrow)
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
          if (isNarrow)
            _IconBtn(
              child: Icon(Icons.menu_rounded, size: 16, color: t.text),
              t: t,
              onTap: () => scaffoldKey?.currentState?.openDrawer(),
            ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final _T t;
  final VoidCallback onTap;
  const _Logo({required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
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
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final int index;
  final int currentIndex;
  final _T t;
  final ValueChanged<int> onTap;
  const _NavLink({
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.t,
    required this.onTap,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentIndex == widget.index;
    final isHighlighted = isActive || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: Container(
          margin: const EdgeInsets.only(right: 2),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: isHighlighted ? widget.t.hover : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: isHighlighted ? widget.t.text : widget.t.textSub,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
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
// SIDEBAR DRAWER
// ─────────────────────────────────────────────────────────────────────────────

// ── Sidebar sub-widgets ───────────────────────────────────────────────────────
class _SidebarLogo extends StatelessWidget {
  final _T t;
  const _SidebarLogo({required this.t});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: t.isDark ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            Icons.book_rounded,
            size: 15,
            color: t.isDark ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'StudyHub',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: t.text,
          ),
        ),
      ],
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  final String label;
  final _T t;
  const _SidebarSectionLabel({required this.label, required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: t.textMuted,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final _T t;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final highlighted = widget.isActive || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: highlighted
                ? (t.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: highlighted ? t.text : t.textSub,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: highlighted ? t.text : t.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarCategoryItem extends StatefulWidget {
  final String emoji, label;
  final int? count;
  final bool isSelected;
  final _T t;
  final VoidCallback onTap;
  const _SidebarCategoryItem({
    required this.emoji,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.t,
    required this.onTap,
  });

  @override
  State<_SidebarCategoryItem> createState() => _SidebarCategoryItemState();
}

class _SidebarCategoryItemState extends State<_SidebarCategoryItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final highlighted = widget.isSelected || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: highlighted ? t.hover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: highlighted ? t.text : t.textSub,
                  ),
                ),
              ),
              if (widget.count != null)
                Text(
                  '${widget.count}',
                  style: TextStyle(fontSize: 12, color: t.textMuted),
                ),
            ],
          ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final isActive = activeTab == tab.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: _TabChip(
              label: tab.$2,
              isActive: isActive,
              t: t,
              onTap: () => context.read<DashboardBloc>().add(
                DashboardTabChanged(tab.$1),
              ),
            ),
          );
        }).toList(),
      ),
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
                    Row(
                      children: [
                        _Tag(label: r.typeLabel, t: t),
                        const SizedBox(width: 4),
                        if (r.isDone) _Tag(label: '✓ Done', t: t),
                        const Spacer(),
                        if (!r.isDone)
                          _ActionText(
                            label: 'Mark done',
                            t: t,
                            onTap: () => bloc.add(ResourceMarkedDone(r.id)),
                          ),
                        const SizedBox(width: 10),
                        _ActionIcon(
                          icon: r.isPinned ? '📌' : '📍',
                          active: r.isPinned,
                          t: t,
                          onTap: () => bloc.add(ResourcePinToggled(r.id)),
                        ),
                        const SizedBox(width: 8),
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
            _ModalRow(
              label: 'Status',
              value: r.isDone ? '✓ Done' : 'Not done',
              t: t,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPageSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _ctrl.reverse().then((_) {
        setState(() => _currentIndex = widget.index);
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
      child: SlideTransition(
        position: _slide,
        child: widget.pages[_currentIndex],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
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
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.ctrl,
    required this.hint,
    required this.t,
    this.maxLines = 1,
    this.obscure = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      obscureText: obscure,
      style: TextStyle(fontSize: 13, color: t.text),
      cursorColor: t.text,
      onChanged: onChanged,
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

class _FilePickerBox extends StatefulWidget {
  final String fileName;
  final String fileType;
  final Map<String, String> fileTypes;
  final _T t;
  final Function(String name, String type) onPicked;
  final VoidCallback onClear;
  const _FilePickerBox({
    required this.fileName,
    required this.fileType,
    required this.fileTypes,
    required this.t,
    required this.onPicked,
    required this.onClear,
  });

  @override
  State<_FilePickerBox> createState() => _FilePickerBoxState();
}

class _FilePickerBoxState extends State<_FilePickerBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hasFile = widget.fileName.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: hasFile ? null : () => _showPicker(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: hasFile
                ? t.surface
                : (_hover ? t.surface2 : Colors.transparent),
            border: Border.all(color: _hover ? t.border2 : t.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasFile
              ? Row(
                  children: [
                    Text(
                      widget.fileTypes[widget.fileType] ?? '📄',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.fileName,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.text,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onClear,
                      child: Icon(Icons.close, size: 16, color: t.textMuted),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Icon(Icons.upload_outlined, size: 28, color: t.textMuted),
                    const SizedBox(height: 8),
                    Text(
                      'Click to select a file',
                      style: TextStyle(
                        fontSize: 13,
                        color: t.textSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PDF, Excel, PPT, Word',
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final sampleFiles = {
      'pdf': 'sample_document.pdf',
      'excel': 'data_sheet.xlsx',
      'ppt': 'presentation.pptx',
      'word': 'notes.docx',
    };
    final t = widget.t;

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
                'Select File Type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Simulated file picker — real one needs file_picker package.',
                style: TextStyle(fontSize: 11, color: t.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              ...widget.fileTypes.entries.map(
                (e) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      widget.onPicked(sampleFiles[e.key]!, e.key);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: t.surface2,
                        border: Border.all(color: t.border2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(e.value, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Text(
                            e.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              color: t.text,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final String hint;
  final Map<String, String>? value;
  final List<Map<String, String>> items;
  final String Function(Map<String, String>) label;
  final _T t;
  final ValueChanged<Map<String, String>?> onChanged;
  const _DropField({
    required this.hint,
    required this.value,
    required this.items,
    required this.label,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Map<String, String>>(
        value: value?.isEmpty == true ? null : value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: t.surface,
        hint: Text(hint, style: TextStyle(fontSize: 13, color: t.textMuted)),
        style: TextStyle(fontSize: 13, color: t.text),
        icon: Icon(Icons.keyboard_arrow_down, size: 18, color: t.textMuted),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  label(item),
                  style: TextStyle(fontSize: 13, color: t.text),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
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
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              fontSize: 13,
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
          curve: Curves.easeOut,
          height: 48,
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

  void _showDeleteDialog(BuildContext context, ResourceModel r, _T t) {
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

class _MobileDrawer extends StatelessWidget {
  final _T t;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  const _MobileDrawer({
    required this.t,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, 'Browse', 0),
      (Icons.folder_outlined, 'My Resources', 1),
      (Icons.upload_outlined, 'Upload', 2),
      (Icons.person_outline_rounded, 'Profile', 3),
    ];

    return Drawer(
      backgroundColor: t.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  _SidebarLogo(t: t),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: t.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: t.border, height: 1),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Container(
                height: 36,
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
                        onChanged: (q) => context.read<DashboardBloc>().add(
                          DashboardSearchChanged(q),
                        ),
                        style: TextStyle(fontSize: 13, color: t.text),
                        decoration: InputDecoration(
                          hintText: 'Search resources...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: t.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Nav items
            ...items.map((item) {
              final isActive = currentIndex == item.$3;
              return _SidebarItem(
                icon: item.$1,
                label: item.$2,
                isActive: isActive,
                t: t,
                onTap: () => onNavTap(item.$3),
              );
            }),

            const Spacer(),
            Divider(color: t.border, height: 1),

            // Avatar + name row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lhorenz Magtibay',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                        ),
                        Text(
                          'lhorenz@email.com',
                          style: TextStyle(fontSize: 11, color: t.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Log out
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
              child: _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Log out',
                isActive: false,
                t: t,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: dispatch logout event
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
