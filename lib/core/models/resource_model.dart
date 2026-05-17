enum ResourceType { pdf, excel, ppt, word, article }

enum DifficultyLevel { beginner, intermediate }

enum ResourceScope { private, global }

class ResourceModel {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final ResourceType type;
  final DifficultyLevel difficulty;
  final List<String> tags;
  final String uploadedBy;     // Firebase UID
  final String uploadedByName; // Display name
  final DateTime uploadedAt;
  final String fileUrl;
  final ResourceScope scope;
  final bool isDone;
  final bool isStarred;
  final bool isPinned;
  final DateTime? lastOpenedAt;

  const ResourceModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.difficulty,
    this.tags = const [],
    required this.uploadedBy,
    this.uploadedByName = '',
    required this.uploadedAt,
    this.fileUrl = '',
    this.scope = ResourceScope.global,
    this.isDone = false,
    this.isStarred = false,
    this.isPinned = false,
    this.lastOpenedAt,
  });

  // ── Getters ───────────────────────────────────────────────────────────────

  String get fileType {
    switch (type) {
      case ResourceType.pdf:     return 'pdf';
      case ResourceType.excel:   return 'excel';
      case ResourceType.ppt:     return 'ppt';
      case ResourceType.word:    return 'word';
      case ResourceType.article: return 'article';
    }
  }

  String get typeLabel {
    switch (type) {
      case ResourceType.pdf:     return 'PDF';
      case ResourceType.excel:   return 'Excel';
      case ResourceType.ppt:     return 'PPT';
      case ResourceType.word:    return 'Word';
      case ResourceType.article: return 'Article';
    }
  }

  String get typeEmoji {
    switch (type) {
      case ResourceType.pdf:     return '📄';
      case ResourceType.excel:   return '📊';
      case ResourceType.ppt:     return '📑';
      case ResourceType.word:    return '📝';
      case ResourceType.article: return '📰';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:     return 'Beginner';
      case DifficultyLevel.intermediate: return 'Intermediate';
    }
  }

  /// The best display name available — name if set, otherwise UID
  String get displayName =>
      uploadedByName.isNotEmpty ? uploadedByName : uploadedBy;

  bool get isPrivate  => scope == ResourceScope.private;
  bool get isGlobal   => scope == ResourceScope.global;
  bool get hasFileUrl => fileUrl.isNotEmpty;

  // ── copyWith ──────────────────────────────────────────────────────────────

  ResourceModel copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    ResourceType? type,
    DifficultyLevel? difficulty,
    List<String>? tags,
    String? uploadedByName,
    String? fileUrl,
    ResourceScope? scope,
    bool? isDone,
    bool? isStarred,
    bool? isPinned,
    DateTime? lastOpenedAt,
  }) {
    return ResourceModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      uploadedBy: uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      uploadedAt: uploadedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      scope: scope ?? this.scope,
      isDone: isDone ?? this.isDone,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  // ── Firestore helpers ─────────────────────────────────────────────────────

  factory ResourceModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ResourceModel(
      id: docId,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      type: _typeFromString(data['fileType'] as String? ?? 'pdf'),
      difficulty: _difficultyFromString(data['difficulty'] as String? ?? 'beginner'),
      tags: List<String>.from(data['tags'] as List? ?? []),
      uploadedBy: data['uploadedBy'] as String? ?? '',
      uploadedByName: data['uploadedByName'] as String? ?? '',
      uploadedAt: (data['uploadedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      fileUrl: data['fileUrl'] as String? ?? '',
      scope: (data['scope'] as String?) == 'private'
          ? ResourceScope.private
          : ResourceScope.global,
      isDone: data['isDone'] as bool? ?? false,
      isStarred: data['isStarred'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      lastOpenedAt: (data['lastOpenedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title'          : title,
      'description'    : description,
      'categoryId'     : categoryId,
      'categoryName'   : categoryName,
      'fileType'       : fileType,
      'difficulty'     : difficulty == DifficultyLevel.beginner ? 'beginner' : 'intermediate',
      'tags'           : tags,
      'uploadedBy'     : uploadedBy,
      'uploadedByName' : uploadedByName,
      'uploadedAt'     : uploadedAt,
      'fileUrl'        : fileUrl,
      'scope'          : isPrivate ? 'private' : 'global',
      'isDone'         : isDone,
      'isStarred'      : isStarred,
      'isPinned'       : isPinned,
      'lastOpenedAt'   : lastOpenedAt,
    };
  }

  // ── Parse helpers ─────────────────────────────────────────────────────────

  static ResourceType _typeFromString(String s) {
    switch (s.toLowerCase()) {
      case 'excel':   return ResourceType.excel;
      case 'ppt':     return ResourceType.ppt;
      case 'word':    return ResourceType.word;
      case 'article': return ResourceType.article;
      default:        return ResourceType.pdf;
    }
  }

  static DifficultyLevel _difficultyFromString(String s) {
    return s == 'intermediate'
        ? DifficultyLevel.intermediate
        : DifficultyLevel.beginner;
  }
}