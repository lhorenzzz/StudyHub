import 'package:flutter/material.dart';
import 'theme_helper.dart';

// ─── SECTION HEADER ───────────────────────────────────────────────────────────
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final AdminTheme t;
  const AdminSectionHeader({super.key, required this.title, required this.t});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: t.textSub,
      ),
    );
  }
}

// Internal alias kept for backwards-compat inside dashboard files.


// ─── SEARCH FIELD (uncontrolled) ──────────────────────────────────────────────
class AdminSearchField extends StatelessWidget {
  final String hint;
  final AdminTheme t;
  final ValueChanged<String> onChanged;
  const AdminSearchField({
    super.key,
    required this.hint,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: t.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, color: t.text),
              decoration: InputDecoration(
                hintText: hint,
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



// ─── SEARCH FIELD WITH EXTERNAL CONTROLLER ────────────────────────────────────
class AdminSearchFieldWithController extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final AdminTheme t;
  final ValueChanged<String> onChanged;
  const AdminSearchFieldWithController({
    super.key,
    required this.hint,
    required this.controller,
    required this.t,
    required this.onChanged,
  });

  @override
  State<AdminSearchFieldWithController> createState() =>
      _AdminSearchFieldWithControllerState();
}

class _AdminSearchFieldWithControllerState
    extends State<AdminSearchFieldWithController> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 15, color: t.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: TextStyle(fontSize: 13, color: t.text),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(fontSize: 13, color: t.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                child: Icon(Icons.close, size: 14, color: t.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}



// ─── FILTER DROPDOWN ──────────────────────────────────────────────────────────
class AdminFilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<(String, String)> items;
  final AdminTheme t;
  final ValueChanged<String?> onChanged;
  const AdminFilterDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.t,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface2,
        border: Border.all(color: t.border2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: t.surface,
        hint: Text(hint, style: TextStyle(fontSize: 13, color: t.textMuted)),
        style: TextStyle(fontSize: 13, color: t.text),
        icon: Icon(Icons.keyboard_arrow_down, size: 16, color: t.textMuted),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              hint,
              style: TextStyle(fontSize: 13, color: t.textMuted),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem(
              value: item.$1,
              child: Text(
                item.$2,
                style: TextStyle(fontSize: 13, color: t.text),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}



// ─── HOVER BUTTON ─────────────────────────────────────────────────────────────
class AdminHoverBtn extends StatefulWidget {
  final String label;
  final AdminTheme t;
  final bool primary;
  final VoidCallback onTap;
  const AdminHoverBtn({
    super.key,
    required this.label,
    required this.t,
    this.primary = true,
    required this.onTap,
  });

  @override
  State<AdminHoverBtn> createState() => _AdminHoverBtnState();
}

class _AdminHoverBtnState extends State<AdminHoverBtn> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}



// ─── ICON BUTTON ──────────────────────────────────────────────────────────────
class AdminIconBtn extends StatefulWidget {
  final Widget child;
  final AdminTheme t;
  final VoidCallback onTap;
  const AdminIconBtn({
    super.key,
    required this.child,
    required this.t,
    required this.onTap,
  });

  @override
  State<AdminIconBtn> createState() => _AdminIconBtnState();
}

class _AdminIconBtnState extends State<AdminIconBtn> {
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



// ─── CHIP ─────────────────────────────────────────────────────────────────────
class AdminChip extends StatefulWidget {
  final String label;
  final bool selected;
  final AdminTheme t;
  final VoidCallback onTap;
  const AdminChip({
    super.key,
    required this.label,
    required this.selected,
    required this.t,
    required this.onTap,
  });

  @override
  State<AdminChip> createState() => _AdminChipState();
}

class _AdminChipState extends State<AdminChip> {
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
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
              fontSize: 12,
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



// ─── SUBMIT BUTTON ────────────────────────────────────────────────────────────
class AdminSubmitBtn extends StatefulWidget {
  final bool isLoading;
  final AdminTheme t;
  final String label;
  final VoidCallback onTap;
  const AdminSubmitBtn({
    super.key,
    required this.isLoading,
    required this.t,
    this.label = 'Upload Resource',
    required this.onTap,
  });

  @override
  State<AdminSubmitBtn> createState() => _AdminSubmitBtnState();
}

class _AdminSubmitBtnState extends State<AdminSubmitBtn> {
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
          height: 46,
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



// ─── MODAL BUTTON ────────────────────────────────────────────────────────────
class AdminModalBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final AdminTheme t;
  final VoidCallback onTap;
  const AdminModalBtn({
    super.key,
    required this.label,
    required this.primary,
    required this.t,
    required this.onTap,
  });

  @override
  State<AdminModalBtn> createState() => _AdminModalBtnState();
}

class _AdminModalBtnState extends State<AdminModalBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.primary
        ? (widget.t.isDark ? Colors.white : Colors.black)
        : widget.t.surface2;
    final fg = widget.primary
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
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}



// ─── FORM LABEL ───────────────────────────────────────────────────────────────
class AdminLabel extends StatelessWidget {
  final String label;
  final bool required;
  final AdminTheme t;
  const AdminLabel(
    this.label, {
    super.key,
    required this.required,
    required this.t,
  });

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



// ─── TEXT FIELD ───────────────────────────────────────────────────────────────
class AdminField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final AdminTheme t;
  final int maxLines;
  final bool obscure;
  const AdminField({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.t,
    this.maxLines = 1,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      obscureText: obscure,
      style: TextStyle(fontSize: 13, color: t.text),
      cursorColor: t.text,
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



// ─── MODAL TEXT FIELD ─────────────────────────────────────────────────────────
class AdminModalTextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final AdminTheme t;
  const AdminModalTextField({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: TextStyle(fontSize: 13, color: t.text),
      cursorColor: t.text,
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



// ─── MODAL ROW ────────────────────────────────────────────────────────────────
class AdminModalRow extends StatelessWidget {
  final String label, value;
  final AdminTheme t;
  const AdminModalRow({
    super.key,
    required this.label,
    required this.value,
    required this.t,
  });

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



// ─── ANIMATED PAGE SWITCHER ───────────────────────────────────────────────────
class AdminAnimatedPageSwitcher extends StatefulWidget {
  final int index;
  final List<Widget> pages;
  const AdminAnimatedPageSwitcher({
    super.key,
    required this.index,
    required this.pages,
  });

  @override
  State<AdminAnimatedPageSwitcher> createState() =>
      _AdminAnimatedPageSwitcherState();
}

class _AdminAnimatedPageSwitcherState extends State<AdminAnimatedPageSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  int _cur = 0;

  @override
  void initState() {
    super.initState();
    _cur = widget.index;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AdminAnimatedPageSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _ctrl.reverse().then((_) {
        setState(() => _cur = widget.index);
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
      child: SlideTransition(position: _slide, child: widget.pages[_cur]),
    );
  }
}






