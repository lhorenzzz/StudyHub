import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/core/models/admin_user.dart';
import 'package:study_hub/features/admin/repository/admin_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAB ENUM
// ─────────────────────────────────────────────────────────────────────────────
enum AdminTab {
  overview,
  globalResources,
  userUploads,
  users,
  myResources,
  profile,
}

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

// ── Resource events ───────────────────────────────────────────────────────────

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

// In admin_bloc.dart, add this event:
class AdminResourceSavedToMyResources extends AdminEvent {
  final String resourceId;
  AdminResourceSavedToMyResources({required this.resourceId});
}

class AdminResourceUploadSubmitted extends AdminEvent {
  final String title;
  final String description;
  final String categoryId;
  final String difficulty;
  final String tags;
  final String fileName;
  final String fileType;
  final String scope; // NEW — 'private' | 'global'
  // 🔥 FIREBASE: add filePath for Storage upload
  // final String filePath;

  AdminResourceUploadSubmitted({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.difficulty,
    required this.tags,
    required this.fileName,
    required this.fileType,
    this.scope = 'global', // default global
    // required this.filePath,
  });
}

// Changes a resource's scope between 'private' and 'global'
// 🔥 FIREBASE: handler calls Firestore update — see _onResourceScopeChanged
class AdminResourceScopeChanged extends AdminEvent {
  final String id;
  final String scope; // 'private' | 'global'
  AdminResourceScopeChanged({required this.id, required this.scope});
}

// ── User events ───────────────────────────────────────────────────────────────

class AdminUserSearchChanged extends AdminEvent {
  final String query;
  AdminUserSearchChanged(this.query);
}

class AdminUserDeleteRequested extends AdminEvent {
  final String id;
  AdminUserDeleteRequested(this.id);
}

// ── NEW: user moderation events ───────────────────────────────────────────
// ── NEW: user moderation events ───────────────────────────────────────────
class AdminUserBanRequested extends AdminEvent {
  final String userId;
  AdminUserBanRequested(this.userId);
}

class AdminUserSuspendRequested extends AdminEvent {
  final String userId;
  AdminUserSuspendRequested(this.userId);
}

class AdminUserUnbanRequested extends AdminEvent {
  final String userId;
  AdminUserUnbanRequested(this.userId);
}

class AdminUserRoleFilterChanged extends AdminEvent {
  final String role;
  AdminUserRoleFilterChanged(this.role);
}

class AdminUserSortChanged extends AdminEvent {
  final String sort;
  AdminUserSortChanged(this.sort);
}

class AdminUserUploadsFilterChanged extends AdminEvent {
  final String username;
  AdminUserUploadsFilterChanged(this.username);
}

// ✅ NEW: fired after admin saves profile changes
// 🔥 FIREBASE: triggered after Firestore + Auth updates succeed
//   Updates AdminLoaded state so Navbar and Profile tab
//   reflect new name/email immediately without re-login
class AdminProfileUpdated extends AdminEvent {
  final String name;
  final String email;
  AdminProfileUpdated({required this.name, required this.email});
}

// ── Category events ───────────────────────────────────────────────────────────

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
// STATES
// ─────────────────────────────────────────────────────────────────────────────
abstract class AdminState {}

class AdminLoading extends AdminState {}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminLoaded extends AdminState {
  final bool isDarkMode;
  final AdminTab activeTab;
  final List<String> savedResourceIds;

  // ✅ FIX: current logged-in admin identity
  // 🔥 FIREBASE: set this from FirebaseAuth.instance.currentUser!.uid on login
  //   Never hardcode this value — always read from Auth
  final String currentAdminId;
  final String currentAdminName;
  final String currentAdminEmail;

  // Stats
  final int totalGlobalResources;
  final int totalUsers;
  final int totalCategories;

