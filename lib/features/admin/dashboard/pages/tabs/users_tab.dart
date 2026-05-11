import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/admin_user.dart';
import 'package:study_hub/features/admin/dashboard/BLoC/admin_bloc.dart';
import '../widgets/theme_helper.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/shared_dialogs.dart';

// ─────────────────────────────────────────────────────────────────────────────
// USERS TAB
// ─────────────────────────────────────────────────────────────────────────────
class UsersTab extends StatelessWidget {
  final AdminLoaded state;
  final AdminTheme t;
  const UsersTab({super.key, required this.state, required this.t});

  List<AdminUser> get _filtered {
    var list = [...state.filteredUsers];
    if (state.userSort == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;

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
                    'Users',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage all registered users.',
                    style: TextStyle(fontSize: 13, color: t.textSub),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${_filtered.length} users',
                style: TextStyle(fontSize: 13, color: t.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _RoleCountRow(users: state.users, t: t),
          const SizedBox(height: 16),

          // Search + Filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : 240,
                child: AdminSearchField(
                  hint: 'Search by name or email...',
                  t: t,
                  onChanged: (q) =>
                      context.read<AdminBloc>().add(AdminUserSearchChanged(q)),
                ),
              ),
              AdminFilterDropdown(
                hint: 'All roles',
                value: state.userRoleFilter.isEmpty
                    ? null
                    : state.userRoleFilter,
                items: const [
                  ('admin', 'Admin'),
                  ('student', 'Student'),
                  ('moderator', 'Moderator'),
                ],
                t: t,
                onChanged: (v) => context.read<AdminBloc>().add(
                  AdminUserRoleFilterChanged(v ?? ''),
                ),
              ),
              AdminFilterDropdown(
                hint: 'Sort: Date',
                value: state.userSort,
                items: const [
                  ('date', 'Sort: Date'),
                  ('name', 'Sort: Name A–Z'),
                ],
                t: t,
                onChanged: (v) => context.read<AdminBloc>().add(
                  AdminUserSortChanged(v ?? 'date'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          if (_filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 36, color: t.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      state.userSearch.isNotEmpty ||
                              state.userRoleFilter.isNotEmpty
                          ? 'No users match your filters.'
                          : 'No users registered yet.',
                      style: TextStyle(color: t.textSub, fontSize: 13),
                    ),
                    if (state.userSearch.isNotEmpty ||
                        state.userRoleFilter.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            context.read<AdminBloc>().add(
                              AdminUserSearchChanged(''),
                            );
                            context.read<AdminBloc>().add(
                              AdminUserRoleFilterChanged(''),
                            );
                          },
                          child: Text(
                            'Clear filters',
                            style: TextStyle(fontSize: 12, color: t.textSub),
                          ),
                        ),
                      ),
                    ],
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
                            const SizedBox(width: 46),
                            Expanded(flex: 3, child: _ColHeader('Name', t)),
                            Expanded(flex: 3, child: _ColHeader('Email', t)),
                            SizedBox(width: 90, child: _ColHeader('Role', t)),
                            SizedBox(width: 90, child: _ColHeader('Status', t)),
                            SizedBox(
                              width: 100,
                              child: _ColHeader('Joined', t),
                            ),
                            SizedBox(
                              width: 110,
                              child: _ColHeader('Actions', t),
                            ),
                          ],
                        ),
                      ),
                    ..._filtered.asMap().entries.map((entry) {
                      final isLast = entry.key == _filtered.length - 1;
                      return _UserRow(
                        user: entry.value,
                        t: t,
                        isLast: isLast,
                        isNarrow: isNarrow,
                        onDelete: () => _confirmDelete(context, entry.value),
                        onBan: () => _confirmBan(context, entry.value),
                        onSuspend: () => _confirmSuspend(context, entry.value),
                        onUnban: () => _confirmUnban(context, entry.value),
                        onViewUploads: () => _viewUploads(context, entry.value),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _viewUploads(BuildContext context, AdminUser u) {
    if (u.role == 'admin') {
      context.read<AdminBloc>().add(AdminTabChanged(AdminTab.myResources));
    } else {
      context.read<AdminBloc>()
        ..add(AdminUserUploadsFilterChanged(u.name))
        ..add(AdminTabChanged(AdminTab.userUploads));
    }
  }

  void _confirmBan(BuildContext context, AdminUser u) {
    showAdminConfirmDialog(
      context: context,
      t: t,
      title: 'Ban User',
      body:
          'Permanently ban "${u.name}"?\n\n'
          '• Their account will be disabled\n'
          '• They cannot log in until reinstated\n'
          '• Use Suspend instead for temporary restrictions',
      confirmLabel: 'Ban',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserBanRequested(u.id)),
    );
  }

  void _confirmSuspend(BuildContext context, AdminUser u) {
    showAdminConfirmDialog(
      context: context,
      t: t,
      title: 'Suspend User',
      body:
          'Temporarily suspend "${u.name}"?\n\n'
          '• Their status will be set to suspended\n'
          '• They cannot access the app until reinstated\n'
          '• Use Ban for permanent removal of access',
      confirmLabel: 'Suspend',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserSuspendRequested(u.id)),
    );
  }

  void _confirmUnban(BuildContext context, AdminUser u) {
    final isBanned = u.status == 'banned';
    showAdminConfirmDialog(
      context: context,
      t: t,
      title: isBanned ? 'Lift Ban' : 'Lift Suspension',
      body: isBanned
          ? 'Lift the ban on "${u.name}"?\n\n'
                '• Their account will be re-enabled\n'
                '• They will be able to log in again'
          : 'Lift the suspension on "${u.name}"?\n\n'
                '• Their status will be set back to active\n'
                '• They will regain full app access',
      confirmLabel: isBanned ? 'Lift Ban' : 'Lift Suspension',
      isDestructive: false,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserUnbanRequested(u.id)),
    );
  }

  void _confirmDelete(BuildContext context, AdminUser u) {
    showAdminConfirmDialog(
      context: context,
      t: t,
      title: 'Delete User',
      body:
          'Delete "${u.name}"? This removes them from Firestore. '
          'Firebase Auth account will still exist until backend wires Cloud Function.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () =>
          context.read<AdminBloc>().add(AdminUserDeleteRequested(u.id)),
    );
  }
}

