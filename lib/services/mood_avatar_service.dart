import '../models/mood_entry.dart';
import '../utils/date_helpers.dart';

enum TreeStage { withered, wilting, steady, healthy, blooming }

class TreeDecoration {
  final bool hasFlowers;
  final bool hasBirds;
  final bool hasButterflies;
  final bool hasRainbow;
  final bool hasRain;
  final bool hasSunshine;
  final bool hasFairyLights;
  final bool hasStars;
  final int leafCount; // 0-12

  const TreeDecoration({
    this.hasFlowers = false,
    this.hasBirds = false,
    this.hasButterflies = false,
    this.hasRainbow = false,
    this.hasRain = false,
    this.hasSunshine = false,
    this.hasFairyLights = false,
    this.hasStars = false,
    this.leafCount = 6,
  });
}

class AvatarState {
  final TreeStage stage;
  final TreeDecoration decoration;
  final String message;
  final String emoji;
  final double health; // 0.0 to 1.0
  final int streak;
  final double recentAvg;

  const AvatarState({
    required this.stage,
    required this.decoration,
    required this.message,
    required this.emoji,
    required this.health,
    required this.streak,
    required this.recentAvg,
  });
}

class MoodAvatarService {
  static AvatarState calculateState(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const AvatarState(
        stage: TreeStage.steady,
        decoration: TreeDecoration(leafCount: 3),
        message: "Your tree is waiting for its first drop of sunlight. Log a mood to start growing!",
        emoji: '🌱',
        health: 0.5,
        streak: 0,
        recentAvg: 3.0,
      );
    }

    // Calculate streak
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final dayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, date)).toList();
      if (dayEntries.isEmpty) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    // Calculate recent average (last 7 days)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEntries = entries.where((e) => e.createdAt.isAfter(weekAgo)).toList();
    double recentAvg = 3.0;
    if (recentEntries.isNotEmpty) {
      recentAvg = recentEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / recentEntries.length;
    }

    // Calculate today's average
    final todayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, DateTime.now())).toList();
    double todayAvg = recentAvg;
    if (todayEntries.isNotEmpty) {
      todayAvg = todayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / todayEntries.length;
    }

    // Determine health (0.0 - 1.0)
    final health = ((recentAvg - 1) / 4).clamp(0.0, 1.0);

    // Determine tree stage
    TreeStage stage;
    if (recentAvg >= 4.0) {
      stage = TreeStage.blooming;
    } else if (recentAvg >= 3.3) {
      stage = TreeStage.healthy;
    } else if (recentAvg >= 2.5) {
      stage = TreeStage.steady;
    } else if (recentAvg >= 1.5) {
      stage = TreeStage.wilting;
    } else {
      stage = TreeStage.withered;
    }

    // Determine decorations
    final hasFlowers = recentAvg >= 4.0 && streak >= 3;
    final hasBirds = recentAvg >= 4.5 && streak >= 5;
    final hasButterflies = streak >= 7;
    final hasRainbow = todayAvg >= 3.5 && recentAvg < 3.0; // recovering from bad week
    final hasRain = todayAvg <= 2.0;
    final hasSunshine = todayAvg >= 4.0 && !hasRain;
    final hasFairyLights = streak >= 14;
    final hasStars = entries.length >= 50;
    final leafCount = (recentAvg * 2.4).round().clamp(0, 12);

    final decoration = TreeDecoration(
      hasFlowers: hasFlowers,
      hasBirds: hasBirds,
      hasButterflies: hasButterflies,
      hasRainbow: hasRainbow,
      hasRain: hasRain,
      hasSunshine: hasSunshine,
      hasFairyLights: hasFairyLights,
      hasStars: hasStars,
      leafCount: leafCount,
    );

    // Determine message
    final message = _buildMessage(stage, streak, todayAvg, recentAvg, todayEntries.isEmpty, entries.length);
    final emoji = _getEmoji(stage, decoration);

    return AvatarState(
      stage: stage,
      decoration: decoration,
      message: message,
      emoji: emoji,
      health: health,
      streak: streak,
      recentAvg: recentAvg,
    );
  }

  static String _buildMessage(TreeStage stage, int streak, double todayAvg, double recentAvg, bool noEntriesToday, int totalEntries) {
    if (noEntriesToday) {
      if (streak > 0) {
        return "Your tree missed you today! Log a mood to keep your $streak-day streak alive.";
      }
      return "Your tree is thirsty! Water it by logging how you feel.";
    }

    switch (stage) {
      case TreeStage.blooming:
        if (streak >= 7) {
          return "Magnificent! Your tree is in full bloom with a $streak-day streak! Keep shining!";
        }
        return "Your tree is blooming beautifully! Your positive energy is showing.";
      case TreeStage.healthy:
        return "Your tree is growing strong. Steady progress is still progress!";
      case TreeStage.steady:
        if (todayAvg > recentAvg) {
          return "A brighter day today! Your tree feels the warmth.";
        }
        return "Your tree stands steady. Even calm days help roots grow deeper.";
      case TreeStage.wilting:
        if (todayAvg > recentAvg) {
          return "A little sunshine today! Your tree is perking up.";
        }
        return "A little rain today. That's okay — growth needs rain too.";
      case TreeStage.withered:
        return "Your tree is going through a storm. Remember: every storm passes, and roots grow deeper in the rain.";
    }
  }

  static String _getEmoji(TreeStage stage, TreeDecoration decoration) {
    if (decoration.hasFlowers) return '🌸';
    switch (stage) {
      case TreeStage.blooming: return '🌳';
      case TreeStage.healthy: return '🌿';
      case TreeStage.steady: return '🪴';
      case TreeStage.wilting: return '🍂';
      case TreeStage.withered: return '🥀';
    }
  }

  /// Get milestones the user has achieved
  static List<AvatarMilestone> getMilestones(List<MoodEntry> entries, int streak) {
    final milestones = <AvatarMilestone>[];

    if (entries.isNotEmpty) milestones.add(const AvatarMilestone('🌱', 'Seed Planted', 'Logged your first mood'));
    if (entries.length >= 10) milestones.add(const AvatarMilestone('🌿', 'Sprout', '10 moods logged'));
    if (entries.length >= 25) milestones.add(const AvatarMilestone('🪴', 'Sapling', '25 moods logged'));
    if (entries.length >= 50) milestones.add(const AvatarMilestone('🌳', 'Young Tree', '50 moods logged'));
    if (entries.length >= 100) milestones.add(const AvatarMilestone('🌲', 'Mighty Oak', '100 moods logged'));
    if (streak >= 3) milestones.add(const AvatarMilestone('💧', 'Consistent', '3-day streak'));
    if (streak >= 7) milestones.add(const AvatarMilestone('🦋', 'Butterfly Effect', '7-day streak'));
    if (streak >= 14) milestones.add(const AvatarMilestone('✨', 'Fairy Lights', '14-day streak'));
    if (streak >= 30) milestones.add(const AvatarMilestone('👑', 'Tree Guardian', '30-day streak'));

    return milestones;
  }
}

class AvatarMilestone {
  final String emoji;
  final String title;
  final String description;

  const AvatarMilestone(this.emoji, this.title, this.description);
}
