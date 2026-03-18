import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoodLoomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MoodLoomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.surfaceColor;
    final shadowLight = isDark ? AppTheme.darkShadowLight : AppTheme.shadowLight;
    final shadowDark = isDark ? AppTheme.darkShadowDark : AppTheme.shadowDark;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : AppTheme.darkTeal.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowDark.withValues(alpha: 0.4),
            offset: const Offset(6, 6),
            blurRadius: 15,
          ),
          BoxShadow(
            color: shadowLight.withValues(alpha: 0.9),
            offset: const Offset(-6, -6),
            blurRadius: 15,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          selectedItemColor: AppTheme.primaryTeal,
          unselectedItemColor: unselectedColor,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Insights'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
