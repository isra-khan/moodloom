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
  int _previousIndex = 0;

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isForward = _currentIndex >= _previousIndex;
          final offsetTween = Tween<Offset>(
            begin: Offset(isForward ? 0.05 : -0.05, 0),
            end: Offset.zero,
          );
          return SlideTransition(
            position: offsetTween.animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: MoodLoomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
