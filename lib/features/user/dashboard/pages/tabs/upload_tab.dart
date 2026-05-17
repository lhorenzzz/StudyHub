import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data'; 
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';

class UploadTab extends StatefulWidget {
  final UserTheme t;
  final DashboardLoaded state;
  const UploadTab({super.key, required this.t, required this.state});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _tagsCtrl  = TextEditingController();

  String _selectedCategoryId   = '';
  String _selectedCategoryName = '';
  String _selectedDifficulty   = '';

  // ── File state ─────────────────────────────────────────────────────────────
  String    _fileName  = '';
  String    _fileType  = '';
  Uint8List? _fileBytes;        // actual bytes for upload

  // ── Upload state ───────────────────────────────────────────────────────────
  bool   _isLoading  = false;
  bool   _isSuccess  = false;
  String _errorMsg   = '';
  double _progress   = 0.0;    // 0.0 → 1.0

  // Maps file extension → emoji label shown in UI
  static const _extEmoji = {
    'pdf'  : '📄',
    'xlsx' : '📊',
    'xls'  : '📊',
    'pptx' : '📑',
    'ppt'  : '📑',
    'docx' : '📝',
    'doc'  : '📝',
  };

  // Maps extension → fileType string stored in Firestore
  static String _extToFileType(String ext) {
    switch (ext.toLowerCase()) {
      case 'xlsx':
      case 'xls':
        return 'excel';
      case 'pptx':
      case 'ppt':
        return 'ppt';
      case 'docx':
      case 'doc':
        return 'word';
      default:
        return 'pdf';
    }
  }

  List<Map<String, String>> get _categories => widget.state.categories
      .map((c) => {'id': c.id, 'name': c.name, 'emoji': c.emoji})
      .toList();

  bool get _isValid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _fileBytes != null &&
      _selectedCategoryId.isNotEmpty &&
      _selectedDifficulty.isNotEmpty;

  // ── Pick file from device ──────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'xlsx', 'xls', 'pptx', 'ppt', 'docx', 'doc'],
      withData: true, // needed for web — loads bytes into memory
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final ext  = (file.extension ?? 'pdf').toLowerCase();

