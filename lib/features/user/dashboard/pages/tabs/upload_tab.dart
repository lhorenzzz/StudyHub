import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';

class UploadTab extends StatefulWidget {
  final UserTheme t;
  final DashboardLoaded state; // ← added
  const UploadTab({super.key, required this.t, required this.state});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
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

  final _fileTypes = {'pdf': '📄', 'excel': '📊', 'ppt': '📑', 'word': '📝'};

  // ── Pull categories from BLoC state ────────────────────────────────────────
  // ── TODO (Backend Team): these will auto-update once Firestore is connected
  List<Map<String, String>> get _categories => widget.state.categories
      .map((c) => {'id': c.id, 'name': c.name, 'emoji': c.emoji})
      .toList();

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

    // ── TODO (Backend Team) ───────────────────────────────────────────────────
    // Replace this delay with real upload flow:
    //
    // STEP 1 — Pick real file bytes (file_picker package):
    //   FilePickerResult? result = await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //     allowedExtensions: ['pdf', 'xlsx', 'pptx', 'docx'],
    //     withData: true,
    //   );
    //   if (result == null) return;
    //   final file = result.files.single;
    //   _fileBytes = file.bytes;
    //   _fileName = file.name;
    //
    // STEP 2 — Upload to Firebase Storage:
    //   final uid = FirebaseAuth.instance.currentUser!.uid;
    //   final ref = FirebaseStorage.instance
    //       .ref('uploads/$uid/${DateTime.now().millisecondsSinceEpoch}_$_fileName');
    //   final task = ref.putData(_fileBytes!);
    //   task.snapshotEvents.listen((s) => setState(() =>
    //       _uploadProgress = s.bytesTransferred / s.totalBytes));
    //   final snapshot = await task.whenComplete(() {});
    //   final fileUrl = await snapshot.ref.getDownloadURL();
    //
    // STEP 3 — Write to Firestore:
    //   await FirebaseFirestore.instance.collection('resources').add({
    //     'title': _titleCtrl.text.trim(),
    //     'categoryId': _selectedCategoryId,
    //     'categoryName': _selectedCategoryName,
    //     'fileType': _fileType,
    //     'difficulty': _selectedDifficulty.toLowerCase(),
    //     'description': _descCtrl.text.trim(),
    //     'tags': _tagsCtrl.text.split(',').map((t) => t.trim()).toList(),
    //     'uploadedBy': uid,
    //     'uploadedAt': FieldValue.serverTimestamp(),
    //     'fileUrl': fileUrl,
    //     'isGlobal': false,
    //   });
    // ─────────────────────────────────────────────────────────────────────────
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
                      HoverBtn(label: 'Upload Another', t: t, onTap: _reset),
                    ],
                  ),
                ),
              ] else ...[
                FieldLabel('Title', required: true, t: t),
                const SizedBox(height: 8),
                InputField(ctrl: _titleCtrl, hint: 'e.g. HTML Basics', t: t),
                const SizedBox(height: 20),

                FieldLabel('File', required: true, t: t),
                const SizedBox(height: 8),
                FilePickerBox(
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

                FieldLabel('Category', required: true, t: t),
                const SizedBox(height: 8),
                // ── Shows empty if no categories loaded yet ─────────────────
                _categories.isEmpty
                    ? Text(
                        'No categories available yet.',
                        style: TextStyle(fontSize: 13, color: t.textMuted),
                      )
                    : CategoryDropField(
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
                          if (c != null && c.isNotEmpty) {
                            setState(() {
                              _selectedCategoryId = c['id']!;
                              _selectedCategoryName = c['name']!;
                            });
                          }
                        },
                      ),
                const SizedBox(height: 20),

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

                FieldLabel('Description', required: false, t: t),
                const SizedBox(height: 8),
                InputField(
                  ctrl: _descCtrl,
                  hint: 'Brief description of this resource...',
                  t: t,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                FieldLabel('Tags', required: false, t: t),
                const SizedBox(height: 8),
                InputField(
                  ctrl: _tagsCtrl,
                  hint: 'e.g. HTML, CSS, beginner',
                  t: t,
                ),
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
                  child: SubmitBtn(isLoading: _isLoading, t: t, onTap: _submit),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
