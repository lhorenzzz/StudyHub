import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';

class DashboardNavbar extends StatelessWidget {
  final UserTheme t;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback onLogoTap;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const DashboardNavbar({
    super.key,
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
          NavLogo(t: t, onTap: onLogoTap),
          if (!isNarrow) ...[
            const SizedBox(width: 24),
            // find the NavLinks block, replace with:
            NavLink(
              label: 'Browse',
              index: 0,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            NavLink(
              label: 'Global Resources',
              index: 1,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            NavLink(
              label: 'My Resources',
              index: 2,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            NavLink(
              label: 'Upload',
              index: 3,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
            NavLink(
              label: 'Profile',
              index: 4,
              currentIndex: currentIndex,
              t: t,
              onTap: onNavTap,
            ),
          ],
          const Spacer(),
          if (!isNarrow) ...[NavSearchBar(t: t), const SizedBox(width: 10)],
          NavIconBtn(
            child: Text(
              t.isDark ? '☀' : '🌙',
              style: const TextStyle(fontSize: 13),
            ),
            t: t,
            onTap: () => context.read<DashboardBloc>().add(ThemeToggled()),
          ),
          const SizedBox(width: 10),
          if (!isNarrow)
            // ── TODO (Backend Team) ────────────────────────────────────────
            // Replace '?' with real user initials from Firebase Auth:
            //
            //   final user = FirebaseAuth.instance.currentUser;
            //   final name = user?.displayName ?? '';
            //   final initials = name.trim().isEmpty ? '?'
            //       : name.trim().split(' ').take(2)
            //           .map((p) => p[0].toUpperCase()).join();
            //
            // Pass initials into DashboardNavbar via DashboardLoaded state.
            // ────────────────────────────────────────────────────────────────
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
                    '?',
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
            NavIconBtn(
              child: Icon(Icons.menu_rounded, size: 16, color: t.text),
              t: t,
              onTap: () => scaffoldKey?.currentState?.openDrawer(),
            ),
        ],
      ),
    );
  }
}

// ─── NavLogo ─────────────────────────────────────────────────────────────────
class NavLogo extends StatelessWidget {
  final UserTheme t;
  final VoidCallback onTap;
  const NavLogo({super.key, required this.t, required this.onTap});

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

// ─── NavLink ─────────────────────────────────────────────────────────────────
class NavLink extends StatefulWidget {
  final String label;
  final int index;
  final int currentIndex;
  final UserTheme t;
  final ValueChanged<int> onTap;
  const NavLink({
    super.key,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.t,
    required this.onTap,
  });

  @override
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink> {
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

// ─── NavSearchBar ────────────────────────────────────────────────────────────
class NavSearchBar extends StatelessWidget {
  final UserTheme t;
  const NavSearchBar({super.key, required this.t});

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

// ─── NavIconBtn ──────────────────────────────────────────────────────────────
class NavIconBtn extends StatefulWidget {
  final Widget child;
  final UserTheme t;
  final VoidCallback onTap;
  const NavIconBtn({
    super.key,
    required this.child,
    required this.t,
    required this.onTap,
  });

  @override
  State<NavIconBtn> createState() => _NavIconBtnState();
}

class _NavIconBtnState extends State<NavIconBtn> {
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

// ─── MobileDrawer ────────────────────────────────────────────────────────────
class MobileDrawer extends StatelessWidget {
  final UserTheme t;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  const MobileDrawer({
    super.key,
    required this.t,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, 'Browse', 0),
      (Icons.public_outlined, 'Global Resources', 1),
      (Icons.folder_outlined, 'My Resources', 2),
      (Icons.upload_outlined, 'Upload', 3),
      (Icons.person_outline_rounded, 'Profile', 4),
    ];

    return Drawer(
      backgroundColor: t.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  SidebarLogo(t: t),
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

            // ── Search ──────────────────────────────────────────────────────
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

            // ── Nav items ───────────────────────────────────────────────────
            ...items.map((item) {
              final isActive = currentIndex == item.$3;
              return SidebarItem(
                icon: item.$1,
                label: item.$2,
                isActive: isActive,
                t: t,
                onTap: () => onNavTap(item.$3),
              );
            }),

            const Spacer(),
            Divider(color: t.border, height: 1),

            // ── User info ───────────────────────────────────────────────────
            // ── TODO (Backend Team) ──────────────────────────────────────────
            // Replace placeholder with real user data from Firebase Auth:
            //
            //   final user = FirebaseAuth.instance.currentUser;
            //   final name = user?.displayName ?? 'User';
            //   final email = user?.email ?? '';
            //   final initials = name.trim().isEmpty ? '?'
            //       : name.trim().split(' ').take(2)
            //           .map((p) => p[0].toUpperCase()).join();
            //
            // Pass name/email/initials via DashboardLoaded state.
            // ────────────────────────────────────────────────────────────────
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
                        '?',
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
                          'Not signed in',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: t.text,
                          ),
                        ),
                        Text(
                          '—',
                          style: TextStyle(fontSize: 11, color: t.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Log out ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
              child: SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Log out',
                isActive: false,
                t: t,
                onTap: () {
                  Navigator.pop(context);
                  // ── TODO (Backend Team) ──────────────────────────────────
                  // await FirebaseAuth.instance.signOut();
                  // context.go('/login');
                  // ────────────────────────────────────────────────────────
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

// ─── SidebarLogo ─────────────────────────────────────────────────────────────
class SidebarLogo extends StatelessWidget {
  final UserTheme t;
  const SidebarLogo({super.key, required this.t});

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

// ─── SidebarSectionLabel ─────────────────────────────────────────────────────
class SidebarSectionLabel extends StatelessWidget {
  final String label;
  final UserTheme t;
  const SidebarSectionLabel({super.key, required this.label, required this.t});

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

// ─── SidebarItem ─────────────────────────────────────────────────────────────
class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final UserTheme t;
  final VoidCallback onTap;
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
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

// ─── SidebarCategoryItem ──────────────────────────────────────────────────────
class SidebarCategoryItem extends StatefulWidget {
  final String emoji, label;
  final int? count;
  final bool isSelected;
  final UserTheme t;
  final VoidCallback onTap;
  const SidebarCategoryItem({
    super.key,
    required this.emoji,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.t,
    required this.onTap,
  });

  @override
  State<SidebarCategoryItem> createState() => _SidebarCategoryItemState();
}

class _SidebarCategoryItemState extends State<SidebarCategoryItem> {
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