    setState(() {
      _fileBytes = file.bytes;
      _fileName  = file.name;
      _fileType  = _extToFileType(ext);
      _errorMsg  = '';
    });
  }

  void _clearFile() => setState(() {
    _fileBytes = null;
    _fileName  = '';
    _fileType  = '';
  });

  // ── Submit: Storage upload → Firestore write ───────────────────────────────
  Future<void> _submit() async {
  if (!_isValid) {
    setState(() => _errorMsg = 'Please fill in all required fields.');
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    setState(() => _errorMsg = 'You must be signed in to upload.');
    return;
  }

  setState(() { _isLoading = true; _errorMsg = ''; });

  try {
    // Save metadata only — no file stored
    await FirebaseFirestore.instance.collection('resources').add({
      'title'          : _titleCtrl.text.trim(),
      'description'    : _descCtrl.text.trim(),
      'categoryId'     : _selectedCategoryId,
      'categoryName'   : _selectedCategoryName,
      'fileType'       : _fileType,
      'difficulty'     : _selectedDifficulty.toLowerCase(),
      'tags'           : _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'uploadedBy'     : user.uid,
      'uploadedByName' : user.displayName ?? user.email?.split('@').first ?? 'Unknown', // ADD THIS
      'uploadedAt'     : FieldValue.serverTimestamp(),
      'fileName'       : _fileName,
      'fileUrl'        : '',
      'scope'          : 'global',
    });

    // Increment category resource count
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(_selectedCategoryId)
        .update({'resourceCount': FieldValue.increment(1)});

    if (mounted) {
      // Reload BLoC so My Resources tab reflects the new upload
      context.read<DashboardBloc>().add(DashboardStarted());
      setState(() { _isLoading = false; _isSuccess = true; });
    }

  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMsg  = 'Upload failed: ${e.toString()}';
      });
    }
  }
}

  void _reset() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _tagsCtrl.clear();
    setState(() {
      _selectedCategoryId   = '';
      _selectedCategoryName = '';
      _selectedDifficulty   = '';
      _fileBytes  = null;
      _fileName   = '';
      _fileType   = '';
      _isSuccess  = false;
      _errorMsg   = '';
      _progress   = 0.0;
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

              // ── Success screen ─────────────────────────────────────────────
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
                      HoverBtn(label: 'Upload Another', t: t, onTap: _reset),
                    ],
                  ),
                ),
              ] else ...[

                // ── Title ──────────────────────────────────────────────────────
                FieldLabel('Title', required: true, t: t),
                const SizedBox(height: 8),
                InputField(ctrl: _titleCtrl, hint: 'e.g. HTML Basics', t: t),
                const SizedBox(height: 20),

                // ── File picker ────────────────────────────────────────────────
                FieldLabel('File', required: true, t: t),
                const SizedBox(height: 8),
                _buildFilePicker(t),
                const SizedBox(height: 20),

                // ── Category ───────────────────────────────────────────────────
                FieldLabel('Category', required: true, t: t),
                const SizedBox(height: 8),
                _categories.isEmpty
                    ? Text(
                        'No categories available yet.',
                        style: TextStyle(fontSize: 13, color: t.textMuted),
                      )
                    : CategoryDropField(
                      hint: 'Select category',
                      value: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
                      items: _categories,
                      label: (c) => '${c['emoji']}  ${c['name']}',
                      t: t,
                      onChanged: (c) {
                        if (c != null && c.isNotEmpty) {
                          setState(() {
                            _selectedCategoryId   = c['id']!;
                            _selectedCategoryName = c['name']!;
                          });
                        }
                      },
                    ),
                const SizedBox(height: 20),

                // ── Difficulty ─────────────────────────────────────────────────
                FieldLabel('Difficulty', required: true, t: t),
                const SizedBox(height: 8),
                Row(
                  children: ['Beginner', 'Intermediate']
                      .map(
                        (d) => DifficultyChip(
                          label: d,
                          selected: _selectedDifficulty == d,
                          t: t,
                          onTap: () => setState(() => _selectedDifficulty = d),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),

                // ── Description ────────────────────────────────────────────────
                FieldLabel('Description', required: false, t: t),
                const SizedBox(height: 8),
                InputField(
                  ctrl: _descCtrl,
                  hint: 'Brief description of this resource...',
                  t: t,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── Tags ───────────────────────────────────────────────────────
                FieldLabel('Tags', required: false, t: t),
                const SizedBox(height: 8),
                InputField(
                  ctrl: _tagsCtrl,
                  hint: 'e.g. HTML, CSS, beginner',
                  t: t,
                ),
                const SizedBox(height: 28),

                // ── Upload progress bar ────────────────────────────────────────
                if (_isLoading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      backgroundColor: t.surface2,
                      color: t.text,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progress > 0
                        ? 'Uploading… ${(_progress * 100).toStringAsFixed(0)}%'
                        : 'Preparing upload…',
                    style: TextStyle(fontSize: 12, color: t.textMuted),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Error ──────────────────────────────────────────────────────
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
                        const Icon(Icons.error_outline,
                            size: 14, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMsg,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFFF6B6B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Submit button ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: SubmitBtn(
                    isLoading: _isLoading,
                    t: t,
                    onTap: _isLoading ? () {} : _submit,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── File picker widget ─────────────────────────────────────────────────────
  Widget _buildFilePicker(UserTheme t) {
    if (_fileBytes != null) {
      // File selected — show name + clear button
      final ext = _fileName.split('.').last.toLowerCase();
      final emoji = _extEmoji[ext] ?? '📄';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _fileName,
                style: TextStyle(fontSize: 13, color: t.text),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _clearFile,
                child: Icon(Icons.close, size: 16, color: t.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    // No file yet — show pick button
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.border2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.upload_file_outlined, size: 28, color: t.textMuted),
              const SizedBox(height: 8),
              Text(
                'Click to choose a file',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, Word, Excel, PowerPoint',
                style: TextStyle(fontSize: 11, color: t.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}