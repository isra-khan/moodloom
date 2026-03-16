import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moodloom.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mood_entries(
            id TEXT PRIMARY KEY,
            mood_level INTEGER NOT NULL,
            note TEXT,
            journal_entry TEXT,
            tags TEXT,
            created_at TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_tags(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertMoodEntry(MoodEntry entry) async {
    final db = await database;
    await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMoodEntry(MoodEntry entry) async {
    final db = await database;
    await db.update(
      'mood_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteMoodEntry(String id) async {
    final db = await database;
    await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query('mood_entries', orderBy: 'created_at DESC');
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getEntriesByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getEntriesByTag(String tag) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getUnsyncedEntries() async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'is_synced = 0',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'mood_entries',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getCustomTags() async {
    final db = await database;
    final maps = await db.query('custom_tags', orderBy: 'name ASC');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> addCustomTag(String tag) async {
    final db = await database;
    await db.insert(
      'custom_tags',
      {'name': tag},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCustomTag(String tag) async {
    final db = await database;
    await db.delete('custom_tags', where: 'name = ?', whereArgs: [tag]);
  }

  Future<void> deleteAllEntries() async {
    final db = await database;
    await db.delete('mood_entries');
  }

  Future<List<MoodEntry>> searchEntries(String query) async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'note LIKE ? OR journal_entry LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }
}
