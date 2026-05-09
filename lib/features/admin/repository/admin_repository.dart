// ─────────────────────────────────────────────────────────────────────────────
// AdminRepository
//
// BACKEND TEAM INSTRUCTIONS:
// This file is the ONLY file you need to modify to connect the real API.
// Each method has a comment showing the exact endpoint to call.
// Replace the mock return values with actual http calls.
//
// Recommended package: http (already common in Flutter projects)
// Base URL: set your base URL in the constant below.
//
// Example pattern for replacing mock data:
//   final res = await http.get(Uri.parse('$_base/admin/stats'));
//   return AdminStats.fromJson(jsonDecode(res.body));
// ─────────────────────────────────────────────────────────────────────────────
import 'package:study_hub/core/models/admin_user.dart';
import 'package:study_hub/core/models/resource_model.dart';
import 'package:study_hub/core/models/category_model.dart';

// ── Backend base URL ──────────────────────────────────────────────────────────
// TODO (backend): Replace with your actual server URL
const String _base = 'http://localhost/studyhub/api';

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

  // TODO (backend): map from your API response JSON
  // factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
  //   totalResources: json['total_resources'],
  //   totalUsers: json['total_users'],
  //   totalCategories: json['total_categories'],
  // );
}

// TODO (backend): map from your API response JSON
// factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
//   id: json['id'].toString(),
//   name: json['name'],
//   email: json['email'],
//   role: json['role'],
//   createdAt: DateTime.parse(json['created_at']),
// );

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORY CLASS
// ─────────────────────────────────────────────────────────────────────────────

class AdminRepository {
  // Singleton so BLoC always uses the same instance
  static final AdminRepository instance = AdminRepository._();
  AdminRepository._();

