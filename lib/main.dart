import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tag_provider.dart';
import 'services/app_lock_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'services/sync_service.dart';
import 'screens/auth/login_screen.dart';
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
            home: _AppEntry(lockEnabled: lockEnabled),
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  final bool lockEnabled;
  const _AppEntry({required this.lockEnabled});

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _pinUnlocked = false;
  bool _authChecked = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _pinUnlocked = !widget.lockEnabled;
    _checkAuth();
  }

  void _checkAuth() {
    _isLoggedIn = AuthService.isLoggedIn;
    _authChecked = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: PIN lock
    if (!_pinUnlocked) {
      return LockScreen(
        onUnlocked: () => setState(() => _pinUnlocked = true),
      );
    }

    // Step 2: Auth check
    if (!_authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    // Step 3: Login or Splash
    if (!_isLoggedIn && SupabaseService.isInitialized) {
      return LoginScreen(
        onLoginSuccess: () => setState(() {
          _isLoggedIn = true;
        }),
      );
    }

    return const SplashScreen();
  }
}
