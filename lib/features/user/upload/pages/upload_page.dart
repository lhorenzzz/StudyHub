import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/theme/app_colors.dart';
import 'package:study_hub/features/user/upload/BLoC/upload_bloc.dart';

class UploadPage extends StatefulWidget {
  final _T t;
  const UploadPage({super.key, required this.t});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  // Dummy categories — will come from DashboardBloc later
  final _categories = [
    {'id': 'it', 'name': 'Information Technology', 'emoji': '💻'},
    {'id': 'science', 'name': 'Science', 'emoji': '🧪'},
    {'id': 'cookery', 'name': 'Cookery', 'emoji': '🍳'},
  ];

  final _difficulties = ['Beginner', 'Intermediate'];

  // Accepted file types and their emojis
  final _fileTypes = {'pdf': '📄', 'excel': '📊', 'ppt': '📑', 'word': '📝'};

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

    return BlocProvider(
      create: (_) => UploadBloc(),
      child: BlocConsumer<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            // Clear text controllers on success
            _titleCtrl.clear();
            _descCtrl.clear();
            _tagsCtrl.clear();
          }
        },
        builder: (context, state) {
          final bloc = context.read<UploadBloc>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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

                    // ── Success state ──
                    if (state is UploadSuccess) ...[
                      _SuccessBanner(
                        title: state.resourceTitle,
                        t: t,
                        onUploadAnother: () => bloc.add(UploadReset()),
                      ),
                    ] else ...[
                      // ── Title (required) ──
                      _FieldLabel(label: 'Title', required: true, t: t),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _titleCtrl,
                        hint: 'e.g. HTML Basics — Structure & Tags',
                        t: t,
                        onChanged: (v) => bloc.add(UploadTitleChanged(v)),
                      ),
                      const SizedBox(height: 20),

                      // ── File picker (required) ──
                      _FieldLabel(label: 'File', required: true, t: t),
                      const SizedBox(height: 8),
                      _FilePicker(
                        state: state,
                        fileTypes: _fileTypes,
                        t: t,
                        onFilePicked: (name, type) => bloc.add(
                          UploadFileSelected(fileName: name, fileType: type),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Category (required) ──
                      _FieldLabel(label: 'Category', required: true, t: t),
                      const SizedBox(height: 8),
                      _DropdownField<Map<String, String>>(
                        hint: 'Select category',
                        value:
                            state is UploadIdle && state.categoryId.isNotEmpty
                            ? _categories
                                  .cast<Map<String, String>>()
                                  .firstWhere(
                                    (c) => c['id'] == state.categoryId,
                                    orElse: () => <String, String>{},
                                  )
                            : null,
                        items: _categories.cast<Map<String, String>>(),
                        labelBuilder: (c) => '${c['emoji']}  ${c['name']}',
                        t: t,
                        onChanged: (c) {
                          if (c != null) {
                            bloc.add(
                              UploadCategoryChanged(
                                categoryId: c['id']!,
                                categoryName: c['name']!,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Difficulty (required) ──
                      _FieldLabel(label: 'Difficulty', required: true, t: t),
                      const SizedBox(height: 8),
                      Row(
                        children: _difficulties.map((d) {
                          final isSelected =
                              state is UploadIdle && state.difficulty == d;
                          return _DifficultyChip(
                            label: d,
                            isSelected: isSelected,
                            t: t,
                            onTap: () => bloc.add(UploadDifficultyChanged(d)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ── Description (optional) ──
                      _FieldLabel(label: 'Description', required: false, t: t),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _descCtrl,
                        hint: 'Brief description of the resource...',
                        t: t,
                        maxLines: 3,
                        onChanged: (v) => bloc.add(UploadDescriptionChanged(v)),
                      ),
                      const SizedBox(height: 20),

                      // ── Tags (optional) ──
                      _FieldLabel(label: 'Tags', required: false, t: t),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _tagsCtrl,
                        hint: 'e.g. HTML, CSS, beginner (comma separated)',
                        t: t,
                        onChanged: (v) => bloc.add(UploadTagsChanged(v)),
                      ),
                      const SizedBox(height: 32),

                      // ── Error state ──
                      if (state is UploadFailure) ...[
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
                                state.error,
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

                      // ── Submit button ──
                      SizedBox(
                        width: double.infinity,
                        child: _SubmitButton(
                          state: state,
                          t: t,
                          onTap: () => bloc.add(UploadSubmitted()),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  final String title;
  final _T t;
  final VoidCallback onUploadAnother;
  const _SuccessBanner({
    required this.title,
    required this.t,
    required this.onUploadAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                '"$title" is now live and visible to everyone.',
                style: TextStyle(fontSize: 13, color: t.textSub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onUploadAnother,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: t.isDark ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Upload Another',
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
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final _T t;
  const _FieldLabel({
    required this.label,
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
        if (!required) ...[
          const SizedBox(width: 6),
          Text('optional', style: TextStyle(fontSize: 11, color: t.textMuted)),
        ] else ...[
          const SizedBox(width: 4),
          Text('*', style: TextStyle(fontSize: 13, color: t.textMuted)),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final _T t;
  final int maxLines;
  final ValueChanged<String> onChanged;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.t,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

// Simulated file picker — no actual file_picker package yet
class _FilePicker extends StatefulWidget {
  final UploadState state;
  final Map<String, String> fileTypes;
  final _T t;
  final Function(String name, String type) onFilePicked;
  const _FilePicker({
    required this.state,
    required this.fileTypes,
    required this.t,
    required this.onFilePicked,
  });

  @override
  State<_FilePicker> createState() => _FilePickerState();
}

class _FilePickerState extends State<_FilePicker> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hasFile =
        widget.state is UploadIdle &&
        (widget.state as UploadIdle).fileName.isNotEmpty;
    final fileName = hasFile ? (widget.state as UploadIdle).fileName : '';
    final fileType = hasFile ? (widget.state as UploadIdle).fileType : '';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // Simulate file pick — in real app use file_picker package
        onTap: () =>
            _showFilePicker(context, widget.fileTypes, t, widget.onFilePicked),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: hasFile
                ? t.surface
                : (_hover ? t.surface2 : Colors.transparent),
            border: Border.all(
              color: hasFile ? t.border2 : (_hover ? t.border2 : t.border),
              style: hasFile ? BorderStyle.solid : BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: hasFile
              ? Row(
                  children: [
                    Text(
                      widget.fileTypes[fileType] ?? '📄',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 13,
                          color: t.text,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onFilePicked('', ''),
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
                      'PDF, Excel, PPT, Word supported',
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Simulate a file picker dialog (replace with real file_picker later)
void _showFilePicker(
  BuildContext context,
  Map<String, String> fileTypes,
  _T t,
  Function(String name, String type) onPicked,
) {
  final sampleFiles = {
    'pdf': 'sample_document.pdf',
    'excel': 'data_sheet.xlsx',
    'ppt': 'presentation.pptx',
    'word': 'notes.docx',
  };

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
              'No file_picker package yet — select a simulated file type.',
              style: TextStyle(fontSize: 11, color: t.textMuted, height: 1.4),
            ),
            const SizedBox(height: 20),
            ...fileTypes.entries.map((e) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    onPicked(sampleFiles[e.key]!, e.key);
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
              );
            }),
          ],
        ),
      ),
    ),
  );
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final _T t;
  final ValueChanged<T?> onChanged;
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
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
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: t.surface,
        hint: Text(hint, style: TextStyle(fontSize: 13, color: t.textMuted)),
        style: TextStyle(fontSize: 13, color: t.text),
        icon: Icon(Icons.keyboard_arrow_down, size: 18, color: t.textMuted),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
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

class _DifficultyChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final _T t;
  final VoidCallback onTap;
  const _DifficultyChip({
    required this.label,
    required this.isSelected,
    required this.t,
    required this.onTap,
  });

  @override
  State<_DifficultyChip> createState() => _DifficultyChipState();
}

class _DifficultyChipState extends State<_DifficultyChip> {
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (widget.t.isDark ? Colors.white : Colors.black)
                : _hover
                ? widget.t.surface2
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? (widget.t.isDark ? Colors.white : Colors.black)
                  : widget.t.border2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? (widget.t.isDark ? Colors.black : Colors.white)
                  : widget.t.textSub,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final UploadState state;
  final _T t;
  final VoidCallback onTap;
  const _SubmitButton({
    required this.state,
    required this.t,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hover = false;
  bool get _isLoading => widget.state is UploadLoading;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 48,
          decoration: BoxDecoration(
            color: _isLoading
                ? widget.t.surface2
                : _hover
                ? (widget.t.isDark
                      ? const Color(0xFFDDDDDD)
                      : const Color(0xFF222222))
                : (widget.t.isDark ? Colors.white : Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.t.textMuted,
                    ),
                  )
                : Text(
                    'Upload Resource',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.t.isDark ? Colors.black : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Theme helper
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
}
