part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardStarted extends DashboardEvent {}

class DashboardTabChanged extends DashboardEvent {
  final DashboardTab tab;
  const DashboardTabChanged(this.tab);
  @override
  List<Object?> get props => [tab];
}

class GlobalResourceUploadSubmitted extends DashboardEvent {
  final String title,
      description,
      categoryId,
      categoryName,
      difficulty,
      tags,
      fileName,
      fileType;
  GlobalResourceUploadSubmitted({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.tags,
    required this.fileName,
    required this.fileType,
  });
}

class GlobalResourceDeleted extends DashboardEvent {
  final String resourceId;
  GlobalResourceDeleted({required this.resourceId});
}

class ResourceSavedToMyResources extends DashboardEvent {
  final String resourceId;
  ResourceSavedToMyResources({required this.resourceId});
}

class ResourceStarToggled extends DashboardEvent {
  final String resourceId;
  const ResourceStarToggled(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}

class ResourcePinToggled extends DashboardEvent {
  final String resourceId;
  const ResourcePinToggled(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}

class ResourceMarkedDone extends DashboardEvent {
  final String resourceId;
  const ResourceMarkedDone(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}

class ResourceOpened extends DashboardEvent {
  final String resourceId;
  const ResourceOpened(this.resourceId);
  @override
  List<Object?> get props => [resourceId];
}

class ThemeToggled extends DashboardEvent {}

class DashboardSearchChanged extends DashboardEvent {
  final String query;
  const DashboardSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

// Fired when user clicks a category card to filter resources
class CategorySelected extends DashboardEvent {
  final String categoryId;
  const CategorySelected(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// Fired when user submits the Add Category form
class CategoryAdded extends DashboardEvent {
  final String name;
  final String emoji;
  const CategoryAdded({required this.name, required this.emoji});
  @override
  List<Object?> get props => [name, emoji];
}
