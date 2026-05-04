import 'package:flutter/foundation.dart';
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
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = DatabaseService();
  final syncService = SyncService(dbService);
  runApp(MoodLoomApp(dbService: dbService, syncService: syncService));
}

class MoodLoomApp extends StatelessWidget {
  final DatabaseService dbService;
  final SyncService syncService;

  const MoodLoomApp({
    super.key,
    required this.dbService,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          lazy: false,
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
            home: _AppEntry(syncService: syncService),
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  final SyncService syncService;
  const _AppEntry({required this.syncService});

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _pinUnlocked = true;
  bool _lockResolved = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _bootstrap() {
    // All of these are intentionally fire-and-forget so the first frame can
    // draw immediately. The UI gates below show a spinner until the lock
    // check resolves; everything else runs invisibly in the background.

    NotificationService.initialize().catchError((e) {
      if (kDebugMode) debugPrint('NotificationService init failed: $e');
    });

    // SyncService.initialize subscribes to Supabase auth events, so it must
    // run only after the Supabase client exists. Chain with .then().
    SupabaseService.initialize().then((_) {
      widget.syncService.initialize();
    }).catchError((e) {
      if (kDebugMode) debugPrint('Supabase/Sync init failed: $e');
    });

    AppLockService.isEnabled().then((enabled) {
      if (!mounted) return;
      setState(() {
        _pinUnlocked = !enabled;
        _lockResolved = true;
      });
    }).catchError((e) {
      if (kDebugMode) debugPrint('AppLock check failed: $e');
      if (mounted) setState(() => _lockResolved = true);
    });
  }

  Widget _loadingScaffold() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryTeal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    // Step 0: Wait for the lock check before deciding PIN vs. straight-in.
    if (!_lockResolved) return _loadingScaffold();

    // Step 1: PIN lock
    if (!_pinUnlocked) {
      return LockScreen(
        onUnlocked: () => setState(() => _pinUnlocked = true),
      );
    }

    // Step 2: Wait for SharedPreferences (dark mode + onboarding flag)
    if (!settings.settingsLoaded) return _loadingScaffold();

    // Step 3: First-launch onboarding
    if (!settings.hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    // Step 4: Straight to the app. No mandatory login — guests land on Home.
    // Discover and Settings tabs handle their own sign-in gates.
    return const SplashScreen();
  }
}
