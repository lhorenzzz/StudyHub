import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';
import 'package:study_hub/features/user/repository/user_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UserRepository _repository = UserRepository.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    on<GlobalResourceUploadSubmitted>(_onGlobalUpload);
    on<GlobalResourceDeleted>(_onGlobalDelete);
    on<ResourceSavedToMyResources>(_onSaveToMyResources);
  }

  Future<void> _onStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(DashboardError('User not authenticated'));
        return;
      }

      // Load data in parallel
      final results = await Future.wait([
        _repository.getGlobalResources(),
        _repository.getMyResources(user.uid),
        _repository.getSavedResources(user.uid),
        _repository.getCategories(),
      ]);

      final globalResources = results[0] as List<ResourceModel>;
      final myResources = results[1] as List<ResourceModel>;
      final savedResources = results[2] as List<ResourceModel>;
      final categories = results[3] as List<CategoryModel>;

      // Combine all resources for the "all" tab
      final seen = <String>{};
      final allResources = [...globalResources, ...myResources, ...savedResources].where((r) => seen.add(r.id)).toList();
          
      // Find last opened resource
      final opened = allResources.where((r) => r.lastOpenedAt != null).toList()
        ..sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));

      emit(
        DashboardLoaded(
          resources: allResources,
          categories: categories,
          activeTab: DashboardTab.all,
          isDarkMode: true,
          lastOpened: opened.isNotEmpty ? opened.first : null,
        ),
      );
    } catch (e) {
      emit(DashboardError('Failed to load resources. Please try again.'));
    }
  }

  void _onTabChanged(DashboardTabChanged event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      emit((state as DashboardLoaded).copyWith(activeTab: event.tab));
    }
  }

  void _onStarToggled(ResourceStarToggled event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        final resource = cur.resources.firstWhere((r) => r.id == event.resourceId);
        final isCurrentlyStarred = resource.isStarred;

        if (isCurrentlyStarred) {
          await _repository.unsaveResource(event.resourceId, user.uid);
        } else {
          await _repository.saveResource(event.resourceId, user.uid);
        }

        emit(
          cur.copyWith(
            resources: cur.resources
                .map(
                  (r) => r.id == event.resourceId
                      ? r.copyWith(isStarred: !isCurrentlyStarred)
                      : r,
                )
                .toList(),
          ),
        );
      } catch (e) {
        // Handle error - could emit an error state or just ignore
      }
    }
  }

  void _onPinToggled(ResourcePinToggled event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      final resource = cur.resources.firstWhere((r) => r.id == event.resourceId);

      try {
        await _repository.updateResourceState(event.resourceId, isPinned: !resource.isPinned);

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
      } catch (e) {
        // Handle error
      }
    }
  }

  void _onMarkedDone(ResourceMarkedDone event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;

      try {
        await _repository.updateResourceState(event.resourceId, isDone: true);

        emit(
          cur.copyWith(
            resources: cur.resources
                .map(
                  (r) => r.id == event.resourceId ? r.copyWith(isDone: true) : r,
                )
                .toList(),
          ),
        );
      } catch (e) {
        // Handle error
      }
    }
  }

  void _onResourceOpened(ResourceOpened event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;

      try {
        await _repository.updateResourceState(event.resourceId, lastOpenedAt: DateTime.now());

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
      } catch (e) {
        // Handle error
      }
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

  void _onGlobalUpload(
    GlobalResourceUploadSubmitted event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;

      try {
        await _repository.uploadResource(
          title: event.title,
          description: event.description,
          categoryId: event.categoryId,
          difficulty: event.difficulty,
          tags: event.tags,
          fileName: event.fileName,
          fileType: event.fileType,
        );

        // Reload resources to show the new one
        add(DashboardStarted());
      } catch (e) {
        // Handle error - could emit an error state
      }
    }
  }

  void _onGlobalDelete(
    GlobalResourceDeleted event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      emit(
        cur.copyWith(
          resources: cur.resources
              .where((r) => r.id != event.resourceId)
              .toList(),
        ),
      );
    }
  }

  void _onSaveToMyResources(
    ResourceSavedToMyResources event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final cur = state as DashboardLoaded;
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        await _repository.saveResource(event.resourceId, user.uid);

        // Update local state to show it's saved
        emit(
          cur.copyWith(
            resources: cur.resources.map((r) {
              if (r.id == event.resourceId) {
                return r.copyWith(isStarred: true);
              }
              return r;
            }).toList(),
          ),
        );
      } catch (e) {
        // Handle error
      }
    }
  }
} // ← class closes HERE, after all handlers
