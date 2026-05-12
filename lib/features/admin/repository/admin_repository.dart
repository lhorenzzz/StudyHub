// ─────────────────────────────────────────────────────────────────────────────
// AdminRepository
//
// Repository for admin dashboard operations using Firebase.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_hub/core/models/admin_user.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';

// ── Data models specific to admin ────────────────────────────────────────────
class AdminStats {
  final int totalResources;
  final int totalUsers;
  final int totalCategories;

  const AdminStats({
    required this.totalResources,
    required this.totalUsers,
    required this.totalCategories,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalResources: (json['totalResources'] as int?) ?? 0,
    totalUsers: (json['totalUsers'] as int?) ?? 0,
    totalCategories: (json['totalCategories'] as int?) ?? 0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORY CLASS
// ─────────────────────────────────────────────────────────────────────────────
class AdminRepository {
  // Singleton so BLoC always uses the same instance
  static final AdminRepository instance = AdminRepository._();
  AdminRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── STATS ──────────────────────────────────────────────────────────────────
  Future<AdminStats> getStats() async {
    try {
      // Get total resources count
      final resourcesSnapshot = await _firestore.collection('resources').get();
      final totalResources = resourcesSnapshot.size;

      // Get total users count
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.size;

      // Get total categories count
      final categoriesSnapshot = await _firestore.collection('categories').get();
      final totalCategories = categoriesSnapshot.size;

      return AdminStats(
        totalResources: totalResources,
        totalUsers: totalUsers,
        totalCategories: totalCategories,
      );
    } catch (e) {
      // Fallback to mock data if Firebase fails
      return const AdminStats(
        totalResources: 25,
        totalUsers: 48,
        totalCategories: 4,
      );
    }
  }

  // ── RESOURCES ──────────────────────────────────────────────────────────────
  Future<List<ResourceModel>> getResources({
    String search = '',
    String categoryId = '',
    String difficulty = '',
  }) async {
    try {
      Query query = _firestore.collection('resources');

      // Apply filters
      if (categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (difficulty.isNotEmpty) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      // Order by upload date (newest first)
      query = query.orderBy('uploadedAt', descending: true);

      final snapshot = await query.get();

      List<ResourceModel> resources = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tagsList = data['tags'] is List ? List<String>.from(data['tags'] as List) : <String>[];
        return ResourceModel(
          id: doc.id,
          title: (data['title'] as String?) ?? '',
          description: (data['description'] as String?) ?? '',
          categoryId: (data['categoryId'] as String?) ?? '',
          categoryName: (data['categoryName'] as String?) ?? '',
          type: _parseResourceType((data['fileType'] as String?) ?? 'pdf'),
          difficulty: _parseDifficultyLevel((data['difficulty'] as String?) ?? 'beginner'),
          tags: tagsList,
          uploadedBy: (data['uploadedBy'] as String?) ?? '',
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          fileUrl: (data['fileUrl'] as String?) ?? '',
          scope: _parseResourceScope((data['scope'] as String?) ?? 'global'),
        );
      }).toList();

      // Apply search filter (client-side)
      if (search.isNotEmpty) {
        resources = resources.where((r) =>
          r.title.toLowerCase().contains(search.toLowerCase()) ||
          r.description.toLowerCase().contains(search.toLowerCase()) ||
          r.tags.any((tag) => tag.toLowerCase().contains(search.toLowerCase()))
        ).toList();
      }

      return resources;
    } catch (e) {
      // Fallback to mock data
      return _mockResources();
    }
  }

  // ── UPLOAD RESOURCE ────────────────────────────────────────────────────────
  Future<void> uploadResource({
    required String title,
    required String description,
    required String categoryId,
    required String difficulty,
    required String tags,
    required String fileName,
    required String fileType,
    String scope = 'global',
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('resources').add({
        'title': title,
        'description': description,
        'categoryId': categoryId,
        'categoryName': await _getCategoryName(categoryId),
        'difficulty': difficulty,
        'tags': tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        'fileName': fileName,
        'fileType': fileType,
        'fileUrl': '',
        'scope': scope,
        'uploadedBy': user.uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Update category resource count
      await _firestore.collection('categories').doc(categoryId).update({
        'resourceCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── DELETE RESOURCE ────────────────────────────────────────────────────────
  Future<void> deleteResource(String resourceId) async {
    try {
      final resource = await _firestore.collection('resources').doc(resourceId).get();
      final data = resource.data() as Map<String, dynamic>?;
      final categoryId = (data?['categoryId'] as String?) ?? '';

      await _firestore.collection('resources').doc(resourceId).delete();

      // Update category resource count
      if (categoryId.isNotEmpty) {
        await _firestore.collection('categories').doc(categoryId).update({
          'resourceCount': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── UPDATE RESOURCE SCOPE ──────────────────────────────────────────────────
  Future<void> updateResourceScope(String resourceId, String newScope) async {
    try {
      await _firestore.collection('resources').doc(resourceId).update({
        'scope': newScope,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── USERS ──────────────────────────────────────────────────────────────────
  Future<List<AdminUser>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AdminUser(
          id: doc.id,
          name: (data['displayName'] as String?) ?? (data['name'] as String?) ?? 'Unknown',
          email: (data['email'] as String?) ?? '',
          role: (data['role'] as String?) ?? 'user',
          status: (data['status'] as String?) ?? 'active',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
          profileImage: (data['profileImage'] as String?) ?? '',
          uploadCount: (data['uploadCount'] as int?) ?? 0,
        );
      }).toList();
    } catch (e) {
      // Fallback to mock data
      return _mockUsers();
    }
  }

  // ── DELETE USER ────────────────────────────────────────────────────────────
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user's resources
      final userResources = await _firestore
          .collection('resources')
          .where('uploadedBy', isEqualTo: userId)
          .get();

      for (final doc in userResources.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── BAN USER ───────────────────────────────────────────────────────────────
  Future<void> banUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': 'banned',
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── SAVE RESOURCE TO MY RESOURCES ──────────────────────────────────────────
  Future<void> saveResourceToMyResources({
    required String resourceId,
    required String adminId,
  }) async {
    try {
      await _firestore.collection('saved_resources').doc('${adminId}_$resourceId').set({
        'resourceId': resourceId,
        'savedBy': adminId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── CATEGORIES ─────────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').orderBy('name').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryModel(
          id: doc.id,
          name: (data['name'] as String?) ?? '',
          emoji: (data['emoji'] as String?) ?? '📁',
          description: (data['description'] as String?) ?? '',
          resourceCount: (data['resourceCount'] as int?) ?? 0,
          isCustom: (data['isCustom'] as bool?) ?? false,
        );
      }).toList();
    } catch (e) {
      // Fallback to mock data
      return _mockCategories();
    }
  }

  // ── ADD CATEGORY ───────────────────────────────────────────────────────────
  Future<void> addCategory({
    required String name,
    required String emoji,
    required String description,
  }) async {
    try {
      await _firestore.collection('categories').add({
        'name': name,
        'emoji': emoji,
        'description': description,
        'resourceCount': 0,
        'isCustom': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── EDIT CATEGORY ──────────────────────────────────────────────────────────
  Future<void> editCategory({
    required String categoryId,
    required String name,
    required String emoji,
    required String description,
  }) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'name': name,
        'emoji': emoji,
        'description': description,
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── DELETE CATEGORY ────────────────────────────────────────────────────────
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ── HELPER METHODS ─────────────────────────────────────────────────────────
  Future<String> _getCategoryName(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      return (doc.data() as Map<String, dynamic>?)?['name'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  ResourceType _parseResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return ResourceType.pdf;
      case 'excel': return ResourceType.excel;
      case 'ppt': return ResourceType.ppt;
      case 'word': return ResourceType.word;
      case 'article': return ResourceType.article;
      default: return ResourceType.pdf;
    }
  }

  DifficultyLevel _parseDifficultyLevel(String level) {
    switch (level.toLowerCase()) {
      case 'intermediate': return DifficultyLevel.intermediate;
      case 'beginner':
      default: return DifficultyLevel.beginner;
    }
  }

  ResourceScope _parseResourceScope(String scope) {
    return scope.toLowerCase() == 'private' ? ResourceScope.private : ResourceScope.global;
  }

  // ─── MOCK DATA (fallback when Firebase fails) ─────────────────────────────
  List<ResourceModel> _mockResources() => [
    ResourceModel(
      id: 'r1',
      title: 'HTML Basics – Structure & Tags',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.article,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 1),
      scope: ResourceScope.global,
      isStarred: false,
      isPinned: false,
      isDone: false,
    ),
    ResourceModel(
      id: 'r2',
      title: 'CSS Cheat Sheet',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.pdf,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 3),
      scope: ResourceScope.global,
      isStarred: true,
      isPinned: true,
      isDone: false,
    ),
  ];

  List<AdminUser> _mockUsers() => [
    AdminUser(
      id: 'user1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'user',
      status: 'active',
      createdAt: DateTime(2026, 1, 1),
      uploadCount: 5,
    ),
    AdminUser(
      id: 'user2',
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'user',
      status: 'active',
      createdAt: DateTime(2026, 1, 15),
      uploadCount: 3,
    ),
  ];

  List<CategoryModel> _mockCategories() => [
    const CategoryModel(
      id: 'it',
      name: 'Information Technology',
      emoji: '💻',
      description: 'Networking, OS, security basics',
      resourceCount: 12,
    ),
    const CategoryModel(
      id: 'science',
      name: 'Science',
      emoji: '🧪',
      description: 'Physics, chemistry, biology',
      resourceCount: 8,
    ),
    const CategoryModel(
      id: 'cookery',
      name: 'Cookery',
      emoji: '🍳',
      description: 'Recipes, techniques, nutrition',
      resourceCount: 5,
    ),
  ];
}