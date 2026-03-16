import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mood_entry.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://ekmydubqsweovjbhvlnt.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbXlkdWJxc3dlb3ZqYmh2bG50Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5NzIwNzAsImV4cCI6MjA3OTU0ODA3MH0.X9VLQcPKz07567QzT2Eu5RV-pTQJsJBa7oyMHOV4dDI';

  static bool _initialized = false;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  static bool get isInitialized => _initialized;
  static SupabaseClient? get client => _initialized ? Supabase.instance.client : null;

  static Future<void> pushEntries(List<MoodEntry> entries) async {
    final c = client;
    if (c == null || entries.isEmpty) return;
    final user = c.auth.currentUser;
    if (user == null) return;

    for (final entry in entries) {
      await c.from('mood_entries').upsert(entry.toSupabase(user.id));
    }
  }

  static Future<List<MoodEntry>> pullEntries(DateTime? lastSync) async {
    final c = client;
    if (c == null) return [];
    final user = c.auth.currentUser;
    if (user == null) return [];

    var query = c.from('mood_entries').select().eq('user_id', user.id);

    if (lastSync != null) {
      query = query.gt('created_at', lastSync.toIso8601String());
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => MoodEntry.fromSupabase(e)).toList();
  }

  static Future<void> deleteEntry(String id) async {
    final c = client;
    if (c == null) return;
    await c.from('mood_entries').delete().eq('id', id);
  }

  static Future<void> deleteAllEntries() async {
    final c = client;
    if (c == null) return;
    final user = c.auth.currentUser;
    if (user == null) return;
    await c.from('mood_entries').delete().eq('user_id', user.id);
  }
}
