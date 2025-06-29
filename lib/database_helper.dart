import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    final path = join(dbPath, 'diary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('entries', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().substring(0, 10);
    final maps = await db.query(
      'entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
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

  Future<List<DiaryEntry>> searchEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      'entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => DiaryEntry.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}