import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardLoading()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardTabChanged>(_onTabChanged);
    on<ResourceStarToggled>(_onStarToggled);
    on<ResourcePinToggled>(_onPinToggled);
    on<ResourceMarkedDone>(_onMarkedDone);
    on<ResourceOpened>(_onResourceOpened);
    on<ThemeToggled>(_onThemeToggled);
    on<DashboardSearchChanged>(_onSearchChanged);
    on<CategorySelected>(_onCategorySelected);
    on<CategoryAdded>(_onCategoryAdded);
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final categories = [
      const CategoryModel(
        id: 'it',
        name: 'Information Technology',
        emoji: '💻',
        description: 'Networking, OS, security basics',
        resourceCount: 12,
      ),
      const CategoryModel(
        id: 'science',
        name: 'Science',
        emoji: '🧪',
        description: 'Physics, chemistry, biology',
        resourceCount: 8,
      ),
      const CategoryModel(
        id: 'cookery',
        name: 'Cookery',
        emoji: '🍳',
        description: 'Recipes, techniques, nutrition',
        resourceCount: 5,
      ),
    ];

    final resources = [
      ResourceModel(
        id: '1',
        title: 'HTML Basics — Structure & Tags',
        categoryId: 'it',
        categoryName: 'Information Technology',
        type: ResourceType.article,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
        isStarred: true,
        lastOpenedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ResourceModel(
        id: '2',
        title: 'CSS Cheat Sheet',
        categoryId: 'it',
        categoryName: 'Information Technology',
        type: ResourceType.pdf,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ResourceModel(
        id: '3',
        title: 'Python Variables & Data Types',
        categoryId: 'it',
        categoryName: 'Information Technology',
        type: ResourceType.article,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 7)),
        isPinned: true,
      ),
      ResourceModel(
        id: '4',
        title: 'OSI Model Reference Sheet',
        categoryId: 'it',
        categoryName: 'Information Technology',
        type: ResourceType.pdf,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
        isStarred: true,
      ),
      ResourceModel(
        id: '5',
        title: 'Basic Chemistry Notes',
        categoryId: 'science',
        categoryName: 'Science',
        type: ResourceType.word,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ResourceModel(
        id: '6',
        title: 'Knife Skills & Cutting Techniques',
        categoryId: 'cookery',
        categoryName: 'Cookery',
        type: ResourceType.ppt,
        difficulty: DifficultyLevel.beginner,
        uploadedBy: 'admin',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        lastOpenedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];

    final opened = resources.where((r) => r.lastOpenedAt != null).toList()
      ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));

    emit(
      DashboardLoaded(
        resources: resources,
        categories: categories,
        activeTab: DashboardTab.all,
        isDarkMode: true,
        lastOpened: opened.isNotEmpty ? opened.first : null,
      ),
    );
  }

  void _onTabChanged(DashboardTabChanged event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(activeTab: event.tab));
    }
  }

  void _onStarToggled(ResourceStarToggled event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      emit(
        cur.copyWith(
          resources: cur.resources
              .map(
                (r) => r.id == event.resourceId
                    ? r.copyWith(isStarred: !r.isStarred)
                    : r,
              )
              .toList(),
        ),
      );
    }
  }

  void _onPinToggled(ResourcePinToggled event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      emit(
        cur.copyWith(
          resources: cur.resources
              .map(
                (r) => r.id == event.resourceId
                    ? r.copyWith(isPinned: !r.isPinned)
                    : r,
              )
              .toList(),
        ),
      );
    }
  }

  void _onMarkedDone(ResourceMarkedDone event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      emit(
        cur.copyWith(
          resources: cur.resources
              .map(
                (r) => r.id == event.resourceId ? r.copyWith(isDone: true) : r,
              )
              .toList(),
        ),
      );
    }
  }

  void _onResourceOpened(ResourceOpened event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      ResourceModel? opened;
      final updated = cur.resources.map((r) {
        if (r.id == event.resourceId) {
          final u = r.copyWith(lastOpenedAt: DateTime.now());
          opened = u;
          return u;
        }
        return r;
      }).toList();
      emit(cur.copyWith(resources: updated, lastOpened: opened));
    }
  }

  void _onThemeToggled(ThemeToggled event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      emit(cur.copyWith(isDarkMode: !cur.isDarkMode));
    }
  }

  void _onSearchChanged(
    DashboardSearchChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(searchQuery: event.query));
    }
  }

  // Toggle category filter — click same category again to deselect
  void _onCategorySelected(
    CategorySelected event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      final isSame = cur.selectedCategoryId == event.categoryId;
      if (isSame) {
        // Deselect — show all
        emit(cur.copyWith(clearCategory: true));
      } else {
        emit(cur.copyWith(selectedCategoryId: event.categoryId));
      }
    }
  }

  // Add new category to the list
  void _onCategoryAdded(CategoryAdded event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      final newCategory = CategoryModel(
        id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
        name: event.name,
        emoji: event.emoji,
        description: '',
        resourceCount: 0,
        isCustom: true,
      );
      emit(cur.copyWith(categories: [...cur.categories, newCategory]));
    }
  }
}
