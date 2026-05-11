import 'package:flutter/material.dart';
import 'package:study_hub/features/user/dashboard/BLoC/dashboard_bloc.dart';
import 'package:study_hub/features/user/dashboard/widgets/theme_helper.dart';
import 'package:study_hub/features/user/dashboard/widgets/shared_widgets.dart';
import 'package:study_hub/features/user/dashboard/widgets/category_widgets.dart';
import 'package:study_hub/features/user/dashboard/widgets/resource_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// browse_tab.dart
//
// The "Browse" tab (index 0) — shows:
//   • Last opened resource banner
//   • Quick filter tabs (All / Starred / Pinned / Recent)
//   • Categories grid
//   • Resources grid (filtered by tab + category + search)
// ─────────────────────────────────────────────────────────────────────────────

class BrowseTab extends StatelessWidget {
  final DashboardLoaded state;
  final UserTheme t;
  const BrowseTab({super.key, required this.state, required this.t});

  String _sectionTitle(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.starred:
        return 'Starred';
      case DashboardTab.pinned:
        return 'Pinned';
      case DashboardTab.recent:
        return 'Recently Opened';
      default:
        return 'All Resources';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Last opened banner ─────────────────────────────────────────────
          if (state.lastOpened != null) ...[
            LastOpenedBar(resource: state.lastOpened!, t: t),
            const SizedBox(height: 24),
          ],

          // ── Filter tabs ───────────────────────────────────────────────────
          QuickTabs(activeTab: state.activeTab, t: t),
          const SizedBox(height: 24),

          // ── Categories ────────────────────────────────────────────────────
          SectionHeader(title: 'Categories', t: t),
          const SizedBox(height: 12),
          CategoriesGrid(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            t: t,
          ),
          const SizedBox(height: 28),

          // ── Resources ─────────────────────────────────────────────────────
          SectionHeader(title: _sectionTitle(state.activeTab), t: t),
          const SizedBox(height: 12),
          ResourcesGrid(resources: state.filteredResources, t: t),
        ],
      ),
    );
  }
}
