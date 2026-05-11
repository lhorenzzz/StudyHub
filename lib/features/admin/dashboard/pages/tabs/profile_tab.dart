import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../../widgets/theme_helper.dart';
import '../../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE TAB
// ─────────────────────────────────────────────────────────────────────────────
class ProfileTab extends StatefulWidget {
  final AdminTheme t;
  final AdminLoaded state;
  const ProfileTab({super.key, required this.t, required this.state});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _showDeleteConfirm = false;
  late String _name;
  late String _email;
  late String _bio;

  @override
  void initState() {
    super.initState();
    _name = widget.state.currentAdminName;
    _email = widget.state.currentAdminEmail;
    _bio = 'StudyHub administrator.';
  }

  String get _initials {
    if (_name.trim().isEmpty) return '?';
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  List<ResourceModel> get _myUploads =>
      widget.state.resources
          .where((r) => r.uploadedBy == widget.state.currentAdminId)
          .toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

  Map<String, List<ResourceModel>> get _groupedByMonth {
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
    final Map<String, List<ResourceModel>> map = {};
    for (final r in _myUploads) {
      final key = '${months[r.uploadedAt.month - 1]} ${r.uploadedAt.year}';
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
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
    return '${months[d.month - 1]} ${d.day}';
  }

  void _logout() => context.go('/');

  void _deleteAccount() => context.go('/');

  void _showEditModal() {
    final t = widget.t;
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final bioCtrl = TextEditingController(text: _bio);
    final currPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSaving = false;

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
            width: 480,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Edit Profile',
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
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AdminLabel('Name', required: true, t: t),
                  const SizedBox(height: 8),
                  AdminField(ctrl: nameCtrl, hint: 'Full name', t: t),
                  const SizedBox(height: 14),
                  AdminLabel('Email', required: true, t: t),
                  const SizedBox(height: 8),
                  AdminField(ctrl: emailCtrl, hint: 'Email address', t: t),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1A05),
                      border: Border.all(color: const Color(0xFF4A3010)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 13,
                          color: Color(0xFFFB923C),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Changing your email requires re-authentication.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFB923C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdminLabel('Bio', required: false, t: t),
                  const SizedBox(height: 8),
                  AdminField(
                    ctrl: bioCtrl,
                    hint: 'About you...',
                    t: t,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AdminLabel('Current Password', required: false, t: t),
                  const SizedBox(height: 8),
                  AdminField(
                    ctrl: currPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  AdminLabel('New Password', required: false, t: t),
                  const SizedBox(height: 8),
                  AdminField(
                    ctrl: newPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  AdminLabel('Confirm New Password', required: false, t: t),
                  const SizedBox(height: 8),
                  AdminField(
                    ctrl: confirmPassCtrl,
                    hint: '••••••••',
                    t: t,
                    obscure: true,
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder(
                    valueListenable: confirmPassCtrl,
                    builder: (_, __, ___) {
                      if (newPassCtrl.text.isEmpty ||
                          confirmPassCtrl.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final matches = newPassCtrl.text == confirmPassCtrl.text;
                      return Row(
                        children: [
                          Icon(
                            matches
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            size: 13,
                            color: matches
                                ? const Color(0xFF34D399)
                                : const Color(0xFFFF6B6B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            matches
                                ? 'Passwords match'
                                : 'Passwords do not match',
                            style: TextStyle(
                              fontSize: 11,
                              color: matches
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: AdminSubmitBtn(
                      isLoading: isSaving,
                      t: t,
                      label: 'Save Changes',
                      onTap: () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        if (newPassCtrl.text.isNotEmpty &&
                            newPassCtrl.text != confirmPassCtrl.text) {
                          setS(() => isSaving = false);
                          return;
                        }
                        setS(() => isSaving = true);
                        await Future.delayed(const Duration(milliseconds: 600));
                        setState(() {
                          if (nameCtrl.text.trim().isNotEmpty) {
                            _name = nameCtrl.text.trim();
                          }
                          if (emailCtrl.text.trim().isNotEmpty) {
                            _email = emailCtrl.text.trim();
                          }
                          _bio = bioCtrl.text.trim();
                        });
                        setS(() => isSaving = false);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: widget.t.surface,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: widget.t.border),
                              ),
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 14,
                                    color: widget.t.text,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Profile saved',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.t.text,
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
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
    final grouped = _groupedByMonth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final isWide = constraints.maxWidth > 600;

              final leftCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: t.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border2, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: t.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_bio.isNotEmpty) ...[
                    Text(
                      _bio,
                      style: TextStyle(
                        fontSize: 13,
                        color: t.textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Edit Profile
                  SizedBox(
                    width: double.infinity,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showEditModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: t.surface2,
                            border: Border.all(color: t.border2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Edit profile',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 20),
                  _ProfileStat(
                    icon: Icons.upload_file_outlined,
                    label: 'uploads',
                    value: '${_myUploads.length}',
                    t: t,
                  ),
                  const SizedBox(height: 10),
                  _ProfileStat(
                    icon: Icons.folder_outlined,
                    label: 'categories',
                    value: '${widget.state.categories.length}',
                    t: t,
                  ),
                  const SizedBox(height: 10),
                  _ProfileStat(
                    icon: Icons.people_outline,
                    label: 'users',
                    value: '${widget.state.totalUsers}',
                    t: t,
                  ),
                  const SizedBox(height: 20),
                  Divider(color: t.border, height: 1),
                  const SizedBox(height: 20),
                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: t.surface2,
                            border: Border.all(color: t.border2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: t.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete account
                  if (!_showDeleteConfirm)
                    SizedBox(
                      width: double.infinity,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _showDeleteConfirm = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1010),
                              border: Border.all(
                                color: const Color(0xFF4A1A1A),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Delete account',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      'This permanently deletes your Firebase Auth account. Cannot be undone.',
                      style: TextStyle(
                        fontSize: 12,
                        color: t.textSub,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AdminHoverBtn(
                            label: 'Cancel',
                            t: t,
                            primary: false,
                            onTap: () =>
                                setState(() => _showDeleteConfirm = false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _deleteAccount,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC3333),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Yes, Delete',
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
                ],
              );

              final rightCol = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.isEmpty
                    ? [
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
                                  'No uploads yet.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: t.textSub,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Go to Global Resources to upload.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    : grouped.entries.map((entry) {
                        final monthLabel = entry.key;
                        final resources = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    monthLabel,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: t.textSub,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Divider(
                                      color: t.border,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: t.surface,
                                  border: Border.all(color: t.border),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Column(
                                    children: resources.asMap().entries.map((
                                      e,
                                    ) {
                                      final isLast =
                                          e.key == resources.length - 1;
                                      return Column(
                                        children: [
                                          _RecentUploadRow(
                                            resource: e.value,
                                            t: t,
                                            formattedDate: _formatDate(
                                              e.value.uploadedAt,
                                            ),
                                          ),
                                          if (!isLast)
                                            Divider(
                                              color: t.border,
                                              height: 1,
                                              thickness: 1,
                                            ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: leftCol),
                    const SizedBox(width: 32),
                    Expanded(child: rightCol),
                  ],
                );
              }
              return Column(
                children: [leftCol, const SizedBox(height: 24), rightCol],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── PROFILE STAT ─────────────────────────────────────────────────────────────
class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AdminTheme t;
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: t.textMuted),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: t.textSub)),
      ],
    );
  }
}

// ─── RECENT UPLOAD ROW ────────────────────────────────────────────────────────
class _RecentUploadRow extends StatefulWidget {
  final ResourceModel resource;
  final AdminTheme t;
  final String formattedDate;
  const _RecentUploadRow({
    required this.resource,
    required this.t,
    required this.formattedDate,
  });

  @override
  State<_RecentUploadRow> createState() => _RecentUploadRowState();
}

class _RecentUploadRowState extends State<_RecentUploadRow> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        color: _hover ? t.surface2 : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 58,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    r.categoryName,
                    style: TextStyle(fontSize: 11, color: t.textMuted),
                  ),
                ],
              ),
            ),
            Text(
              widget.formattedDate,
              style: TextStyle(fontSize: 11, color: t.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
