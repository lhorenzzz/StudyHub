import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._();
  UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── GET GLOBAL RESOURCES ───────────────────────────────────────────────────
  Future<List<ResourceModel>> getGlobalResources({
    String search = '',
    String categoryId = '',
    String difficulty = '',
  }) async {
    try {
      Query query = _firestore
          .collection('resources')
          .where('scope', isEqualTo: 'global')
          .orderBy('uploadedAt', descending: true);

      if (categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (difficulty.isNotEmpty) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();

      List<ResourceModel> resources = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tagsList = data['tags'] is List
            ? List<String>.from(data['tags'] as List)
            : <String>[];
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
          uploadedByName: (data['uploadedByName'] as String?) ?? '',
          uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          fileUrl: (data['fileUrl'] as String?) ?? '',
          scope: ResourceScope.global,
        );
      }).toList();

      if (search.isNotEmpty) {
        resources = resources.where((r) =>
          r.title.toLowerCase().contains(search.toLowerCase()) ||
          r.description.toLowerCase().contains(search.toLowerCase()) ||
          r.tags.any((tag) => tag.toLowerCase().contains(search.toLowerCase()))
        ).toList();
      }

      return resources;
    } catch (e) {
      print('Firebase getGlobalResources error: $e');
      return [];
    }
  }

  // ── GET MY RESOURCES ───────────────────────────────────────────────────────
  Future<List<ResourceModel>> getMyResources(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('resources')
          .where('uploadedBy', isEqualTo: userId)
          .get();

      final resources = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tagsList = data['tags'] is List
            ? List<String>.from(data['tags'] as List)
            : <String>[];
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

      // Sort client-side — no composite index needed
      resources.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return resources;
    } catch (e) {
      print('Firebase getMyResources error: $e');
      return [];
    }
  }

  // ── GET SAVED RESOURCES ────────────────────────────────────────────────────
  Future<List<ResourceModel>> getSavedResources(String userId) async {
    try {
      final savedSnapshot = await _firestore
          .collection('saved_resources')
          .where('savedBy', isEqualTo: userId)
          .get();

      if (savedSnapshot.docs.isEmpty) return [];

      final resourceIds = savedSnapshot.docs
          .map((doc) => doc.data()['resourceId'] as String)
          .toList();

      final resourcesSnapshot = await _firestore
          .collection('resources')
          .where(FieldPath.documentId, whereIn: resourceIds)
          .get();

      final resources = resourcesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tagsList = data['tags'] is List
            ? List<String>.from(data['tags'] as List)
            : <String>[];
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
          isStarred: true,
        );
      }).toList();

      // Sort client-side
      resources.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return resources;
    } catch (e) {
      print('Firebase getSavedResources error: $e');
      return [];
    }
  }

  // ── GET CATEGORIES ─────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('name')
          .get();

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
      print('Firebase getCategories error: $e');
      return [];
    }
  }

  // ── SAVE / UNSAVE RESOURCE ─────────────────────────────────────────────────
  Future<void> saveResource(String resourceId, String userId) async {
    try {
      await _firestore
          .collection('saved_resources')
          .doc('${userId}_$resourceId')
          .set({
        'resourceId': resourceId,
        'savedBy': userId,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unsaveResource(String resourceId, String userId) async {
    try {
      await _firestore
          .collection('saved_resources')
          .doc('${userId}_$resourceId')
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isResourceSaved(String resourceId, String userId) async {
    try {
      final doc = await _firestore
          .collection('saved_resources')
          .doc('${userId}_$resourceId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
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
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('resources').add({
        'title'          : title,
        'description'    : description,
        'categoryId'     : categoryId,
        'categoryName'   : await _getCategoryName(categoryId),
        'difficulty'     : difficulty,
        'tags'           : tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        'fileName'       : fileName,
        'fileType'       : fileType,
        'fileUrl'        : '',
        'scope'          : 'global',
        'uploadedBy'     : user.uid,
        'uploadedByName' : user.displayName ?? user.email?.split('@').first ?? 'Unknown',
        'uploadedAt'     : FieldValue.serverTimestamp(),
      });

      await _firestore.collection('categories').doc(categoryId).update({
        'resourceCount': FieldValue.increment(1),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ── UPDATE RESOURCE STATE ──────────────────────────────────────────────────
  Future<void> updateResourceState(
    String resourceId, {
    bool? isStarred,
    bool? isPinned,
    bool? isDone,
    DateTime? lastOpenedAt,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (isStarred != null) updates['isStarred'] = isStarred;
      if (isPinned != null) updates['isPinned'] = isPinned;
      if (isDone != null) updates['isDone'] = isDone;
      if (lastOpenedAt != null) updates['lastOpenedAt'] = Timestamp.fromDate(lastOpenedAt);

      if (updates.isNotEmpty) {
        await _firestore.collection('resources').doc(resourceId).update(updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Future<String> _getCategoryName(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      return doc.data()?['name'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  ResourceType _parseResourceType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf'    : return ResourceType.pdf;
      case 'excel'  : return ResourceType.excel;
      case 'ppt'    : return ResourceType.ppt;
      case 'word'   : return ResourceType.word;
      case 'article': return ResourceType.article;
      default       : return ResourceType.pdf;
    }
  }

  DifficultyLevel _parseDifficultyLevel(String level) {
    switch (level.toLowerCase()) {
      case 'intermediate': return DifficultyLevel.intermediate;
      default            : return DifficultyLevel.beginner;
    }
  }

  ResourceScope _parseResourceScope(String scope) {
    return scope.toLowerCase() == 'private'
        ? ResourceScope.private
        : ResourceScope.global;
  }
}