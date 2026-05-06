import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/admin/repository/admin_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────────────────────────────
abstract class AdminEvent {}

// Initial load
class AdminStarted extends AdminEvent {}

// Theme
class AdminThemeToggled extends AdminEvent {}

// Tab navigation
class AdminTabChanged extends AdminEvent {
  final AdminTab tab;
  AdminTabChanged(this.tab);
}

// Resources
class AdminResourceSearchChanged extends AdminEvent {
  final String query;
  AdminResourceSearchChanged(this.query);
}

class AdminResourceFilterChanged extends AdminEvent {
  final String categoryId;
  final String difficulty;
  AdminResourceFilterChanged({this.categoryId = '', this.difficulty = ''});
}

class AdminResourceDeleteRequested extends AdminEvent {
  final String id;
  AdminResourceDeleteRequested(this.id);
}

class AdminResourceUploadSubmitted extends AdminEvent {
  final String title;
  final String description;
  final String categoryId;
  final String difficulty;
  final String tags;
  final String fileName;
  final String fileType;
  AdminResourceUploadSubmitted({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.difficulty,
    required this.tags,
    required this.fileName,
    required this.fileType,
  });
}

// Users
class AdminUserSearchChanged extends AdminEvent {
  final String query;
  AdminUserSearchChanged(this.query);
}

class AdminUserDeleteRequested extends AdminEvent {
  final String id;
  AdminUserDeleteRequested(this.id);
}

// Categories
class AdminCategoryAddRequested extends AdminEvent {
  final String name;
  final String description;
  final String emoji;
  AdminCategoryAddRequested({
    required this.name,
    required this.description,
    required this.emoji,
  });
}

