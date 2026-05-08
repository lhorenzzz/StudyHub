// Supported file types a user can upload
enum ResourceType { pdf, excel, ppt, word, article }

// Difficulty level of the resource
enum DifficultyLevel { beginner, intermediate }

// Scope of the resource — who can see it
// 🔥 FIREBASE: stored as 'scope' field in Firestore document
//   'private' = only visible to uploader (My Resources)
//   'global'  = visible to all users (Global Resources + student dashboard)
enum ResourceScope { private, global }

// ResourceModel — represents a single uploaded resource
class ResourceModel {
  final String id;
  final String title;
  final String description; // NEW — brief description of the resource
  final String categoryId;
  final String categoryName;
  final ResourceType type;
  final DifficultyLevel difficulty;
  final List<String> tags; // NEW — searchable tags e.g. ['HTML', 'CSS']
  final String uploadedBy; // user id of uploader
  final DateTime uploadedAt;

  // 🔥 FIREBASE: fileUrl is the Firebase Storage download URL
  //   Set after upload: await FirebaseStorage.instance.ref(...).getDownloadURL()
  //   Empty string '' until Firebase Storage is connected
  final String fileUrl; // NEW — real file URL for "Open File" button

  // 🔥 FIREBASE: scope determines visibility
  //   Firestore field: 'scope' → 'private' | 'global'
  final ResourceScope scope; // NEW — private or global

  final bool isDone;
  final bool isStarred;
  final bool isPinned;
  final DateTime? lastOpenedAt;

  const ResourceModel({
    required this.id,
    required this.title,
    this.description = '', // optional, empty by default
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.difficulty,
    this.tags = const [], // optional, empty by default
    required this.uploadedBy,
    required this.uploadedAt,
    this.fileUrl = '', // empty until Firebase Storage connected
    this.scope =
        ResourceScope.global, // default global to not break existing data
    this.isDone = false,
    this.isStarred = false,
    this.isPinned = false,
    this.lastOpenedAt,
  });

  // ── Getters ──────────────────────────────────────────────────────────────────

  String get fileType {
    switch (type) {
      case ResourceType.pdf:
        return 'pdf';
      case ResourceType.excel:
        return 'excel';
      case ResourceType.ppt:
        return 'ppt';
      case ResourceType.word:
        return 'word';
      case ResourceType.article:
        return 'article';
    }
  }

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

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
    }
  }

  // Convenience getters for scope
  bool get isPrivate => scope == ResourceScope.private;
  bool get isGlobal => scope == ResourceScope.global;

  // Whether the file can actually be opened
  // 🔥 FIREBASE: will be true once fileUrl is populated from Storage
  bool get hasFileUrl => fileUrl.isNotEmpty;

  // ── copyWith ──────────────────────────────────────────────────────────────────
  // 🔥 FIREBASE: scope change → update Firestore doc 'scope' field
  //   FirebaseFirestore.instance
  //     .collection('resources')
  //     .doc(id)
  //     .update({'scope': newScope == ResourceScope.global ? 'global' : 'private'})
  ResourceModel copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    ResourceType? type,
    DifficultyLevel? difficulty,
    List<String>? tags,
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
      uploadedAt: uploadedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      scope: scope ?? this.scope,
      isDone: isDone ?? this.isDone,
      isStarred: isStarred ?? this.isStarred,
      isPinned: isPinned ?? this.isPinned,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }

  // ── Firebase helpers ──────────────────────────────────────────────────────────

  // 🔥 FIREBASE: Convert from Firestore document snapshot
  // Usage: ResourceModel.fromFirestore(doc.data()!, doc.id)
  factory ResourceModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ResourceModel(
      id: docId,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['category_id'] as String? ?? '',
      categoryName: data['category_name'] as String? ?? '',
      type: _typeFromString(data['file_type'] as String? ?? 'pdf'),
      difficulty: _difficultyFromString(
        data['difficulty'] as String? ?? 'beginner',
      ),
      tags: List<String>.from(data['tags'] as List? ?? []),
      uploadedBy: data['uploaded_by'] as String? ?? '',
      uploadedAt: (data['uploaded_at'] as dynamic)?.toDate() ?? DateTime.now(),
      fileUrl: data['file_url'] as String? ?? '',
      scope: (data['scope'] as String?) == 'private'
          ? ResourceScope.private
          : ResourceScope.global,
      isDone: data['is_done'] as bool? ?? false,
      isStarred: data['is_starred'] as bool? ?? false,
      isPinned: data['is_pinned'] as bool? ?? false,
      lastOpenedAt: (data['last_opened_at'] as dynamic)?.toDate(),
    );
  }

  // 🔥 FIREBASE: Convert to Firestore document map
  // Usage: FirebaseFirestore.instance.collection('resources').doc(id).set(toFirestore())
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'file_type': fileType,
      'difficulty': difficulty == DifficultyLevel.beginner
          ? 'beginner'
          : 'intermediate',
      'tags': tags,
      'uploaded_by': uploadedBy,
      'uploaded_at':
          uploadedAt, // 🔥 FIREBASE: Firestore will store as Timestamp
      'file_url': fileUrl,
      'scope': isPrivate ? 'private' : 'global',
      'is_done': isDone,
      'is_starred': isStarred,
      'is_pinned': isPinned,
      'last_opened_at': lastOpenedAt,
    };
  }

  // ── Private parse helpers ─────────────────────────────────────────────────────
  static ResourceType _typeFromString(String s) {
    switch (s) {
      case 'excel':
        return ResourceType.excel;
      case 'ppt':
        return ResourceType.ppt;
      case 'word':
        return ResourceType.word;
      case 'article':
        return ResourceType.article;
      default:
        return ResourceType.pdf;
    }
  }

  static DifficultyLevel _difficultyFromString(String s) {
    return s == 'intermediate'
        ? DifficultyLevel.intermediate
        : DifficultyLevel.beginner;
  }
}
