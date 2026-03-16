import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class SyncService {
  final DatabaseService _db;
  bool _isSyncing = false;
  bool _isOnline = false;
  StreamSubscription? _connectivitySub;

  final _onlineController = StreamController<bool>.broadcast();
  Stream<bool> get onlineStream => _onlineController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  SyncService(this._db);

  Future<void> initialize() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    _onlineController.add(_isOnline);

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _onlineController.add(_isOnline);
        if (_isOnline) syncAll();
      }
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing || !_isOnline || !SupabaseService.isInitialized) return;
    _isSyncing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMs = prefs.getInt('last_sync_timestamp');
      final lastSync = lastSyncMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
          : null;

      // Push unsynced entries
      final unsynced = await _db.getUnsyncedEntries();
      await SupabaseService.pushEntries(unsynced);
      for (final entry in unsynced) {
        await _db.markAsSynced(entry.id);
      }

      // Pull remote entries
      final remote = await SupabaseService.pullEntries(lastSync);
      for (final entry in remote) {
        await _db.insertMoodEntry(entry.copyWith(isSynced: true));
      }

      await prefs.setInt(
        'last_sync_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Sync failed, will retry on next connectivity change
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _onlineController.close();
  }
}
