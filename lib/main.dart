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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await SupabaseService.initialize();

  final dbService = DatabaseService();
  final syncService = SyncService(dbService);

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
            home: _AppEntry(
              lockEnabled: lockEnabled,
              syncService: syncService,
            ),
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  final bool lockEnabled;
  final SyncService syncService;
  const _AppEntry({required this.lockEnabled, required this.syncService});

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _pinUnlocked = false;

  @override
  void initState() {
    super.initState();
    _pinUnlocked = !widget.lockEnabled;
    // Initialize sync after providers are built so MoodProvider catches the
    // initialSession event and refreshes when a stored session signs in.
    widget.syncService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    // Step 1: PIN lock
    if (!_pinUnlocked) {
      return LockScreen(
        onUnlocked: () => setState(() => _pinUnlocked = true),
      );
    }

    // Step 2: Wait for SharedPreferences (dark mode + onboarding flag)
    if (!settings.settingsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    // Step 3: First-launch onboarding
    if (!settings.hasSeenOnboarding) {
      return const OnboardingScreen();
    }

    // Step 4: Straight to the app. No mandatory login — guests land on Home.
    // Discover and Settings tabs handle their own sign-in gates.
    return const SplashScreen();
  }
}
