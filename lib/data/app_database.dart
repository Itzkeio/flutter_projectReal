import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  AppDatabase._();
  factory AppDatabase() => _instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'app_auth.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel users mirip field Firestore-mu
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT UNIQUE,             -- opsional, kalau mau punya uid string
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            display_name TEXT,
            role TEXT,
            photo_path TEXT,             -- simpan path file lokal (lebih hemat)
            created_at INTEGER NOT NULL, -- epoch millis
            updated_at INTEGER NOT NULL,
            last_login_at INTEGER
          );
        ''');
        // Kamu bisa tambahkan index email
        await db.execute('CREATE INDEX idx_users_email ON users(email);');
      },
    );
  }
}
