// Supported file types a user can upload
enum ResourceType { pdf, excel, ppt, word, article }

// Difficulty level of the resource
enum DifficultyLevel { beginner, intermediate }

// ResourceModel — represents a single uploaded resource
class ResourceModel {
  final String id;
  final String title;
  final String categoryId; // which category this belongs to
  final String categoryName; // display name of the category
  final ResourceType type; // pdf, excel, ppt, word, or article
  final DifficultyLevel difficulty;
  final String uploadedBy; // user id of uploader
  final DateTime uploadedAt;
  final bool isDone; // user marked this as done
  final bool isStarred; // user starred/favorited this
  final bool isPinned; // user pinned this
  final DateTime? lastOpenedAt; // for "Opened Recently" tab

  const ResourceModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.difficulty,
    required this.uploadedBy,
    required this.uploadedAt,
    this.isDone = false,
    this.isStarred = false,
    this.isPinned = false,
    this.lastOpenedAt,
  });

  // Helper — returns a display label for the file type
  String get typeLabel {
    switch (type) {
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.excel:
        return 'Excel';
      case ResourceType.ppt:
        return 'PPT';
      case ResourceType.word:
        return 'Word';
      case ResourceType.article:
        return 'Article';
    }
  }

  // Helper — returns an emoji icon for the file type
  String get typeEmoji {
    switch (type) {
      case ResourceType.pdf:
        return '📄';
      case ResourceType.excel:
        return '📊';
      case ResourceType.ppt:
        return '📑';
      case ResourceType.word:
        return '📝';
      case ResourceType.article:
        return '📰';
    }
  }

  // Helper — difficulty display label
  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
    }
  }

  // Returns a copy of this resource with updated fields
  // Used in BLoC when toggling star, pin, done, etc.
  ResourceModel copyWith({
    bool? isDone,
    bool? isStarred,
    bool? isPinned,
    DateTime? lastOpenedAt,
  }) {
    return ResourceModel(
      id: id,
      title: title,
      categoryId: categoryId,
      categoryName: categoryName,
      type: type,
      difficulty: difficulty,
      uploadedBy: uploadedBy,
      uploadedAt: uploadedAt,
      isDone: isDone ?? this.isDone,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }
}
