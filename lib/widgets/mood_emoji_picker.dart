import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/mood_entry.dart';
import '../theme/app_theme.dart';
import '../utils/mood_colors.dart';

class MoodEmojiPicker extends StatelessWidget {
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodEmojiPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final level = index + 1;
        final isSelected = selectedMood == level;
        return GestureDetector(
          onTap: () => onMoodSelected(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: isSelected ? 72 : 56,
            height: isSelected ? 72 : 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? MoodColors.getColor(level).withValues(alpha: 0.2)
                  : AppTheme.surfaceColor,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: MoodColors.getColor(level), width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: MoodColors.getColor(level).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.shadowDark.withValues(alpha: 0.3),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: AppTheme.shadowLight.withValues(alpha: 0.8),
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                MoodEntry.moodEmojis[level]!,
                style: TextStyle(fontSize: isSelected ? 36 : 28),
              ),
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
      }),
    );
  }
}
