import 'package:flutter/material.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';

// ─── QuickTabs ───────────────────────────────────────────────────────────────
// Import the BLoC and state here to dispatch events
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// shared_widgets.dart
//
// All reusable UI widgets used across tabs and other widget files.
// Classes are public (no _ prefix) so they can be imported cross-file.
//
// Widgets exported:
//   HoverBtn, FieldLabel, InputField, DifficultyChip, SubmitBtn,
//   FilePickerBox, CategoryDropField, ResourceTag, ActionText,
//   ActionIcon, ModalRow, ModalBtn, SectionHeader, StatCard,
//   AnimatedPageSwitcher, LastOpenedBar, QuickTabs, TabChip
// ─────────────────────────────────────────────────────────────────────────────

// ─── HoverBtn ────────────────────────────────────────────────────────────────
class HoverBtn extends StatefulWidget {
  final String label;
  final UserTheme t;
  final bool primary;
  final VoidCallback onTap;
  const HoverBtn({
    super.key,
    required this.label,
    required this.t,
    this.primary = true,
    required this.onTap,
  });

  @override
  State<HoverBtn> createState() => _HoverBtnState();
}

class _HoverBtnState extends State<HoverBtn> {
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

// ─── FieldLabel ──────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final UserTheme t;
  const FieldLabel(
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

// ─── InputField ──────────────────────────────────────────────────────────────
class InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final UserTheme t;
  final int maxLines;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  const InputField({
    super.key,
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

// ─── DifficultyChip ──────────────────────────────────────────────────────────
class DifficultyChip extends StatefulWidget {
  final String label;
  final bool selected;
  final UserTheme t;
  final VoidCallback onTap;
  const DifficultyChip({
    super.key,
    required this.label,
    required this.selected,
    required this.t,
    required this.onTap,
  });

  @override
  State<DifficultyChip> createState() => _DifficultyChipState();
}

class _DifficultyChipState extends State<DifficultyChip> {
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

// ─── SubmitBtn ───────────────────────────────────────────────────────────────
class SubmitBtn extends StatefulWidget {
  final bool isLoading;
  final UserTheme t;
  final String label;
  final VoidCallback onTap;
  const SubmitBtn({
    super.key,
    required this.isLoading,
    required this.t,
    this.label = 'Upload Resource',
    required this.onTap,
  });

  @override
  State<SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<SubmitBtn> {
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

// ─── FilePickerBox ───────────────────────────────────────────────────────────
class FilePickerBox extends StatefulWidget {
  final String fileName;
  final String fileType;
  final Map<String, String> fileTypes;
  final UserTheme t;
  final Function(String name, String type) onPicked;
  final VoidCallback onClear;
  const FilePickerBox({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.fileTypes,
    required this.t,
    required this.onPicked,
    required this.onClear,
  });

  @override
  State<FilePickerBox> createState() => _FilePickerBoxState();
}

class _FilePickerBoxState extends State<FilePickerBox> {
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

  // ─── TODO (Backend Team) ───────────────────────────────────────────────────
  // Replace this simulated picker with the real file_picker package:
  //
  //   import 'package:file_picker/file_picker.dart';
  //
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf', 'xlsx', 'pptx', 'docx'],
  //     withData: true,  // set to true to get file bytes for upload
  //   );
  //   if (result != null) {
  //     final file = result.files.single;
  //     widget.onPicked(file.name, file.extension ?? 'pdf', file.bytes);
  //   }
  //
  // Also update the onPicked callback signature to pass bytes:
  //   final Function(String name, String type, Uint8List? bytes) onPicked;
  // ──────────────────────────────────────────────────────────────────────────
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
                'Simulated picker — replace with file_picker package.',
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

// ─── CategoryDropField ───────────────────────────────────────────────────────
class CategoryDropField extends StatelessWidget {
  final String hint;
  final Map<String, String>? value;
  final List<Map<String, String>> items;
  final String Function(Map<String, String>) label;
  final UserTheme t;
  final ValueChanged<Map<String, String>?> onChanged;
  const CategoryDropField({
    super.key,
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

// ─── ResourceTag ─────────────────────────────────────────────────────────────
class ResourceTag extends StatelessWidget {
  final String label;
  final UserTheme t;
  const ResourceTag({super.key, required this.label, required this.t});

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

// ─── ActionText ──────────────────────────────────────────────────────────────
class ActionText extends StatefulWidget {
  final String label;
  final UserTheme t;
  final VoidCallback onTap;
  const ActionText({
    super.key,
    required this.label,
    required this.t,
    required this.onTap,
  });

  @override
  State<ActionText> createState() => _ActionTextState();
}

class _ActionTextState extends State<ActionText> {
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

// ─── ActionIcon ──────────────────────────────────────────────────────────────
class ActionIcon extends StatefulWidget {
  final String icon;
  final bool active;
  final UserTheme t;
  final VoidCallback onTap;
  const ActionIcon({
    super.key,
    required this.icon,
    required this.active,
    required this.t,
    required this.onTap,
  });

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
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

// ─── ModalRow ────────────────────────────────────────────────────────────────
class ModalRow extends StatelessWidget {
  final String label, value;
  final UserTheme t;
  const ModalRow({
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

// ─── ModalBtn ────────────────────────────────────────────────────────────────
class ModalBtn extends StatefulWidget {
  final String label;
  final bool primary;
  final UserTheme t;
  final VoidCallback onTap;
  const ModalBtn({
    super.key,
    required this.label,
    required this.primary,
    required this.t,
    required this.onTap,
  });

  @override
  State<ModalBtn> createState() => _ModalBtnState();
}

class _ModalBtnState extends State<ModalBtn> {
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

// ─── SectionHeader ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final UserTheme t;
  final VoidCallback? onSeeAll;
  const SectionHeader({
    super.key,
    required this.title,
    required this.t,
    this.onSeeAll,
  });

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
        if (onSeeAll != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all →',
                style: TextStyle(fontSize: 12, color: t.textMuted),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── StatCard ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final double width;
  final UserTheme t;
  const StatCard({
    super.key,
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

// ─── AnimatedPageSwitcher ────────────────────────────────────────────────────
class AnimatedPageSwitcher extends StatefulWidget {
  final int index;
  final List<Widget> pages;
  const AnimatedPageSwitcher({
    super.key,
    required this.index,
    required this.pages,
  });

  @override
  State<AnimatedPageSwitcher> createState() => _AnimatedPageSwitcherState();
}

class _AnimatedPageSwitcherState extends State<AnimatedPageSwitcher>
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
  void didUpdateWidget(AnimatedPageSwitcher old) {
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

class QuickTabs extends StatelessWidget {
  final DashboardTab activeTab;
  final UserTheme t;
  const QuickTabs({super.key, required this.activeTab, required this.t});

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
            child: TabChip(
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

// ─── TabChip ─────────────────────────────────────────────────────────────────
class TabChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final UserTheme t;
  final VoidCallback onTap;
  const TabChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.t,
    required this.onTap,
  });

  @override
  State<TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<TabChip> {
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
