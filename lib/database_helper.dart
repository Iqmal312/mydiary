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
    final path = join(dbPath, 'diary_v1.db'); // Versioned database name

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            date TEXT NOT NULL,
            mood TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_date ON entries(date)');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // Handle future migrations here
      },
    );
  }

  // CRUD operations with error handling
  Future<int> insertEntry(DiaryEntry entry) async {
    try {
      final db = await database;
      return await db.insert('entries', entry.toMap());
    } catch (e) {
      debugPrint('Insert error: $e');
      return -1;
    }
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      final db = await database;
      final maps = await db.query('entries', orderBy: 'date DESC');
      return maps.map((map) => DiaryEntry.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Query error: $e');
      return [];
    }
  }

  // Add these methods to your existing DatabaseHelper class
Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
  final db = await database;
  final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD format
  final maps = await db.query(
    'entries',
    where: 'date LIKE ?',
    whereArgs: ['$dateStr%'],
    orderBy: 'date DESC',
  );
  return maps.map((map) => DiaryEntry.fromMap(map)).toList();
}

Future<List<DiaryEntry>> searchEntries(String query) async {
  final db = await database;
  final maps = await db.query(
    'entries',
    where: 'title LIKE ? OR content LIKE ?',
    whereArgs: ['%$query%', '%$query%'],
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

  // Close database when done
  Future<void> close() async {
    if (_database != null) await _database!.close();
  }
}