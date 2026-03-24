import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/mood_entry.dart';
import '../models/dream_entry.dart';
import '../models/time_capsule.dart';

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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mood_entries(
            id TEXT PRIMARY KEY,
            mood_level INTEGER NOT NULL,
            note TEXT,
            journal_entry TEXT,
            tags TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_synced INTEGER DEFAULT 0,
            latitude REAL,
            longitude REAL,
            location_name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_tags(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE pending_deletes(
            id TEXT PRIMARY KEY,
            deleted_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE dream_entries(
            id TEXT PRIMARY KEY,
            description TEXT NOT NULL,
            sleep_quality INTEGER NOT NULL,
            remembered INTEGER DEFAULT 1,
            tags TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE time_capsules(
            id TEXT PRIMARY KEY,
            message TEXT NOT NULL,
            mood_when_written INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            unlock_at TEXT NOT NULL,
            is_opened INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE mood_entries ADD COLUMN updated_at TEXT",
          );
          await db.execute(
            "UPDATE mood_entries SET updated_at = created_at WHERE updated_at IS NULL",
          );
          await db.execute('''
            CREATE TABLE IF NOT EXISTS pending_deletes(
              id TEXT PRIMARY KEY,
              deleted_at TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          // Add location columns to mood_entries
          await db.execute("ALTER TABLE mood_entries ADD COLUMN latitude REAL");
          await db.execute("ALTER TABLE mood_entries ADD COLUMN longitude REAL");
          await db.execute("ALTER TABLE mood_entries ADD COLUMN location_name TEXT");
          // Create dream_entries table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS dream_entries(
              id TEXT PRIMARY KEY,
              description TEXT NOT NULL,
              sleep_quality INTEGER NOT NULL,
              remembered INTEGER DEFAULT 1,
              tags TEXT,
              created_at TEXT NOT NULL
            )
          ''');
          // Create time_capsules table
          await db.execute('''
            CREATE TABLE IF NOT EXISTS time_capsules(
              id TEXT PRIMARY KEY,
              message TEXT NOT NULL,
              mood_when_written INTEGER NOT NULL,
              created_at TEXT NOT NULL,
              unlock_at TEXT NOT NULL,
              is_opened INTEGER DEFAULT 0
            )
          ''');
        }
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

  /// Delete locally and queue for remote deletion on next sync
  Future<void> deleteMoodEntryAndTrack(String id) async {
    final db = await database;
    await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
    await db.insert(
      'pending_deletes',
      {'id': id, 'deleted_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getPendingDeletes() async {
    final db = await database;
    final maps = await db.query('pending_deletes');
    return maps.map((m) => m['id'] as String).toList();
  }

  Future<void> clearPendingDelete(String id) async {
    final db = await database;
    await db.delete('pending_deletes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllPendingDeletes() async {
    final db = await database;
    await db.delete('pending_deletes');
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

  // --- Dream Journal ---
  Future<void> insertDreamEntry(DreamEntry entry) async {
    final db = await database;
    await db.insert('dream_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<DreamEntry>> getAllDreamEntries() async {
    final db = await database;
    final maps = await db.query('dream_entries', orderBy: 'created_at DESC');
    return maps.map((map) => DreamEntry.fromMap(map)).toList();
  }

  Future<void> deleteDreamEntry(String id) async {
    final db = await database;
    await db.delete('dream_entries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Time Capsules ---
  Future<void> insertTimeCapsule(TimeCapsule capsule) async {
    final db = await database;
    await db.insert('time_capsules', capsule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TimeCapsule>> getAllTimeCapsules() async {
    final db = await database;
    final maps = await db.query('time_capsules', orderBy: 'unlock_at ASC');
    return maps.map((map) => TimeCapsule.fromMap(map)).toList();
  }

  Future<void> openTimeCapsule(String id) async {
    final db = await database;
    await db.update('time_capsules', {'is_opened': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTimeCapsule(String id) async {
    final db = await database;
    await db.delete('time_capsules', where: 'id = ?', whereArgs: [id]);
  }

  // --- Location-based mood queries ---
  Future<List<MoodEntry>> getEntriesWithLocation() async {
    final db = await database;
    final maps = await db.query(
      'mood_entries',
      where: 'latitude IS NOT NULL AND longitude IS NOT NULL',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }
}
