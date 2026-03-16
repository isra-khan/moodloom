import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../utils/date_helpers.dart';
import '../utils/id_generator.dart';

class MoodProvider extends ChangeNotifier {
  final DatabaseService _db;
  final SyncService _sync;

  List<MoodEntry> _allEntries = [];
  List<MoodEntry> _todayEntries = [];
  List<MoodEntry> _filteredEntries = [];
  bool _isLoading = false;

  MoodProvider(this._db, this._sync);

  List<MoodEntry> get allEntries => _allEntries;
  List<MoodEntry> get todayEntries => _todayEntries;
  List<MoodEntry> get filteredEntries => _filteredEntries;
  bool get isLoading => _isLoading;

  Future<void> loadAllEntries() async {
    _isLoading = true;
    notifyListeners();
    _allEntries = await _db.getAllEntries();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayEntries() async {
    final now = DateTime.now();
    final start = DateHelpers.startOfDay(now);
    final end = DateHelpers.endOfDay(now);
    _todayEntries = await _db.getEntriesByDateRange(start, end);
    notifyListeners();
  }

  Future<void> addMoodEntry({
    required int moodLevel,
    String? note,
    String? journalEntry,
    List<String> tags = const [],
  }) async {
    final entry = MoodEntry(
      id: IdGenerator.generate(),
      moodLevel: moodLevel,
      note: note,
      journalEntry: journalEntry,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await _db.insertMoodEntry(entry);
    await loadTodayEntries();
    await loadAllEntries();
    _sync.syncAll();
  }

  Future<void> updateEntry(MoodEntry entry) async {
    await _db.updateMoodEntry(entry.copyWith(isSynced: false));
    await loadTodayEntries();
    await loadAllEntries();
    _sync.syncAll();
  }

  Future<void> deleteEntry(String id) async {
    await _db.deleteMoodEntry(id);
    await loadTodayEntries();
    await loadAllEntries();
    _sync.syncAll();
  }

  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    _filteredEntries = await _db.getEntriesByDateRange(start, end);
    notifyListeners();
  }

  Future<void> filterByTag(String tag) async {
    _filteredEntries = await _db.getEntriesByTag(tag);
    notifyListeners();
  }

  Future<void> searchEntries(String query) async {
    _filteredEntries = await _db.searchEntries(query);
    notifyListeners();
  }

  Future<void> deleteAllEntries() async {
    await _db.deleteAllEntries();
    _allEntries = [];
    _todayEntries = [];
    _filteredEntries = [];
    notifyListeners();
  }

  List<MoodEntry> getEntriesForDate(DateTime date) {
    return _allEntries.where((e) => DateHelpers.isSameDay(e.createdAt, date)).toList();
  }

  // Insights helpers
  Map<int, int> getMoodDistribution([List<MoodEntry>? entries]) {
    final source = entries ?? _allEntries;
    final dist = <int, int>{};
    for (final e in source) {
      dist[e.moodLevel] = (dist[e.moodLevel] ?? 0) + 1;
    }
    return dist;
  }

  double getAverageMood([List<MoodEntry>? entries]) {
    final source = entries ?? _allEntries;
    if (source.isEmpty) return 0;
    return source.map((e) => e.moodLevel).reduce((a, b) => a + b) / source.length;
  }

  Map<int, double> getWeeklyAverages() {
    final now = DateTime.now();
    final weekStart = DateHelpers.startOfWeek(now);
    final averages = <int, double>{};

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayEntries = getEntriesForDate(day);
      if (dayEntries.isNotEmpty) {
        averages[i] = dayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / dayEntries.length;
      }
    }
    return averages;
  }

  String getHappiestDayOfWeek() {
    if (_allEntries.isEmpty) return 'N/A';
    final dayAverages = <int, List<int>>{};
    for (final e in _allEntries) {
      final day = e.createdAt.weekday;
      dayAverages.putIfAbsent(day, () => []).add(e.moodLevel);
    }
    int bestDay = 1;
    double bestAvg = 0;
    dayAverages.forEach((day, moods) {
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestDay = day;
      }
    });
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[bestDay];
  }

  String getMostCommonMood() {
    final dist = getMoodDistribution();
    if (dist.isEmpty) return 'N/A';
    final maxEntry = dist.entries.reduce((a, b) => a.value > b.value ? a : b);
    return MoodEntry.moodEmojis[maxEntry.key] ?? '😐';
  }

  int get totalEntries => _allEntries.length;
  int get currentStreak {
    if (_allEntries.isEmpty) return 0;
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final entries = getEntriesForDate(date);
      if (entries.isEmpty) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
