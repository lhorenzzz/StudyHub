part of 'dashboard_bloc.dart';

enum DashboardTab { all, starred, pinned, recent }

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ResourceModel> resources;
  final List<CategoryModel> categories;
  final DashboardTab activeTab;
  final bool isDarkMode;
  final String searchQuery;
  final ResourceModel? lastOpened;
  final String? selectedCategoryId; // null = show all categories

  const DashboardLoaded({
    required this.resources,
    required this.categories,
    required this.activeTab,
    required this.isDarkMode,
    this.searchQuery = '',
    this.lastOpened,
    this.selectedCategoryId,
  });

  // Filtered resources based on tab, category, and search
  List<ResourceModel> get filteredResources {
    List<ResourceModel> result = resources;

    // Filter by selected category
    if (selectedCategoryId != null) {
      result = result.where((r) => r.categoryId == selectedCategoryId).toList();
    }

    // Filter by active tab
    switch (activeTab) {
      case DashboardTab.starred:
        result = result.where((r) => r.isStarred).toList();
        break;
      case DashboardTab.pinned:
        result = result.where((r) => r.isPinned).toList();
        break;
      case DashboardTab.recent:
        result = result.where((r) => r.lastOpenedAt != null).toList()
          ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
        break;
      default:
        break;
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where(
            (r) =>
                r.title.toLowerCase().contains(q) ||
                r.categoryName.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  DashboardLoaded copyWith({
    List<ResourceModel>? resources,
    List<CategoryModel>? categories,
    DashboardTab? activeTab,
    bool? isDarkMode,
    String? searchQuery,
    ResourceModel? lastOpened,
    String? selectedCategoryId,
    bool clearCategory = false, // pass true to deselect category
  }) {
    return DashboardLoaded(
      resources: resources ?? this.resources,
      categories: categories ?? this.categories,
      activeTab: activeTab ?? this.activeTab,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      searchQuery: searchQuery ?? this.searchQuery,
      lastOpened: lastOpened ?? this.lastOpened,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props => [
    resources,
    categories,
    activeTab,
    isDarkMode,
    searchQuery,
    lastOpened,
    selectedCategoryId,
  ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