  // ── STATS ──────────────────────────────────────────────────────────────────
  // TODO (backend): GET /api/admin/stats
  // Response: { total_resources: int, total_users: int, total_categories: int }
  Future<AdminStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network
    return const AdminStats(
      totalResources: 25,
      totalUsers: 48,
      totalCategories: 4,
    );
  }

  // ── RESOURCES ──────────────────────────────────────────────────────────────
  // TODO (backend): GET /api/admin/resources?search=&category=&difficulty=
  // Response: [ { id, title, category_id, category_name, difficulty,
  //              file_type, uploaded_by, uploaded_at, description } ]
  Future<List<ResourceModel>> getResources({
    String search = '',
    String categoryId = '',
    String difficulty = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = _mockResources();
    return all.where((r) {
      final matchSearch =
          search.isEmpty ||
          r.title.toLowerCase().contains(search.toLowerCase());
      final matchCat = categoryId.isEmpty || r.categoryId == categoryId;
      final matchDiff = difficulty.isEmpty || r.difficulty == difficulty;
      return matchSearch && matchCat && matchDiff;
    }).toList();
  }

  // TODO (backend): DELETE /api/admin/resources/:id
  // Response: { success: true }
  Future<void> deleteResource(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: await http.delete(Uri.parse('$_base/admin/resources/$id'));
  }

  // TODO (backend): POST /api/admin/resources/upload
  // Body (multipart form): title, description, category_id, difficulty,
  //                        tags, file (binary)
  // Response: { success: true, resource: { ...ResourceModel fields } }
  // 🔥 FIREBASE: full upload flow for backend team:
  //   STEP 1 — Upload file to Firebase Storage:
  //     final storageRef = FirebaseStorage.instance.ref(
  //       scope == 'global'
  //         ? 'resources/global/$categoryId/${DateTime.now().millisecondsSinceEpoch}_$fileName'
  //         : 'resources/private/${FirebaseAuth.instance.currentUser!.uid}/$fileName',
  //     );
  //     await storageRef.putFile(File(filePath));   // mobile/desktop
  //     // await storageRef.putData(fileBytes);     // web
  //     final fileUrl = await storageRef.getDownloadURL();
  //
  //   STEP 2 — Save metadata to Firestore:
  //     await FirebaseFirestore.instance.collection('resources').add({
  //       'title':         title,
  //       'description':   description,
  //       'category_id':   categoryId,
  //       'category_name': (look up from categories collection by categoryId),
  //       'difficulty':    difficulty,
  //       'tags':          tags.split(',').map((t) => t.trim()).toList(),
  //       'file_name':     fileName,
  //       'file_type':     fileType,
  //       'file_url':      fileUrl,              // ← from STEP 1
  //       'scope':         scope,                // 'global' | 'private'
  //       'uploaded_by':   FirebaseAuth.instance.currentUser!.uid,
  //       'uploaded_at':   FieldValue.serverTimestamp(),
  //     });
  //
  //   STEP 3 — If scope == 'global', increment category count:
  //     await FirebaseFirestore.instance
  //       .collection('categories')
  //       .doc(categoryId)
  //       .update({'global_resource_count': FieldValue.increment(1)});
  Future<void> uploadResource({
    required String title,
    required String description,
    required String categoryId,
    required String difficulty,
    required String tags,
    required String fileName,
    required String fileType,
    String scope = 'global', // ✅ added
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: implement full Firebase upload — see comments above
  }

  // In admin_repository.dart:
  Future<void> saveResourceToMyResources({
    required String resourceId,
    required String adminId,
  }) async {
    // 🔥 FIREBASE: Creates a bookmark document in saved_resources collection
    // await FirebaseFirestore.instance
    //   .collection('saved_resources')
    //   .doc('${adminId}_$resourceId')   // ← composite key prevents duplicates
    //   .set({
    //     'resource_id':  resourceId,
    //     'saved_by':     adminId,
    //     'saved_at':     FieldValue.serverTimestamp(),
    //   });

    // 🗑️ DUMMY — no-op until Firebase is connected
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<bool> isResourceSaved({
    required String resourceId,
    required String adminId,
  }) async {
    // 🔥 FIREBASE:
    // final doc = await FirebaseFirestore.instance
    //   .collection('saved_resources')
    //   .doc('${adminId}_$resourceId')
    //   .get();
    // return doc.exists;
    return false;
  }

  Future<void> unsaveResource({
    required String resourceId,
    required String adminId,
  }) async {
    // 🔥 FIREBASE:
    // await FirebaseFirestore.instance
    //   .collection('saved_resources')
    //   .doc('${adminId}_$resourceId')
    //   .delete();
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── USERS ──────────────────────────────────────────────────────────────────
  // TODO (backend): GET /api/admin/users?search=
  // Response: [ { id, name, email, role, created_at } ]
  Future<List<AdminUser>> getUsers({String search = ''}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = _mockUsers();
    if (search.isEmpty) return all;
    return all
        .where(
          (u) =>
              u.name.toLowerCase().contains(search.toLowerCase()) ||
              u.email.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
  }

  // TODO (backend): DELETE /api/admin/users/:id
  // Response: { success: true }
  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: await http.delete(Uri.parse('$_base/admin/users/$id'));
  }

  // ── BAN USER ────────────────────────────────────────────────────────────────
  // 🔥 FIREBASE: TWO steps required:
  //   STEP 1 — Update Firestore status field:
  //     await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .update({'status': 'banned'});
  //
  //   STEP 2 — Disable Firebase Auth account via Cloud Function:
  //     await FirebaseFunctions.instance
  //       .httpsCallable('banUser')
  //       .call({'uid': userId});
  //
  //   Cloud Function (index.js):
  //     exports.banUser = functions.https.onCall(async (data, context) => {
  //       await admin.auth().updateUser(data.uid, { disabled: true });
  //       return { success: true };
  //     });
  Future<void> banUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: implement Firebase steps above
  }

  // ── SUSPEND USER ─────────────────────────────────────────────────────────────
  // 🔥 FIREBASE:
  //   await FirebaseFirestore.instance
  //     .collection('users')
  //     .doc(userId)
  //     .update({'status': 'suspended'});
  //   // Suspension is Firestore-only (no Auth disable)
  //   // App checks 'status' field on login and blocks suspended users
  Future<void> suspendUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: implement Firebase step above
  }

  // ── UNBAN / REINSTATE USER ────────────────────────────────────────────────────
  // 🔥 FIREBASE: TWO steps required (reverse of banUser):
  //   STEP 1 — Update Firestore status field:
  //     await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .update({'status': 'active'});
  //
  //   STEP 2 — Re-enable Firebase Auth account via Cloud Function:
  //     await FirebaseFunctions.instance
  //       .httpsCallable('unbanUser')
  //       .call({'uid': userId});
  //
  //   Cloud Function (index.js):
  //     exports.unbanUser = functions.https.onCall(async (data, context) => {
  //       await admin.auth().updateUser(data.uid, { disabled: false });
  //       return { success: true };
  //     });
  Future<void> unbanUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: implement Firebase steps above
  }

  // ── CATEGORIES ─────────────────────────────────────────────────────────────
  // TODO (backend): GET /api/admin/categories
  // Response: [ { id, name, description, emoji, resource_count } ]
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories();
  }

  // TODO (backend): POST /api/admin/categories
  // Body: { name, description, emoji }
  // Response: { success: true, category: { ...CategoryModel fields } }
  Future<void> addCategory({
    required String name,
    required String description,
    required String emoji,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: await http.post(Uri.parse('$_base/admin/categories'), body: {...});
  }

  // TODO (backend): PUT /api/admin/categories/:id
  // Body: { name, description, emoji }
  // Response: { success: true }
  Future<void> editCategory({
    required String id,
    required String name,
    required String description,
    required String emoji,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: await http.put(Uri.parse('$_base/admin/categories/$id'), body: {...});
  }

  // TODO (backend): DELETE /api/admin/categories/:id
  // Response: { success: true }
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // TODO: await http.delete(Uri.parse('$_base/admin/categories/$id'));
  }

  // ─── MOCK DATA (remove when backend is connected) ────────────────────────
  List<ResourceModel> _mockResources() => [
    // 🔥 FIREBASE: replace this entire list with:
    //   final snapshot = await FirebaseFirestore.instance
    //     .collection('resources')
    //     .orderBy('uploaded_at', descending: true)
    //     .get();
    //   return snapshot.docs
    //     .map((d) => ResourceModel.fromFirestore(d.data(), d.id))
    //     .toList();
    ResourceModel(
      id: 'r1',
      title: 'HTML Basics – Structure & Tags',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.article,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 1),
      scope: ResourceScope.global, // 🔥 FIREBASE: from Firestore 'scope' field
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
      scope: ResourceScope.private, // ✅ private — only shows in My Resources
      isStarred: true,
      isPinned: true,
      isDone: false,
    ),
    ResourceModel(
      id: 'r3',
      title: 'Python Variables & Data Types',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.pdf,
      uploadedBy: 'student1',
      uploadedAt: DateTime(2026, 4, 5),
      scope: ResourceScope
          .global, // 🔥 FIREBASE: student uploads → global by default
      isStarred: true,
      isPinned: false,
      isDone: false,
    ),
    ResourceModel(
      id: 'r4',
      title: 'OSI Model Reference Sheet',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.pdf,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 6),
      scope: ResourceScope.global,
      isStarred: false,
      isPinned: false,
      isDone: false,
    ),
    ResourceModel(
      id: 'r5',
      title: 'Basic Chemistry Notes',
      categoryId: 'science',
      categoryName: 'Science',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.word,
      uploadedBy: 'student2',
      uploadedAt: DateTime(2026, 4, 7),
      scope: ResourceScope.global,
      isStarred: false,
      isPinned: false,
      isDone: false,
    ),
    ResourceModel(
      id: 'r6',
      title: 'Knife Skills & Cutting Techniques',
      categoryId: 'cookery',
      categoryName: 'Cookery',
      difficulty: DifficultyLevel.beginner,
      type: ResourceType.ppt,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 8),
      scope: ResourceScope.global,
      isStarred: true,
      isPinned: true,
      isDone: false,
    ),
  ];
  List<AdminUser> _mockUsers() => [
    AdminUser(
      id: 'u1',
      name: 'Lhorenz Magtibay',
      email: 'lhorenz@email.com',
      role: 'student',
      status: 'active',
      createdAt: DateTime(2026, 3, 1),
    ),
    AdminUser(
      id: 'u2',
      name: 'John Hermie Tatel',
      email: 'jhermie@email.com',
      role: 'student',
      status: 'active',
      createdAt: DateTime(2026, 3, 5),
    ),
    AdminUser(
      id: 'u3',
      name: 'Jun Amaro',
      email: 'jun@email.com',
      role: 'student',
      status: 'active',
      createdAt: DateTime(2026, 3, 10),
    ),
    AdminUser(
      id: 'u4',
      name: 'Ronnie Vargas',
      email: 'ronnie@email.com',
      role: 'student',
      status: 'active',
      createdAt: DateTime(2026, 3, 12),
    ),
    AdminUser(
      id: 'u5',
      name: 'Admin User',
      email: 'admin@studyhub.com',
      role: 'admin',
      status: 'active',
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  List<CategoryModel> _mockCategories() => [
    CategoryModel(
      id: 'it',
      name: 'Information Technology',
      description: 'Networking, OS, security basics',
      emoji: '💻',
      resourceCount: 12,
    ),
    CategoryModel(
      id: 'science',
      name: 'Science',
      description: 'Physics, chemistry, biology',
      emoji: '🧪',
      resourceCount: 8,
    ),
    CategoryModel(
      id: 'cookery',
      name: 'Cookery',
      description: 'Recipes, techniques, nutrition',
      emoji: '🍳',
      resourceCount: 5,
    ),
    CategoryModel(
      id: 'math',
      name: 'Mathematics',
      description: 'Algebra, calculus, statistics',
      emoji: '📐',
      resourceCount: 0,
    ),
  ];
}
