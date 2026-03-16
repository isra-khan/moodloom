import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../services/app_lock_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'custom_moods_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _appLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService.isReminderEnabled();
    final time = await NotificationService.getReminderTime();
    final lockEnabled = await AppLockService.isEnabled();
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        if (time != null) _reminderTime = time;
        _appLockEnabled = lockEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 24),

              // Dark Mode
              NeuBox(
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryTeal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return Switch(
                          value: settings.isDarkMode,
                          activeThumbColor: AppTheme.primaryTeal,
                          activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          inactiveThumbColor: AppTheme.lightTeal,
                          inactiveTrackColor: AppTheme.lightTeal.withValues(alpha: 0.3),
                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          onChanged: (_) => settings.toggleDarkMode(),
                        );
                      },
                    ),
                  ],
                ),
              ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Custom Mood Scale
              NeuButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const CustomMoodsScreen(),
                  ));
                },
                child: Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined, color: AppTheme.primaryTeal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Custom Mood Scale',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.4)),
                  ],
                ),
              ).animate(delay: 75.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // App Lock
              NeuBox(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppTheme.primaryTeal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'App Lock (PIN)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: _appLockEnabled,
                          activeThumbColor: AppTheme.primaryTeal,
                          activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          inactiveThumbColor: AppTheme.lightTeal,
                          inactiveTrackColor: AppTheme.lightTeal.withValues(alpha: 0.3),
                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          onChanged: (value) async {
                            if (value) {
                              _showSetPinDialog();
                            } else {
                              await AppLockService.disableLock();
                              if (!mounted) return;
                              setState(() => _appLockEnabled = false);
                              context.read<SettingsProvider>().setAppLockEnabled(false);
                            }
                          },
                        ),
                      ],
                    ),
                    if (_appLockEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'A PIN will be required when opening the app',
                          style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Reminders
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined, color: AppTheme.primaryTeal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Daily Reminder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Switch(
                          value: _reminderEnabled,
                          activeThumbColor: AppTheme.primaryTeal,
                          activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          inactiveThumbColor: AppTheme.lightTeal,
                          inactiveTrackColor: AppTheme.lightTeal.withValues(alpha: 0.3),
                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          onChanged: (value) async {
                            setState(() => _reminderEnabled = value);
                            if (value) {
                              await NotificationService.requestPermissions();
                              await NotificationService.scheduleDailyReminder(_reminderTime);
                            } else {
                              await NotificationService.cancelReminder();
                            }
                          },
                        ),
                      ],
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime,
                          );
                          if (time != null) {
                            setState(() => _reminderTime = time);
                            await NotificationService.scheduleDailyReminder(time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, size: 18, color: AppTheme.primaryTeal),
                              const SizedBox(width: 8),
                              Text(
                                _reminderTime.format(context),
                                style: TextStyle(fontSize: 15, color: textColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Export
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.file_download_outlined, color: AppTheme.primaryTeal),
                        const SizedBox(width: 12),
                        Text(
                          'Export Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: NeuButton(
                            onPressed: () => _export('csv'),
                            child: const Text('Export CSV', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeuButton(
                            onPressed: () => _export('json'),
                            child: const Text('Export JSON', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Privacy
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.primaryTeal),
                        const SizedBox(width: 12),
                        Text(
                          'Privacy & Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All your data is stored locally on your device. Supabase sync is optional.',
                      style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 12),
                    NeuButton(
                      onPressed: _confirmDeleteAll,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete All Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Account & Sync
              if (SupabaseService.isInitialized)
                NeuBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud_sync_outlined, color: AppTheme.primaryTeal),
                          const SizedBox(width: 12),
                          Text(
                            'Account & Sync',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (AuthService.isLoggedIn) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Signed in',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                                    ),
                                    Text(
                                      AuthService.currentUser?.email ?? '',
                                      style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeuButton(
                          onPressed: () async {
                            await AuthService.signOut();
                            if (mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Not signed in. Data is stored locally only.',
                                  style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate(delay: 275.ms).fadeIn().slideY(begin: 0.1, end: 0),
              if (SupabaseService.isInitialized) const SizedBox(height: 16),

              // About
              NeuBox(
                child: Column(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('MoodLoom', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.5))),
                    const SizedBox(height: 4),
                    Text('Weave your wellness', style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.4))),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _export(String format) {
    final entries = context.read<MoodProvider>().allEntries;
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No data to export'),
          backgroundColor: AppTheme.primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (format == 'csv') {
      ExportService.exportAsCsv(entries);
    } else {
      ExportService.exportAsJson(entries);
    }
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set PIN', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4-digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (pinController.text.length == 4) {
                await AppLockService.setPin(pinController.text);
                setState(() => _appLockEnabled = true);
                if (mounted) {
                  context.read<SettingsProvider>().setAppLockEnabled(true);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Set', style: TextStyle(color: AppTheme.primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete All Data', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: const Text('This will permanently delete all your mood data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<MoodProvider>().deleteAllEntries();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data deleted'),
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
