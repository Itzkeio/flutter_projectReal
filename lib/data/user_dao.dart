import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class UserEntity {
  final int? id;
  final String? uid;
  final String email;
  final String passwordHash;
  final String? displayName;
  final String? role;
  final String? photoPath;
  final int createdAt;
  final int updatedAt;
  final int? lastLoginAt;

  UserEntity({
    this.id,
    this.uid,
    required this.email,
    required this.passwordHash,
    this.displayName,
    this.role,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  UserEntity copyWith({
    int? id,
    String? uid,
    String? email,
    String? passwordHash,
    String? displayName,
    String? role,
    String? photoPath,
    int? createdAt,
    int? updatedAt,
    int? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'uid': uid,
        'email': email,
        'password_hash': passwordHash,
        'display_name': displayName,
        'role': role,
        'photo_path': photoPath,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'last_login_at': lastLoginAt,
      };

  static UserEntity fromMap(Map<String, Object?> m) => UserEntity(
        id: m['id'] as int?,
        uid: m['uid'] as String?,
        email: m['email'] as String,
        passwordHash: m['password_hash'] as String,
        displayName: m['display_name'] as String?,
        role: m['role'] as String?,
        photoPath: m['photo_path'] as String?,
        createdAt: m['created_at'] as int,
        updatedAt: m['updated_at'] as int,
        lastLoginAt: m['last_login_at'] as int?,
      );
}

class UserDao {
  Future<Database> get _db async => AppDatabase().database;

  Future<UserEntity?> findByEmail(String email) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserEntity.fromMap(rows.first);
  }

  Future<int> insert(UserEntity user) async {
    final db = await _db;
    return db.insert('users', user.toMap());
  }

  Future<int> update(UserEntity user) async {
    final db = await _db;
    return db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> touchLogin(int id) async {
    final db = await _db;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.update(
      'users',
      {'updated_at': now, 'last_login_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
    Future<UserEntity?> getLastLoggedInUser() async {
    final db = await _db;
    final rows = await db.query(
      'users',
      orderBy: 'last_login_at DESC, updated_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserEntity.fromMap(rows.first);
  }
}

