part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();
  @override
  List<Object?> get props => [];
}

// Fired when user types in the title field
class UploadTitleChanged extends UploadEvent {
  final String title;
  const UploadTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

// Fired when user picks a file
class UploadFileSelected extends UploadEvent {
  final String fileName;
  final String fileType; // pdf, excel, ppt, word
  const UploadFileSelected({required this.fileName, required this.fileType});
  @override
  List<Object?> get props => [fileName, fileType];
}

// Fired when user selects a category
class UploadCategoryChanged extends UploadEvent {
  final String categoryId;
  final String categoryName;
  const UploadCategoryChanged({
    required this.categoryId,
    required this.categoryName,
  });
  @override
  List<Object?> get props => [categoryId, categoryName];
}

// Fired when user selects difficulty
class UploadDifficultyChanged extends UploadEvent {
  final String difficulty;
  const UploadDifficultyChanged(this.difficulty);
  @override
  List<Object?> get props => [difficulty];
}

// Fired when user types description (optional)
class UploadDescriptionChanged extends UploadEvent {
  final String description;
  const UploadDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

// Fired when user types tags (optional)
class UploadTagsChanged extends UploadEvent {
  final String tags;
  const UploadTagsChanged(this.tags);
  @override
  List<Object?> get props => [tags];
}

// Fired when user submits the form
class UploadSubmitted extends UploadEvent {}

// Fired to reset form after success
class UploadReset extends UploadEvent {}