class AdminCategoryEditRequested extends AdminEvent {
  final String id;
  final String name;
  final String description;
  final String emoji;
  AdminCategoryEditRequested({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

class AdminCategoryDeleteRequested extends AdminEvent {
  final String id;
  AdminCategoryDeleteRequested(this.id);
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB ENUM
// ─────────────────────────────────────────────────────────────────────────────
enum AdminTab { overview, resources, users, categories }

// ─────────────────────────────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────────────────────────────
abstract class AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final bool isDarkMode;
  final AdminTab activeTab;

  // Stats
  final int totalResources;
  final int totalUsers;
  final int totalCategories;

  // Resources
  final List<ResourceModel> resources;
  final List<ResourceModel> filteredResources;
  final String resourceSearch;
  final String resourceCategoryFilter;
  final String resourceDifficultyFilter;

  // Users
  final List<AdminUser> users;
  final List<AdminUser> filteredUsers;
  final String userSearch;

  // Categories
  final List<CategoryModel> categories;

  // Feedback
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  AdminLoaded({
    required this.isDarkMode,
    required this.activeTab,
    required this.totalResources,
    required this.totalUsers,
    required this.totalCategories,
    required this.resources,
    required this.filteredResources,
    required this.resourceSearch,
    required this.resourceCategoryFilter,
    required this.resourceDifficultyFilter,
    required this.users,
    required this.filteredUsers,
    required this.userSearch,
    required this.categories,
    this.isActionLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  AdminLoaded copyWith({
    bool? isDarkMode,
    AdminTab? activeTab,
    int? totalResources,
    int? totalUsers,
    int? totalCategories,
    List<ResourceModel>? resources,
    List<ResourceModel>? filteredResources,
    String? resourceSearch,
    String? resourceCategoryFilter,
    String? resourceDifficultyFilter,
    List<AdminUser>? users,
    List<AdminUser>? filteredUsers,
    String? userSearch,
    List<CategoryModel>? categories,
    bool? isActionLoading,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return AdminLoaded(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      activeTab: activeTab ?? this.activeTab,
      totalResources: totalResources ?? this.totalResources,
      totalUsers: totalUsers ?? this.totalUsers,
      totalCategories: totalCategories ?? this.totalCategories,
      resources: resources ?? this.resources,
      filteredResources: filteredResources ?? this.filteredResources,
      resourceSearch: resourceSearch ?? this.resourceSearch,
      resourceCategoryFilter:
          resourceCategoryFilter ?? this.resourceCategoryFilter,
      resourceDifficultyFilter:
          resourceDifficultyFilter ?? this.resourceDifficultyFilter,
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      userSearch: userSearch ?? this.userSearch,
      categories: categories ?? this.categories,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────────────────────────────
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final _repo = AdminRepository.instance;

  AdminBloc() : super(AdminLoading()) {
    on<AdminStarted>(_onStarted);
    on<AdminThemeToggled>(_onThemeToggled);
    on<AdminTabChanged>(_onTabChanged);
    on<AdminResourceSearchChanged>(_onResourceSearchChanged);
    on<AdminResourceFilterChanged>(_onResourceFilterChanged);
    on<AdminResourceDeleteRequested>(_onResourceDeleteRequested);
    on<AdminResourceUploadSubmitted>(_onResourceUploadSubmitted);
    on<AdminUserSearchChanged>(_onUserSearchChanged);
    on<AdminUserDeleteRequested>(_onUserDeleteRequested);
    on<AdminCategoryAddRequested>(_onCategoryAddRequested);
    on<AdminCategoryEditRequested>(_onCategoryEditRequested);
    on<AdminCategoryDeleteRequested>(_onCategoryDeleteRequested);
  }

  // ── Load all data on start ──────────────────────────────────────────────
  Future<void> _onStarted(AdminStarted e, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        _repo.getStats(),
        _repo.getResources(),
        _repo.getUsers(),
        _repo.getCategories(),
      ]);

      final stats = results[0] as AdminStats;
      final resources = results[1] as List<ResourceModel>;
      final users = results[2] as List<AdminUser>;
      final categories = results[3] as List<CategoryModel>;

      emit(
        AdminLoaded(
          isDarkMode: true,
          activeTab: AdminTab.overview,
          totalResources: stats.totalResources,
          totalUsers: stats.totalUsers,
          totalCategories: stats.totalCategories,
          resources: resources,
          filteredResources: resources,
          resourceSearch: '',
          resourceCategoryFilter: '',
          resourceDifficultyFilter: '',
          users: users,
          filteredUsers: users,
          userSearch: '',
          categories: categories,
        ),
      );
    } catch (err) {
      emit(AdminError(err.toString()));
    }
  }

  // ── Theme ───────────────────────────────────────────────────────────────
  void _onThemeToggled(AdminThemeToggled e, Emitter<AdminState> emit) {
    if (state is AdminLoaded) {
      final s = state as AdminLoaded;
      emit(s.copyWith(isDarkMode: !s.isDarkMode));
    }
  }

  // ── Tab change ──────────────────────────────────────────────────────────
  void _onTabChanged(AdminTabChanged e, Emitter<AdminState> emit) {
    if (state is AdminLoaded) {
      emit((state as AdminLoaded).copyWith(activeTab: e.tab));
    }
  }

  // ── Resource search ─────────────────────────────────────────────────────
  void _onResourceSearchChanged(
    AdminResourceSearchChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(
      s.copyWith(
        resourceSearch: e.query,
        filteredResources: _filterResources(
          s.resources,
          search: e.query,
          categoryId: s.resourceCategoryFilter,
          difficulty: s.resourceDifficultyFilter,
        ),
      ),
    );
  }

  // ── Resource filter ─────────────────────────────────────────────────────
  void _onResourceFilterChanged(
    AdminResourceFilterChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(
      s.copyWith(
        resourceCategoryFilter: e.categoryId,
        resourceDifficultyFilter: e.difficulty,
        filteredResources: _filterResources(
          s.resources,
          search: s.resourceSearch,
          categoryId: e.categoryId,
          difficulty: e.difficulty,
        ),
      ),
    );
  }

  List<ResourceModel> _filterResources(
    List<ResourceModel> all, {
    String search = '',
    String categoryId = '',
    String difficulty = '',
  }) {
    return all.where((r) {
      final ms =
          search.isEmpty ||
          r.title.toLowerCase().contains(search.toLowerCase());
      final mc = categoryId.isEmpty || r.categoryId == categoryId;
      final md = difficulty.isEmpty || r.difficulty == difficulty;
      return ms && mc && md;
    }).toList();
  }

  // ── Delete resource ─────────────────────────────────────────────────────
  Future<void> _onResourceDeleteRequested(
    AdminResourceDeleteRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.deleteResource(e.id);
      final updated = s.resources.where((r) => r.id != e.id).toList();
      emit(
        s.copyWith(
          isActionLoading: false,
          resources: updated,
          filteredResources: _filterResources(
            updated,
            search: s.resourceSearch,
            categoryId: s.resourceCategoryFilter,
            difficulty: s.resourceDifficultyFilter,
          ),
          totalResources: s.totalResources - 1,
          successMessage: 'Resource deleted.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to delete resource.',
        ),
      );
    }
  }

  // ── Upload resource ─────────────────────────────────────────────────────
  Future<void> _onResourceUploadSubmitted(
    AdminResourceUploadSubmitted e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.uploadResource(
        title: e.title,
        description: e.description,
        categoryId: e.categoryId,
        difficulty: e.difficulty,
        tags: e.tags,
        fileName: e.fileName,
        fileType: e.fileType,
      );
      // Refresh resources list
      final updated = await _repo.getResources();
      emit(
        s.copyWith(
          isActionLoading: false,
          resources: updated,
          filteredResources: updated,
          totalResources: s.totalResources + 1,
          successMessage: '"${e.title}" uploaded successfully.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to upload resource.',
        ),
      );
    }
  }

  // ── User search ─────────────────────────────────────────────────────────
  void _onUserSearchChanged(
    AdminUserSearchChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    final filtered = e.query.isEmpty
        ? s.users
        : s.users
              .where(
                (u) =>
                    u.name.toLowerCase().contains(e.query.toLowerCase()) ||
                    u.email.toLowerCase().contains(e.query.toLowerCase()),
              )
              .toList();
    emit(s.copyWith(userSearch: e.query, filteredUsers: filtered));
  }

  // ── Delete user ─────────────────────────────────────────────────────────
  Future<void> _onUserDeleteRequested(
    AdminUserDeleteRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.deleteUser(e.id);
      final updated = s.users.where((u) => u.id != e.id).toList();
      emit(
        s.copyWith(
          isActionLoading: false,
          users: updated,
          filteredUsers: updated,
          totalUsers: s.totalUsers - 1,
          successMessage: 'User deleted.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to delete user.',
        ),
      );
    }
  }

  // ── Add category ────────────────────────────────────────────────────────
  Future<void> _onCategoryAddRequested(
    AdminCategoryAddRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.addCategory(
        name: e.name,
        description: e.description,
        emoji: e.emoji,
      );
      final updated = await _repo.getCategories();
      emit(
        s.copyWith(
          isActionLoading: false,
          categories: updated,
          totalCategories: s.totalCategories + 1,
          successMessage: '"${e.name}" category added.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to add category.',
        ),
      );
    }
  }

  // ── Edit category ───────────────────────────────────────────────────────
  Future<void> _onCategoryEditRequested(
    AdminCategoryEditRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.editCategory(
        id: e.id,
        name: e.name,
        description: e.description,
        emoji: e.emoji,
      );
      final updated = await _repo.getCategories();
      emit(
        s.copyWith(
          isActionLoading: false,
          categories: updated,
          successMessage: 'Category updated.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to update category.',
        ),
      );
    }
  }

  // ── Delete category ─────────────────────────────────────────────────────
  Future<void> _onCategoryDeleteRequested(
    AdminCategoryDeleteRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.deleteCategory(e.id);
      final updated = s.categories.where((c) => c.id != e.id).toList();
      emit(
        s.copyWith(
          isActionLoading: false,
          categories: updated,
          totalCategories: s.totalCategories - 1,
          successMessage: 'Category deleted.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to delete category.',
        ),
      );
    }
  }
}
