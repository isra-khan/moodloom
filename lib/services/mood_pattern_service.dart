import '../models/mood_entry.dart';
import '../utils/date_helpers.dart';

class MoodAlert {
  final String title;
  final String message;
  final String emoji;
  final MoodAlertType type;

  const MoodAlert({
    required this.title,
    required this.message,
    required this.emoji,
    required this.type,
  });
}

enum MoodAlertType { warning, positive, tip }

class MoodPatternService {
  static List<MoodAlert> analyzePatterns(List<MoodEntry> entries) {
    if (entries.isEmpty) return [];
    final alerts = <MoodAlert>[];

    // Check downward trend (3+ days)
    final downTrend = _checkDownwardTrend(entries);
    if (downTrend != null) alerts.add(downTrend);

    // Check upward trend
    final upTrend = _checkUpwardTrend(entries);
    if (upTrend != null) alerts.add(upTrend);

    // Check recurring bad day of week
    final badDay = _checkWeekdayPattern(entries);
    if (badDay != null) alerts.add(badDay);

    // Check tag impact
    final tagAlert = _checkTagImpact(entries);
    if (tagAlert != null) alerts.add(tagAlert);

    // Check streak celebration
    final streak = _checkStreak(entries);
    if (streak != null) alerts.add(streak);

    // Check low mood persistence
    final lowMood = _checkLowMoodPersistence(entries);
    if (lowMood != null) alerts.add(lowMood);

    // Check if weekends are better
    final weekendAlert = _checkWeekendPattern(entries);
    if (weekendAlert != null) alerts.add(weekendAlert);

    return alerts;
  }

  static MoodAlert? _checkDownwardTrend(List<MoodEntry> entries) {
    final now = DateTime.now();
    final dailyAvgs = <double>[];

    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, date)).toList();
      if (dayEntries.isEmpty) continue;
      dailyAvgs.add(dayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / dayEntries.length);
    }

    if (dailyAvgs.length < 3) return null;

    int declining = 0;
    for (int i = 0; i < dailyAvgs.length - 1; i++) {
      if (dailyAvgs[i] < dailyAvgs[i + 1]) declining++;
    }

    if (declining >= 3) {
      return const MoodAlert(
        title: 'Downward Trend',
        message: "Your mood has been declining over the past few days. Consider doing something you enjoy or talking to someone you trust.",
        emoji: '📉',
        type: MoodAlertType.warning,
      );
    }
    return null;
  }

  static MoodAlert? _checkUpwardTrend(List<MoodEntry> entries) {
    final now = DateTime.now();
    final dailyAvgs = <double>[];

    for (int i = 0; i < 5; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, date)).toList();
      if (dayEntries.isEmpty) continue;
      dailyAvgs.add(dayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / dayEntries.length);
    }

    if (dailyAvgs.length < 3) return null;

    int improving = 0;
    for (int i = 0; i < dailyAvgs.length - 1; i++) {
      if (dailyAvgs[i] > dailyAvgs[i + 1]) improving++;
    }

    if (improving >= 3) {
      return const MoodAlert(
        title: 'Rising Mood!',
        message: "You're on an upward trend! Whatever you're doing is working. Keep it up!",
        emoji: '📈',
        type: MoodAlertType.positive,
      );
    }
    return null;
  }

  static MoodAlert? _checkWeekdayPattern(List<MoodEntry> entries) {
    if (entries.length < 14) return null;

    final dayMoods = <int, List<int>>{};
    for (final e in entries) {
      dayMoods.putIfAbsent(e.createdAt.weekday, () => []).add(e.moodLevel);
    }

    int worstDay = 1;
    double worstAvg = 5;
    for (final entry in dayMoods.entries) {
      if (entry.value.length < 2) continue;
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg < worstAvg) {
        worstAvg = avg;
        worstDay = entry.key;
      }
    }

    if (worstAvg < 2.5) {
      const days = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
      return MoodAlert(
        title: '${days[worstDay]} are tough',
        message: 'Your mood tends to dip on ${days[worstDay]}. Try planning something uplifting!',
        emoji: '📅',
        type: MoodAlertType.tip,
      );
    }
    return null;
  }

  static MoodAlert? _checkTagImpact(List<MoodEntry> entries) {
    if (entries.length < 10) return null;

    final tagMoods = <String, List<int>>{};
    for (final e in entries) {
      for (final tag in e.tags) {
        tagMoods.putIfAbsent(tag, () => []).add(e.moodLevel);
      }
    }

    String? bestTag;
    double bestAvg = 0;
    for (final entry in tagMoods.entries) {
      if (entry.value.length < 3) continue;
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestTag = entry.key;
      }
    }

    if (bestTag != null && bestAvg >= 3.5) {
      return MoodAlert(
        title: '$bestTag boosts your mood!',
        message: 'You tend to feel great when "$bestTag" is part of your day. Try to do more of it!',
        emoji: '✨',
        type: MoodAlertType.positive,
      );
    }
    return null;
  }

  static MoodAlert? _checkStreak(List<MoodEntry> entries) {
    int streak = 0;
    var date = DateTime.now();
    while (true) {
      final dayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, date)).toList();
      if (dayEntries.isEmpty) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    if (streak >= 7) {
      return MoodAlert(
        title: '$streak-day streak!',
        message: "Incredible consistency! You've logged your mood for $streak days in a row. Self-awareness is a superpower!",
        emoji: '🔥',
        type: MoodAlertType.positive,
      );
    }
    return null;
  }

  static MoodAlert? _checkLowMoodPersistence(List<MoodEntry> entries) {
    final now = DateTime.now();
    final recent = entries.where(
      (e) => e.createdAt.isAfter(now.subtract(const Duration(days: 5))),
    ).toList();

    if (recent.length < 3) return null;

    final allLow = recent.every((e) => e.moodLevel <= 2);
    if (allLow) {
      return const MoodAlert(
        title: 'Extended low mood',
        message: "You've been feeling low for several days. Remember it's okay to reach out for support. Consider talking to someone you trust.",
        emoji: '💙',
        type: MoodAlertType.warning,
      );
    }
    return null;
  }

  static MoodAlert? _checkWeekendPattern(List<MoodEntry> entries) {
    if (entries.length < 21) return null;

    final weekdayMoods = <int>[];
    final weekendMoods = <int>[];

    for (final e in entries) {
      if (e.createdAt.weekday >= 6) {
        weekendMoods.add(e.moodLevel);
      } else {
        weekdayMoods.add(e.moodLevel);
      }
    }

    if (weekdayMoods.length < 5 || weekendMoods.length < 3) return null;

    final weekdayAvg = weekdayMoods.reduce((a, b) => a + b) / weekdayMoods.length;
    final weekendAvg = weekendMoods.reduce((a, b) => a + b) / weekendMoods.length;

    if (weekendAvg - weekdayAvg > 0.8) {
      return const MoodAlert(
        title: 'Weekend boost',
        message: "You're noticeably happier on weekends. Try bringing elements of weekend activities into your weekdays!",
        emoji: '🎯',
        type: MoodAlertType.tip,
      );
    }
    return null;
  }
}
