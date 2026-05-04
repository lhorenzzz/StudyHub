// Category model — represents a resource category (e.g. IT, Science, Cookery)
class CategoryModel {
  final String id;
  final String name;
  final String emoji; // display icon
  final String description;
  final int resourceCount; // how many resources are inside
  final bool isCustom; // true = user-created category

  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.resourceCount,
    this.isCustom = false,
  });

  // Convert from a Map (e.g. Firestore document)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '📁',
      description: map['description'] ?? '',
      resourceCount: map['resourceCount'] ?? 0,
      isCustom: map['isCustom'] ?? false,
    );
  }

  // Convert to a Map (e.g. for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'description': description,
      'resourceCount': resourceCount,
      'isCustom': isCustom,
    };
  }
}
