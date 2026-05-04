part of 'upload_bloc.dart';

abstract class UploadState extends Equatable {
  const UploadState();
  @override
  List<Object?> get props => [];
}

// Idle state — form is ready to fill
class UploadIdle extends UploadState {
  final String title;
  final String fileName;
  final String fileType;
  final String categoryId;
  final String categoryName;
  final String difficulty;
  final String description;
  final String tags;

  const UploadIdle({
    this.title = '',
    this.fileName = '',
    this.fileType = '',
    this.categoryId = '',
    this.categoryName = '',
    this.difficulty = '',
    this.description = '',
    this.tags = '',
  });

  // Check if required fields are filled
  bool get isValid =>
      title.isNotEmpty &&
      fileName.isNotEmpty &&
      categoryId.isNotEmpty &&
      difficulty.isNotEmpty;

  UploadIdle copyWith({
    String? title,
    String? fileName,
    String? fileType,
    String? categoryId,
    String? categoryName,
    String? difficulty,
    String? description,
    String? tags,
  }) {
    return UploadIdle(
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    title,
    fileName,
    fileType,
    categoryId,
    categoryName,
    difficulty,
    description,
    tags,
  ];
}

// Uploading state — show loading
class UploadLoading extends UploadState {}

// Success state
class UploadSuccess extends UploadState {
  final String resourceTitle;
  const UploadSuccess(this.resourceTitle);
  @override
  List<Object?> get props => [resourceTitle];
}

// Error state
class UploadFailure extends UploadState {
  final String error;
  const UploadFailure(this.error);
  @override
  List<Object?> get props => [error];
}
