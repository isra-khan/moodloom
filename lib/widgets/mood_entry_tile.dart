import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import 'emoji_widget.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/mood_colors.dart';

class MoodEntryTile extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MoodEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: 'mood_emoji_${entry.id}',
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      MoodColors.getColor(entry.moodLevel).withValues(alpha: 0.3),
                      MoodColors.getColor(entry.moodLevel).withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: EmojiWidget(emoji: entry.emoji, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateHelpers.formatTime(entry.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.darkTeal.withValues(alpha: 0.6),
                    ),
                  ),
                  if (entry.note?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkTeal.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  if (entry.tags.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: entry.tags
                          .take(3)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.darkTeal),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.5), size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
