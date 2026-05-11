import 'package:flutter/material.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/resource_widgets.dart';

class MyResourcesTab extends StatelessWidget {
  final DashboardLoaded state;
  final UserTheme t;
  const MyResourcesTab({super.key, required this.state, required this.t});

  @override
  Widget build(BuildContext context) {
    // ── TODO (Backend Team) ───────────────────────────────────────────────────
    // Replace this empty list with real uid filter when Firebase is ready:
    //
    //   import 'package:firebase_auth/firebase_auth.dart';
    //
    //   final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    //   final myResources = state.resources
    //       .where((r) => r.uploadedBy == uid)
    //       .toList();
    //
    // Resources are already in state (loaded from Firestore via BLoC) —
    // just change the filter condition above and remove the empty list below.
    // ─────────────────────────────────────────────────────────────────────────
    // Filters to only private-scope resources (the user's own uploads)
    // TODO (Firebase): change scope filter to uploadedBy == currentUser.uid
    // once Firebase Auth is wired:
    //   final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    //   final myResources = state.resources.where((r) => r.uploadedBy == uid).toList();
    final myResources = state.resources
        .where((r) => r.scope == ResourceScope.private)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'My Resources',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: t.text,
                ),
              ),
              const Spacer(),
              Text(
                '${myResources.length} uploaded',
                style: TextStyle(fontSize: 13, color: t.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Resources you have uploaded.',
            style: TextStyle(fontSize: 13, color: t.textSub),
          ),
          const SizedBox(height: 28),

          // ── Empty state ────────────────────────────────────────────────────
          if (myResources.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 48,
                      color: t.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You haven't uploaded anything yet.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: t.textSub,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Go to Upload to share resources.',
                      style: TextStyle(fontSize: 13, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            // ── Resource grid ───────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 700 ? 2 : 1;
                final cardW =
                    (constraints.maxWidth - (cols == 2 ? 10 : 0)) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: myResources
                      .map(
                        (r) => MyResourceCard(resource: r, width: cardW, t: t),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