// ─── ROLE COUNT ROW ───────────────────────────────────────────────────────────
class _RoleCountRow extends StatelessWidget {
  final List<AdminUser> users;
  final AdminTheme t;
  const _RoleCountRow({required this.users, required this.t});

  @override
  Widget build(BuildContext context) {
    final students = users.where((u) => u.role == 'student').length;
    final admins = users.where((u) => u.role == 'admin').length;
    final moderators = users.where((u) => u.role == 'moderator').length;
    final banned = users.where((u) => u.status == 'banned').length;
    final suspended = users.where((u) => u.status == 'suspended').length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _CountChip(
          label: 'Students',
          count: students,
          bg: const Color(0xFF0F2040),
          fg: const Color(0xFF60A5FA),
          t: t,
        ),
        _CountChip(
          label: 'Admins',
          count: admins,
          bg: const Color(0xFF0A2A18),
          fg: const Color(0xFF34D399),
          t: t,
        ),
        if (moderators > 0)
          _CountChip(
            label: 'Moderators',
            count: moderators,
            bg: const Color(0xFF2A1F05),
            fg: const Color(0xFFFB923C),
            t: t,
          ),
        if (banned > 0)
          _CountChip(
            label: 'Banned',
            count: banned,
            bg: const Color(0xFF3A1010),
            fg: const Color(0xFFFF6B6B),
            t: t,
          ),
        if (suspended > 0)
          _CountChip(
            label: 'Suspended',
            count: suspended,
            bg: const Color(0xFF2A1A05),
            fg: const Color(0xFFFBBF24),
            t: t,
          ),
      ],
    );
  }
}

// ─── COUNT CHIP ───────────────────────────────────────────────────────────────
class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color bg, fg;
  final AdminTheme t;
  const _CountChip({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: fg.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

// ─── COLUMN HEADER ────────────────────────────────────────────────────────────
class _ColHeader extends StatelessWidget {
  final String label;
  final AdminTheme t;
  const _ColHeader(this.label, this.t);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: t.textMuted,
      ),
    );
  }
}

// ─── ROLE / STATUS BADGE COLORS ───────────────────────────────────────────────
({Color bg, Color fg, Color border}) _roleBadgeColors(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return (
        bg: const Color(0xFF0A2A18),
        fg: const Color(0xFF34D399),
        border: const Color(0xFF34D399),
      );
    case 'moderator':
      return (
        bg: const Color(0xFF2A1F05),
        fg: const Color(0xFFFB923C),
        border: const Color(0xFFFB923C),
      );
    default:
      return (
        bg: const Color(0xFF0F2040),
        fg: const Color(0xFF60A5FA),
        border: const Color(0xFF60A5FA),
      );
  }
}

({Color bg, Color fg, Color border}) _statusBadgeColors(String status) {
  switch (status.toLowerCase()) {
    case 'banned':
      return (
        bg: const Color(0xFF3A1010),
        fg: const Color(0xFFFF6B6B),
        border: const Color(0xFFFF6B6B),
      );
    case 'suspended':
      return (
        bg: const Color(0xFF2A1A05),
        fg: const Color(0xFFFBBF24),
        border: const Color(0xFFFBBF24),
      );
    default:
      return (
        bg: const Color(0xFF0A2A18),
        fg: const Color(0xFF34D399),
        border: const Color(0xFF34D399),
      );
  }
}