  // Resources — all resources (global + private)
  // 🔥 FIREBASE: global resources → scope == 'global'
  //              my resources    → uploaded_by == currentUser.uid
  final List<ResourceModel> resources;
  final List<ResourceModel> filteredResources;
  final String resourceSearch;
  final String resourceCategoryFilter;
  final String resourceDifficultyFilter;

  // Users
  // Users
  final List<AdminUser> users;
  final List<AdminUser> filteredUsers;
  final String userSearch;
  final String userRoleFilter;
  final String userSort;
  final String userUploadsFilter;

  // Categories
  final List<CategoryModel> categories;

  // Feedback
  final bool isActionLoading;
  final String? successMessage;
  final String? errorMessage;

  AdminLoaded({
    required this.isDarkMode,
    required this.activeTab,
    // ✅ identity fields
    // 🔥 FIREBASE: populated from FirebaseAuth.instance.currentUser on _onStarted
    this.currentAdminId = 'admin', // 🔥 FIREBASE: replace with currentUser.uid
    this.currentAdminName =
        'Admin User', // 🔥 FIREBASE: replace with currentUser.displayName
    this.currentAdminEmail =
        'admin@studyhub.com', // 🔥 FIREBASE: replace with currentUser.email
    required this.totalGlobalResources,
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
    this.userRoleFilter = '',
    this.userSort = 'date',
    this.userUploadsFilter = '',
    this.savedResourceIds = const [],
    required this.categories,
    this.isActionLoading = false,
    this.successMessage,
    this.errorMessage,
  });

  AdminLoaded copyWith({
    bool? isDarkMode,
    AdminTab? activeTab,
    // ✅ identity fields in copyWith
    // 🔥 FIREBASE: these update when Auth state changes
    String? currentAdminId,
    String? currentAdminName,
    String? currentAdminEmail,
    int? totalGlobalResources,
    int? totalUsers,
    int? totalCategories,
    List<ResourceModel>? resources,
    List<ResourceModel>? filteredResources,
    String? userRoleFilter,
    String? userSort,
    String? userUploadsFilter,
    String? resourceSearch,
    String? resourceCategoryFilter,
    String? resourceDifficultyFilter,
    List<AdminUser>? users,
    List<AdminUser>? filteredUsers,
    String? userSearch,
    List<String>? savedResourceIds,
    List<CategoryModel>? categories,
    bool? isActionLoading,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return AdminLoaded(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      activeTab: activeTab ?? this.activeTab,
      // ✅ preserve identity across state updates
      // 🔥 FIREBASE: these never change mid-session unless user re-authenticates
      currentAdminId: currentAdminId ?? this.currentAdminId,
      currentAdminName: currentAdminName ?? this.currentAdminName,
      currentAdminEmail: currentAdminEmail ?? this.currentAdminEmail,
      totalGlobalResources: totalGlobalResources ?? this.totalGlobalResources,
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
      userRoleFilter: userRoleFilter ?? this.userRoleFilter,
      userSort: userSort ?? this.userSort,
      userUploadsFilter: userUploadsFilter ?? this.userUploadsFilter,
      categories: categories ?? this.categories,
      savedResourceIds: savedResourceIds ?? this.savedResourceIds,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }
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
    on<AdminResourceScopeChanged>(_onResourceScopeChanged);
    on<AdminUserSearchChanged>(_onUserSearchChanged);
    on<AdminUserDeleteRequested>(_onUserDeleteRequested);
    on<AdminUserBanRequested>(_onUserBanRequested);
    on<AdminUserSuspendRequested>(_onUserSuspendRequested);
    on<AdminUserUnbanRequested>(_onUserUnbanRequested);
    on<AdminUserRoleFilterChanged>(_onUserRoleFilterChanged);
    on<AdminUserSortChanged>(_onUserSortChanged);
    on<AdminUserUploadsFilterChanged>(_onUserUploadsFilterChanged);
    on<AdminCategoryAddRequested>(_onCategoryAddRequested);
    on<AdminCategoryEditRequested>(_onCategoryEditRequested);
    on<AdminCategoryDeleteRequested>(_onCategoryDeleteRequested);
    on<AdminProfileUpdated>(_onProfileUpdated);
    // In admin_bloc.dart, inside your on<> handlers:
    on<AdminResourceSavedToMyResources>((event, emit) async {
      if (state is! AdminLoaded) return;
      final current = state as AdminLoaded;
      try {
        await _repo.saveResourceToMyResources(
          resourceId: event.resourceId,
          adminId: current.currentAdminId,
        );
        emit(
          current.copyWith(
            savedResourceIds: [...current.savedResourceIds, event.resourceId],
            successMessage: 'Saved to My Resources',
          ),
        );
      } catch (e) {
        emit(current.copyWith(errorMessage: 'Failed to save: $e'));
      }
    });
  }

  // ✅ NEW: updates identity fields in AdminLoaded state
  // 🔥 FIREBASE: call this after both Auth + Firestore updates succeed
  //   context.read<AdminBloc>().add(AdminProfileUpdated(
  //     name:  nameCtrl.text.trim(),
  //     email: emailCtrl.text.trim(),
  //   ));
  void _onProfileUpdated(AdminProfileUpdated e, Emitter<AdminState> emit) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(
      s.copyWith(
        currentAdminName: e.name,
        currentAdminEmail: e.email,
        successMessage: 'Profile updated.',
      ),
    );
  }

