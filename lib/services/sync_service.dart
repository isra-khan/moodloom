import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class SyncService {
  final DatabaseService _db;
  bool _isSyncing = false;
  bool _isOnline = false;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _authSub;

  final _onlineController = StreamController<bool>.broadcast();
  final _localDataResetController = StreamController<void>.broadcast();
  Stream<bool> get onlineStream => _onlineController.stream;
  Stream<void> get onLocalDataReset => _localDataResetController.stream;
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

    if (SupabaseService.isInitialized) {
      _authSub = SupabaseService.client!.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession) {
          if (SupabaseService.client?.auth.currentUser != null) {
            syncAll();
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _clearLocalAfterSignOut();
        }
      });
    }
  }

  Future<void> _clearLocalAfterSignOut() async {
    await _db.deleteAllEntries();
    await _db.clearAllPendingDeletes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_timestamp');
    _localDataResetController.add(null);
  }

  Future<void> syncAll() async {
    if (_isSyncing || !_isOnline || !SupabaseService.isInitialized) return;
    if (SupabaseService.client?.auth.currentUser == null) return;
    _isSyncing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncMs = prefs.getInt('last_sync_timestamp');
      final lastSync = lastSyncMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
          : null;

      // 1. Push unsynced entries (new + updated). Anonymous local rows get
      //    claimed here — pushEntries tags them with the current user_id.
      final unsynced = await _db.getUnsyncedEntries();
      await SupabaseService.pushEntries(unsynced);
      for (final entry in unsynced) {
        await _db.markAsSynced(entry.id);
      }

      // 2. Sync pending deletes to Supabase
      final pendingDeletes = await _db.getPendingDeletes();
      if (pendingDeletes.isNotEmpty) {
        await SupabaseService.deleteEntries(pendingDeletes);
        for (final id in pendingDeletes) {
          await _db.clearPendingDelete(id);
        }
      }

      // 3. Pull remote entries (uses updated_at for changes since last sync)
      final remote = await SupabaseService.pullEntries(lastSync);
      for (final entry in remote) {
        await _db.insertMoodEntry(entry.copyWith(isSynced: true));
      }

      await prefs.setInt(
        'last_sync_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      if (unsynced.isNotEmpty || remote.isNotEmpty) {
        _localDataResetController.add(null);
      }
    } catch (_) {
      // Sync failed, will retry on next connectivity change
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _authSub?.cancel();
    _onlineController.close();
    _localDataResetController.close();
  }
}
