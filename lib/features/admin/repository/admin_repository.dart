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

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' | 'student'
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  // TODO (backend): map from your API response JSON
  // factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
  //   id: json['id'].toString(),
  //   name: json['name'],
  //   email: json['email'],
  //   role: json['role'],
  //   createdAt: DateTime.parse(json['created_at']),
  // );
}

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
  Future<void> uploadResource({
    required String title,
    required String description,
    required String categoryId,
    required String difficulty,
    required String tags,
    required String fileName,
    required String fileType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: use http.MultipartRequest for actual file upload
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

  // ─── MOCK DATA (remove when backend is connected) ─────────────────────────
  List<ResourceModel> _mockResources() => [
    ResourceModel(
      id: 'r1',
      title: 'HTML Basics – Structure & Tags',
      categoryId: 'it',
      categoryName: 'Information Technology',
      difficulty: DifficultyLevel.beginner, // 'beginner',
      type: ResourceType.article,
      uploadedBy: 'admin',
      uploadedAt: DateTime(2026, 4, 1),
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
      createdAt: DateTime(2026, 3, 1),
    ),
    AdminUser(
      id: 'u2',
      name: 'John Hermie Tatel',
      email: 'jhermie@email.com',
      role: 'student',
      createdAt: DateTime(2026, 3, 5),
    ),
    AdminUser(
      id: 'u3',
      name: 'Jun Amaro',
      email: 'jun@email.com',
      role: 'student',
      createdAt: DateTime(2026, 3, 10),
    ),
    AdminUser(
      id: 'u4',
      name: 'Ronnie Vargas',
      email: 'ronnie@email.com',
      role: 'student',
      createdAt: DateTime(2026, 3, 12),
    ),
    AdminUser(
      id: 'u5',
      name: 'Admin User',
      email: 'admin@studyhub.com',
      role: 'admin',
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
