import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'discover_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    DiscoverScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: MoodLoomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