// ─── USER ROW ─────────────────────────────────────────────────────────────────
class _UserRow extends StatefulWidget {
  final AdminUser user;
  final AdminTheme t;
  final bool isLast;
  final bool isNarrow;
  final VoidCallback onDelete;
  final VoidCallback onBan;
  final VoidCallback onSuspend;
  final VoidCallback onUnban;
  final VoidCallback onViewUploads;

  const _UserRow({
    required this.user,
    required this.t,
    required this.isLast,
    required this.isNarrow,
    required this.onDelete,
    required this.onBan,
    required this.onSuspend,
    required this.onUnban,
    required this.onViewUploads,
  });

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hover = false;

  String get _initials {
    final parts = widget.user.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return widget.user.name.isNotEmpty
        ? widget.user.name[0].toUpperCase()
        : '?';
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
    final u = widget.user;
    final t = widget.t;
    final roleColors = _roleBadgeColors(u.role);
    final statusColors = _statusBadgeColors(u.status);
    final isBannedOrSuspended = u.status == 'banned' || u.status == 'suspended';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
                  _UserAvatar(initials: _initials, t: t),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          u.email,
                          style: TextStyle(fontSize: 11, color: t.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: u.status.toUpperCase(),
                    bg: statusColors.bg,
                    fg: statusColors.fg,
                    border: statusColors.border,
                  ),
                  const SizedBox(width: 8),
                  _UserActionsMenu(
                    u: u,
                    t: t,
                    isBannedOrSuspended: isBannedOrSuspended,
                    onBan: widget.onBan,
                    onSuspend: widget.onSuspend,
                    onUnban: widget.onUnban,
                    onViewUploads: widget.onViewUploads,
                    onDelete: widget.onDelete,
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: _UserAvatar(initials: _initials, t: t),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      u.name,
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
                    flex: 3,
                    child: Text(
                      u.email,
                      style: TextStyle(fontSize: 12, color: t.textSub),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(
                        label: u.role.toUpperCase(),
                        bg: roleColors.bg,
                        fg: roleColors.fg,
                        border: roleColors.border,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _StatusBadge(
                        label: u.status.toUpperCase(),
                        bg: statusColors.bg,
                        fg: statusColors.fg,
                        border: statusColors.border,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      _formatDate(u.createdAt),
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: _UserActionsMenu(
                      u: u,
                      t: t,
                      isBannedOrSuspended: isBannedOrSuspended,
                      onBan: widget.onBan,
                      onSuspend: widget.onSuspend,
                      onUnban: widget.onUnban,
                      onViewUploads: widget.onViewUploads,
                      onDelete: widget.onDelete,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── USER AVATAR ──────────────────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  final String initials;
  final AdminTheme t;
  const _UserAvatar({required this.initials, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: t.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: t.border2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
        ),
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bg, fg, border;
  const _StatusBadge({
    required this.label,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: fg,
        ),
      ),
    );
  }
}

// ─── USER ACTIONS MENU ────────────────────────────────────────────────────────
class _UserActionsMenu extends StatelessWidget {
  final AdminUser u;
  final AdminTheme t;
  final bool isBannedOrSuspended;
  final VoidCallback onBan;
  final VoidCallback onSuspend;
  final VoidCallback onUnban;
  final VoidCallback onViewUploads;
  final VoidCallback onDelete;

  const _UserActionsMenu({
    required this.u,
    required this.t,
    required this.isBannedOrSuspended,
    required this.onBan,
    required this.onSuspend,
    required this.onUnban,
    required this.onViewUploads,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (u.role == 'admin') {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onViewUploads,
          child: const Icon(
            Icons.folder_outlined,
            size: 15,
            color: Color(0xFF60A5FA),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Uploads',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onViewUploads,
              child: const Icon(
                Icons.folder_outlined,
                size: 15,
                color: Color(0xFF60A5FA),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (!isBannedOrSuspended) ...[
          Tooltip(
            message: 'Suspend',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onSuspend,
                child: const Icon(
                  Icons.pause_circle_outline,
                  size: 15,
                  color: Color(0xFFFBBF24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Ban',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onBan,
                child: const Icon(
                  Icons.block_outlined,
                  size: 15,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ),
        ] else ...[
          Tooltip(
            message: 'Reinstate',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onUnban,
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 15,
                  color: Color(0xFF34D399),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Tooltip(
          message: 'Delete',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline,
                size: 15,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