  // ── Ban user ─────────────────────────────────────────────────────────────
  // 🔥 FIREBASE: _repo.banUser() handles:
  //   STEP 1 → Firestore: users/{uid} status:'banned'
  //   STEP 2 → Cloud Function: disables Firebase Auth account
  Future<void> _onUserBanRequested(
    AdminUserBanRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(s.copyWith(isActionLoading: true, clearMessages: true));
    try {
      await _repo.banUser(e.userId);
      final updated = s.users
          .map((u) => u.id == e.userId ? u.copyWith(status: 'banned') : u)
          .toList();
      emit(
        s.copyWith(
          isActionLoading: false,
          users: updated,
          filteredUsers: _applyUserFilters(updated, s),
          successMessage: 'User banned.',
        ),
      );
    } catch (_) {
      emit(
        s.copyWith(isActionLoading: false, errorMessage: 'Failed to ban user.'),
      );
    }
  }

  // ── Suspend user ──────────────────────────────────────────────────────────
  Future<void> _onUserSuspendRequested(
    AdminUserSuspendRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    // 🔥 FIREBASE (backend team): suspend via Cloud Function:
    //   await FirebaseFunctions.instance
    //     .httpsCallable('suspendUser')
    //     .call({'uid': e.userId});
    // 🔥 FIREBASE:
    //   await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(e.userId)
    //     .update({'status': 'suspended'});
    final updated = s.users
        .map((u) => u.id == e.userId ? u.copyWith(status: 'suspended') : u)
        .toList();
    emit(
      s.copyWith(
        users: updated,
        filteredUsers: _applyUserFilters(updated, s),
        successMessage: 'User suspended.',
      ),
    );
  }

  // ── Unban / reinstate user ────────────────────────────────────────────────
  Future<void> _onUserUnbanRequested(
    AdminUserUnbanRequested e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    // 🔥 FIREBASE (backend team):
    //   await FirebaseFunctions.instance
    //     .httpsCallable('unbanUser')
    //     .call({'uid': e.userId});
    // 🔥 FIREBASE:
    //   await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(e.userId)
    //     .update({'status': 'active'});
    final updated = s.users
        .map((u) => u.id == e.userId ? u.copyWith(status: 'active') : u)
        .toList();
    emit(
      s.copyWith(
        users: updated,
        filteredUsers: _applyUserFilters(updated, s),
        successMessage: 'User reinstated.',
      ),
    );
  }

