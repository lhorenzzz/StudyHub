import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// shared_dialogs.dart
//
// Contains the two global modal functions used across the dashboard:
//   showResourceModal()     — view resource details, download, mark done
//   showAddCategoryModal()  — add a new category with emoji picker
// ─────────────────────────────────────────────────────────────────────────────

void showResourceModal(BuildContext context, ResourceModel r, UserTheme t) {
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
            // ── Header ──────────────────────────────────────────────────────
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

            // ── Details ─────────────────────────────────────────────────────
            ModalRow(label: 'File Type', value: r.typeLabel, t: t),
            ModalRow(label: 'Category', value: r.categoryName, t: t),
            ModalRow(label: 'Difficulty', value: r.difficultyLabel, t: t),
            ModalRow(
              label: 'Uploaded',
              value:
                  '${r.uploadedAt.day}/${r.uploadedAt.month}/${r.uploadedAt.year}',
              t: t,
            ),
            ModalRow(
              label: 'Status',
              value: r.isDone ? '✓ Done' : 'Not done',
              t: t,
            ),

            const SizedBox(height: 24),

            // ── Actions ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ModalBtn(
                    label: '↓  Download',
                    primary: true,
                    t: t,
                    onTap: () {
                      Navigator.pop(context);

                      // ── TODO (Backend Team) ──────────────────────────────
                      // Replace this snackbar with real file download logic:
                      //
                      //   final url = r.fileUrl; // from Firestore field
                      //   if (url != null && url.isNotEmpty) {
                      //     // Option A — open in browser (easiest):
                      //     await launchUrl(Uri.parse(url));
                      //
                      //     // Option B — download with Dio:
                      //     final dio = Dio();
                      //     final dir = await getTemporaryDirectory();
                      //     await dio.download(url, '${dir.path}/${r.title}');
                      //     OpenFile.open('${dir.path}/${r.title}');
                      //   }
                      // ────────────────────────────────────────────────────
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: t.surface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: t.border),
                          ),
                          content: Text(
                            'Download ready once backend is connected.',
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
                    child: ModalBtn(
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

// ─────────────────────────────────────────────────────────────────────────────

void showAddCategoryModal(BuildContext context, UserTheme t) {
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
              // ── Header ────────────────────────────────────────────────────
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

              // ── Emoji picker ──────────────────────────────────────────────
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

              // ── Name field ────────────────────────────────────────────────
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

              // ── Submit ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ModalBtn(
                  label: 'Add Category',
                  primary: true,
                  t: t,
                  onTap: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;

                    // ── TODO (Backend Team) ──────────────────────────────
                    // The BLoC currently writes to local state only.
                    // When Firestore is connected, _onCategoryAdded in
                    // dashboard_bloc.dart will also write to:
                    //   /categories/{id}
                    // So no changes needed here — just connect the BLoC.
                    // ────────────────────────────────────────────────────
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
