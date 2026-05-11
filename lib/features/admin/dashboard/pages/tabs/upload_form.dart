import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import '../../widgets/theme_helper.dart';
import '../../widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN UPLOAD FORM
// ─────────────────────────────────────────────────────────────────────────────
class AdminUploadForm extends StatefulWidget {
  final AdminTheme t;
  final String? preselectedCategoryId;
  final ResourceScope defaultScope;
  final List<CategoryModel> categories;
  final bool isLoading;
  final Function(Map<String, String>) onSubmit;

  const AdminUploadForm({
    super.key,
    required this.t,
    this.preselectedCategoryId,
    required this.categories,
    required this.isLoading,
    required this.onSubmit,
    required this.defaultScope,
  });

  @override
  State<AdminUploadForm> createState() => _AdminUploadFormState();
}

class _AdminUploadFormState extends State<AdminUploadForm> {
  final AdminThemeitleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final AdminThemeagsCtrl = TextEditingController();

  String _categoryId = '';
  String _difficulty = '';
  late ResourceScope _scope;
  String _errorMsg = '';

  String? _pickedFileName;
  String? _pickedFilePath;
  String? _pickedFileType;
  int? _pickedFileBytes;
  bool _isPicking = false;

  static const _extToType = {
    'pdf': 'pdf',
    'doc': 'word',
    'docx': 'word',
    'ppt': 'ppt',
    'pptx': 'ppt',
    'xls': 'excel',
    'xlsx': 'excel',
  };

  static const _typeEmoji = {
    'pdf': '📄',
    'word': '📝',
    'ppt': '📑',
    'excel': '📊',
  };

