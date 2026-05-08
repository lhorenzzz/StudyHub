// ═══════════════════════════════════════════════════════════════════════════════
// FILE: lib/core/models/admin_user.dart
// ═══════════════════════════════════════════════════════════════════════════════

// ── User status enum ──────────────────────────────────────────────────────────
// Firestore field: 'status' → 'active' | 'banned' | 'suspended'
enum UserStatus { active, banned, suspended }

extension UserStatusX on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.banned:
        return 'banned';
      case UserStatus.suspended:
        return 'suspended';
    }
  }

  static UserStatus fromString(String? s) {
    switch (s) {
      case 'banned':
        return UserStatus.banned;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }
}

// ── AdminUser model ───────────────────────────────────────────────────────────
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' | 'student' | 'moderator'
  final String status; // 'active' | 'banned' | 'suspended'
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.status = 'active',
  });

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isStudent => role == 'student';
  bool get isBanned => status == 'banned';
  bool get isSuspended => status == 'suspended';
  bool get isActive => status == 'active';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── copyWith ───────────────────────────────────────────────────────────────
  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? status,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── toMap (for Firestore writes) ───────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 🔥 FIREBASE: uncomment when Firestore is wired
  // Replace toIso8601String() with Timestamp and import cloud_firestore
  //
  // factory AdminUser.fromFirestore(Map<String, dynamic> d, String docId) {
  //   return AdminUser(
  //     id:        docId,
  //     name:      d['name']   ?? '',
  //     email:     d['email']  ?? '',
  //     role:      d['role']   ?? 'student',
  //     status:    d['status'] ?? 'active',
  //     createdAt: (d['created_at'] as Timestamp).toDate(),
  //   );
  // }

  // ── Dummy factory (used by AdminRepository until Firebase is wired) ────────
  factory AdminUser.dummy({
    required String id,
    required String name,
    required String email,
    String role = 'student',
    String status = 'active',
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      role: role,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'AdminUser(id: $id, name: $name, role: $role, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
