import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/mood_entry.dart';
import 'emoji_widget.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.surfaceColor;

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
                  : bgColor,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: MoodColors.getColor(level), width: 3)
                  : Border.all(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.06)),
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
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Center(
              child: EmojiWidget(
                emoji: MoodEntry.moodEmojis[level]!,
                size: isSelected ? 36 : 28,
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