  @override
  void initState() {
    super.initState();
    _scope = widget.defaultScope;
    if (widget.preselectedCategoryId != null) {
      _categoryId = widget.preselectedCategoryId!;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
        withData: true,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = (file.extension ?? '').toLowerCase();
        final type = _extToType[ext];

        if (type == null) {
          setState(() => _errorMsg = 'Unsupported file type: .$ext');
        } else {
          setState(() {
            _pickedFileName = file.name;
            _pickedFilePath = file.path;
            _pickedFileType = type;
            _pickedFileBytes = file.size;
            _errorMsg = '';

            if (AdminThemeitleCtrl.text.trim().isEmpty) {
              final nameNoExt = file.name.contains('.')
                  ? file.name.substring(0, file.name.lastIndexOf('.'))
                  : file.name;
              titleCtrl.text = nameNoExt
                  .replaceAll('_', ' ')
                  .replaceAll('-', ' ');
            }
          });
        }
      }
    } catch (e) {
      setState(() => _errorMsg = 'Could not open file picker: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _submit() {
    setState(() => _errorMsg = '');

    if (AdminThemeitleCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Please enter a title.');
      return;
    }
    if (_pickedFileName == null) {
      setState(() => _errorMsg = 'Please select a file.');
      return;
    }
    if (_categoryId.isEmpty) {
      setState(() => _errorMsg = 'Please select a category.');
      return;
    }
    if (_difficulty.isEmpty) {
      setState(() => _errorMsg = 'Please select a difficulty.');
      return;
    }

    widget.onSubmit({
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'categoryId': _categoryId,
      'difficulty': _difficulty,
      'tags': tagsCtrl.text.trim(),
      'fileName': _pickedFileName!,
      'fileType': _pickedFileType!,
      'filePath': _pickedFilePath ?? '',
      'scope': _scope == ResourceScope.private ? 'private' : 'global',
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Resource',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
          ),
          const SizedBox(height: 20),

          // File picker
          AdminLabel('File', required: true, t: t),
          const SizedBox(height: 8),
          _FilePicker(
            t: t,
            isPicking: _isPicking,
            fileName: _pickedFileName,
            fileType: _pickedFileType,
            fileBytes: _pickedFileBytes,
            onPick: _pickFile,
            onClear: () => setState(() {
              _pickedFileName = null;
              _pickedFilePath = null;
              _pickedFileType = null;
              _pickedFileBytes = null;
            }),
            typeEmoji: _typeEmoji,
          ),
          const SizedBox(height: 16),

          // Visibility
          AdminLabel('Visibility', required: true, t: t),
          const SizedBox(height: 8),
          Row(
            children: [
              AdminChip(
                label: '🔒  Private',
                selected: _scope == ResourceScope.private,
                t: t,
                onTap: () => setState(() => _scope = ResourceScope.private),
              ),
              AdminChip(
                label: '🌐  Global',
                selected: _scope == ResourceScope.global,
                t: t,
                onTap: () => setState(() => _scope = ResourceScope.global),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _scope == ResourceScope.private
                ? 'Only visible to you in My Resources.'
                : 'Visible to all users in Global Resources.',
            style: TextStyle(fontSize: 11, color: t.textMuted),
          ),
          const SizedBox(height: 16),

          // Title
          AdminLabel('Title', required: true, t: t),
          const SizedBox(height: 8),
          AdminField(ctrl: titleCtrl, hint: 'e.g. HTML Basics', t: t),
          const SizedBox(height: 16),

          // Category + Difficulty
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminLabel('Category', required: true, t: t),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: t.surface2,
                        border: Border.all(color: t.border2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _categoryId.isEmpty ? null : _categoryId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: t.surface,
                        hint: Text(
                          'Select category',
                          style: TextStyle(fontSize: 13, color: t.textMuted),
                        ),
                        style: TextStyle(fontSize: 13, color: t.text),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: t.textMuted,
                        ),
                        items: widget.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  '${c.emoji}  ${c.name}',
                                  style: TextStyle(fontSize: 13, color: t.text),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminLabel('Difficulty', required: true, t: t),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Beginner', 'Intermediate']
                          .map(
                            (d) => AdminChip(
                              label: d,
                              selected: _difficulty == d.toLowerCase(),
                              t: t,
                              onTap: () =>
                                  setState(() => _difficulty = d.toLowerCase()),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          AdminLabel('Description', required: false, t: t),
          const SizedBox(height: 8),
          AdminField(
            ctrl: descCtrl,
            hint: 'Brief description of this resource...',
            t: t,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Tags
          AdminLabel('Tags', required: false, t: t),
          const SizedBox(height: 8),
          AdminField(ctrl: tagsCtrl, hint: 'e.g. HTML, CSS, beginner', t: t),

          // Error
          if (_errorMsg.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1010),
                border: Border.all(color: const Color(0xFF4A2020)),
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
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AdminSubmitBtn(
              isLoading: widget.isLoading,
              t: t,
              label: 'Upload Resource',
              onTap: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FILE PICKER WIDGET ───────────────────────────────────────────────────────
class _FilePicker extends StatelessWidget {
  final AdminTheme t;
  final bool isPicking;
  final String? fileName;
  final String? fileType;
  final int? fileBytes;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final Map<String, String> typeEmoji;

  const _FilePicker({
    required this.t,
    required this.isPicking,
    required this.fileName,
    required this.fileType,
    required this.fileBytes,
    required this.onPick,
    required this.onClear,
    required this.typeEmoji,
  });

  String _fmt(int b) {
    if (b < 1024) return '${b}B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)}KB';
    return '${(b / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    if (fileName != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface2,
          border: Border.all(color: t.border2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              typeEmoji[fileType] ?? '📄',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (fileBytes != null)
                    Text(
                      _fmt(fileBytes!),
                      style: TextStyle(fontSize: 11, color: t.textMuted),
                    ),
                ],
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 16, color: t.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isPicking ? null : onPick,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: t.surface2,
            border: Border.all(color: t.border2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isPicking
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: t.textMuted,
                    ),
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        size: 28,
                        color: t.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to select a file',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: t.textSub,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, Word, PowerPoint, Excel',
                        style: TextStyle(fontSize: 11, color: t.textMuted),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
