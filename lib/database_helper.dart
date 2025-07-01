import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'diary_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diary_app.db');

    return await openDatabase(
      path,
      version: 2, // bump version if you want to reset DB
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL
          )
        ''');


        // Create diary entries table
        await db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            mood TEXT NOT NULL,
            imagePath TEXT,
            userId INTEGER,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        await db.execute('CREATE INDEX idx_date ON entries(date)');
        onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Check if userId already exists before adding (optional)
        await db.execute('ALTER TABLE entries ADD COLUMN userId INTEGER');
      }
        };
      },
    );
  }

  // ---------------- AUTH METHODS ----------------

  Future<bool> registerUser(String email, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
  final db = await database;
  final result = await db.query(
    'users',
    columns: ['id', 'email', 'password'], // <-- make sure 'id' is included
    where: 'email = ? AND password = ?',
    whereArgs: [email, password],
  );
  return result.isNotEmpty ? result.first : null;
}


  // ---------------- DIARY METHODS ----------------

  Future<void> insertEntry(DiaryEntry entry) async {
  final db = await database;
  try {
    debugPrint("🔍 Inserting entry: ${entry.toMap()}");
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    debugPrint("❌ insertEntry failed: $e");
    rethrow; // let it bubble up so you can see it in the error log
  }
}


  Future<List<DiaryEntry>> getAllEntries({int? userId}) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: userId != null ? 'userId = ?' : null,
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'date DESC',
    );
    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> getEntriesByUserId(int userId) async {
  final db = await database;
  final maps = await db.query(
    'entries',
    where: 'userId = ?',
    whereArgs: [userId],
    orderBy: 'date DESC',
  );
  return maps.map((map) => DiaryEntry.fromMap(map)).toList();
}


  Future<List<DiaryEntry>> getEntriesForDate(DateTime date, {int? userId}) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'entries',
      where: 'date LIKE ? AND userId = ?',
      whereArgs: ['$dateStr%', userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> searchEntries(String query, {int? userId}) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: '(title LIKE ? OR content LIKE ?) AND userId = ?',
      whereArgs: ['%$query%', '%$query%', userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    if (_database != null) await _database!.close();
  }
}
