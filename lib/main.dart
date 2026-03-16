import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tag_provider.dart';
import 'services/app_lock_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';
import 'screens/lock_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await SupabaseService.initialize();

  final dbService = DatabaseService();
  final syncService = SyncService(dbService);
  await syncService.initialize();

  final lockEnabled = await AppLockService.isEnabled();

  runApp(MoodLoomApp(
    dbService: dbService,
    syncService: syncService,
    lockEnabled: lockEnabled,
  ));
}

class MoodLoomApp extends StatelessWidget {
  final DatabaseService dbService;
  final SyncService syncService;
  final bool lockEnabled;

  const MoodLoomApp({
    super.key,
    required this.dbService,
    required this.syncService,
    required this.lockEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodProvider(dbService, syncService),
        ),
        ChangeNotifierProvider(
          create: (_) => TagProvider(dbService)..loadTags(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'MoodLoom',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: lockEnabled
                ? _LockedApp(onUnlocked: () {})
                : const SplashScreen(),
          );
        },
      ),
    );
  }
}

class _LockedApp extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _LockedApp({required this.onUnlocked});

  @override
  State<_LockedApp> createState() => _LockedAppState();
}

class _LockedAppState extends State<_LockedApp> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return const SplashScreen();
    return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
  }
}