  // ── Role filter ───────────────────────────────────────────────────────────
  void _onUserRoleFilterChanged(
    AdminUserRoleFilterChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    final updated = s.copyWith(userRoleFilter: e.role);
    emit(updated.copyWith(filteredUsers: _applyUserFilters(s.users, updated)));
  }

  // ── Sort ──────────────────────────────────────────────────────────────────
  void _onUserSortChanged(AdminUserSortChanged e, Emitter<AdminState> emit) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    final updated = s.copyWith(userSort: e.sort);
    emit(updated.copyWith(filteredUsers: _applyUserFilters(s.users, updated)));
  }

  // ── Cross-tab uploads filter ──────────────────────────────────────────────
  void _onUserUploadsFilterChanged(
    AdminUserUploadsFilterChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    emit((state as AdminLoaded).copyWith(userUploadsFilter: e.username));
  }

  // ── Shared user filter helper ─────────────────────────────────────────────
  List<AdminUser> _applyUserFilters(List<AdminUser> all, AdminLoaded s) {
    var list = [...all];

    if (s.userRoleFilter.isNotEmpty) {
      list = list.where((u) => u.role == s.userRoleFilter).toList();
    }

    if (s.userSearch.isNotEmpty) {
      final q = s.userSearch.toLowerCase();
      list = list
          .where(
            (u) =>
                u.name.toLowerCase().contains(q) ||
                u.email.toLowerCase().contains(q),
          )
          .toList();
    }

    if (s.userSort == 'name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  // ── Load ────────────────────────────────────────────────────────────────
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
          savedResourceIds: const [],
          totalGlobalResources: resources.where((r) => r.isGlobal).length,
          totalUsers: users.length,
          totalCategories: categories.length,
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

  // ── Tab ─────────────────────────────────────────────────────────────────
  void _onTabChanged(AdminTabChanged e, Emitter<AdminState> emit) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    emit(
      s.copyWith(
        activeTab: e.tab,
        // Auto-clear the uploads filter when leaving User Uploads tab
        // so there's no stale filter if user navigates back normally
        userUploadsFilter: e.tab == AdminTab.userUploads
            ? s.userUploadsFilter
            : '',
      ),
    );
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
      final md = difficulty.isEmpty || r.fileType == difficulty;
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
      // 🔥 FIREBASE: await _repo.deleteResource(e.id);
      // 🔥 FIREBASE: also delete file from Storage:
      //   final r = s.resources.firstWhere((r) => r.id == e.id);
      //   if (r.fileUrl.isNotEmpty) {
      //     await FirebaseStorage.instance.refFromURL(r.fileUrl).delete();
      //   }
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
          totalGlobalResources: s.totalGlobalResources - 1,
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
      // 🔥 FIREBASE: Upload file to Storage first, get download URL:
      //   final ref = FirebaseStorage.instance.ref(
      //     'resources/${e.categoryId}/${DateTime.now().millisecondsSinceEpoch}_${e.fileName}',
      //   );
      //   await ref.putFile(File(e.filePath));        // mobile/desktop
      //   // await ref.putData(fileBytes);            // web
      //   final fileUrl = await ref.getDownloadURL();
      //
      // 🔥 FIREBASE: Then save to Firestore:
      //   await FirebaseFirestore.instance
      //     .collection('resources')
      //     .add({
      //       'title':         e.title,
      //       'description':   e.description,
      //       'category_id':   e.categoryId,
      //       'difficulty':    e.difficulty,
      //       'tags':          e.tags.split(',').map((t) => t.trim()).toList(),
      //       'file_name':     e.fileName,
      //       'file_type':     e.fileType,
      //       'file_url':      fileUrl,
      //       'scope':         e.scope,
      //       'uploaded_by':   FirebaseAuth.instance.currentUser!.uid,
      //       'uploaded_at':   FieldValue.serverTimestamp(),
      //     });
      // ✅ FIX: pass scope to repository
      // 🔥 FIREBASE: repository will use scope to set Firestore 'scope' field
      //   AND to decide which Storage bucket path to use:
      //   'resources/global/{categoryId}/{fileName}' ← for global
      //   'resources/private/{uid}/{fileName}'       ← for private
      await _repo.uploadResource(
        title: e.title,
        description: e.description,
        categoryId: e.categoryId,
        difficulty: e.difficulty,
        tags: e.tags,
        fileName: e.fileName,
        fileType: e.fileType,
        scope: e.scope, // ✅ added
      );
      final updated = await _repo.getResources();
      // Only increment global count if scope is global
      final newGlobalCount = e.scope == 'global'
          ? s.totalGlobalResources + 1
          : s.totalGlobalResources;
      emit(
        s.copyWith(
          isActionLoading: false,
          resources: updated,
          filteredResources: updated,
          totalGlobalResources: newGlobalCount,
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

  // ── Scope change ────────────────────────────────────────────────────────
  Future<void> _onResourceScopeChanged(
    AdminResourceScopeChanged e,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    try {
      // 🔥 FIREBASE: Replace optimistic update below with:
      //   await FirebaseFirestore.instance
      //     .collection('resources')
      //     .doc(e.id)
      //     .update({'scope': e.scope});
      //   // No need to manually update state — use a stream listener instead

      // Optimistic local update (remove when Firebase stream is connected)
      final newScope = e.scope == 'global'
          ? ResourceScope.global
          : ResourceScope.private;

      final updated = s.resources.map((r) {
        if (r.id != e.id) return r;
        return r.copyWith(scope: newScope);
      }).toList();

      // Adjust global resource count
      final wasGlobal = s.resources.firstWhere((r) => r.id == e.id).isGlobal;
      final becomesGlobal = e.scope == 'global';
      int newCount = s.totalGlobalResources;
      if (!wasGlobal && becomesGlobal) newCount++;
      if (wasGlobal && !becomesGlobal) newCount--;

      emit(
        s.copyWith(
          resources: updated,
          filteredResources: _filterResources(
            updated,
            search: s.resourceSearch,
            categoryId: s.resourceCategoryFilter,
            difficulty: s.resourceDifficultyFilter,
          ),
          totalGlobalResources: newCount,
          successMessage: becomesGlobal
              ? 'Resource is now public.'
              : 'Resource is now private.',
        ),
      );
    } catch (_) {
      emit(s.copyWith(errorMessage: 'Failed to update visibility.'));
    }
  }

  // ── User search ─────────────────────────────────────────────────────────
  void _onUserSearchChanged(
    AdminUserSearchChanged e,
    Emitter<AdminState> emit,
  ) {
    if (state is! AdminLoaded) return;
    final s = state as AdminLoaded;
    final updated = s.copyWith(userSearch: e.query);
    emit(updated.copyWith(filteredUsers: _applyUserFilters(s.users, updated)));
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
      // 🔥 FIREBASE: Two-step delete — Auth + Firestore:
      //   await FirebaseAuth.instance.deleteUser(e.id); // needs Admin SDK
      //   OR use a Cloud Function: functions.httpsCallable('deleteUser')({uid: e.id})
      //   await FirebaseFirestore.instance.collection('users').doc(e.id).delete();
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
      // 🔥 FIREBASE:
      //   await FirebaseFirestore.instance.collection('categories').add({
      //     'name':        e.name,
      //     'description': e.description,
      //     'emoji':       e.emoji,
      //     'created_at':  FieldValue.serverTimestamp(),
      //   });
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
      // 🔥 FIREBASE:
      //   await FirebaseFirestore.instance
      //     .collection('categories')
      //     .doc(e.id)
      //     .update({
      //       'name':        e.name,
      //       'description': e.description,
      //       'emoji':       e.emoji,
      //     });
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
      // 🔥 FIREBASE:
      //   await FirebaseFirestore.instance
      //     .collection('categories')
      //     .doc(e.id)s
      //     .delete();
      //   // Optionally: update all resources in this category to categoryId = ''
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
