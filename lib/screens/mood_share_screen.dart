import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mood_entry.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';

class MoodShareScreen extends StatelessWidget {
  final List<MoodEntry> entries;
  final DateTime date;

  const MoodShareScreen({super.key, required this.entries, required this.date});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final avgMood = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.moodLevel).reduce((a, b) => a + b) / entries.length;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  NeuButton(
                    onPressed: () => Navigator.pop(context),
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Share Mood',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 32),
              // Preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: AppTheme.tealGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('🌿 MoodLoom', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 16),
                    Text(
                      DateHelpers.formatDate(date),
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      const Text('No moods logged', style: TextStyle(fontSize: 18, color: Colors.white))
                    else ...[
                      Text(
                        entries.map((e) => e.emoji).join(' '),
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Average mood: ${avgMood.toStringAsFixed(1)}/5',
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                        style: const TextStyle(fontSize: 14, color: Colors.white60),
                      ),
                      if (entries.any((e) => e.tags.isNotEmpty)) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: entries
                              .expand((e) => e.tags)
                              .toSet()
                              .take(5)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => _shareMood(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.tealGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Share', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _shareMood(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('🌿 MoodLoom - ${DateHelpers.formatDate(date)}');
    buffer.writeln();

    if (entries.isEmpty) {
      buffer.writeln('No moods logged today.');
    } else {
      for (final e in entries) {
        buffer.write('${e.emoji} ${e.label} at ${DateHelpers.formatTime(e.createdAt)}');
        if (e.note?.isNotEmpty == true) buffer.write(' - ${e.note}');
        buffer.writeln();
      }
      final avg = entries.map((e) => e.moodLevel).reduce((a, b) => a + b) / entries.length;
      buffer.writeln();
      buffer.writeln('Average: ${avg.toStringAsFixed(1)}/5');
    }

    Share.share(buffer.toString());
  }
}
