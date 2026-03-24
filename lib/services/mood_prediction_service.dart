import '../models/mood_entry.dart';
import '../utils/date_helpers.dart';

class MoodForecast {
  final double predictedMood;
  final String confidence; // 'Low', 'Medium', 'High'
  final String reason;
  final Map<String, double> factors;

  MoodForecast({
    required this.predictedMood,
    required this.confidence,
    required this.reason,
    required this.factors,
  });

  String get emoji => MoodEntry.moodEmojis[predictedMood.round()] ?? '😐';
  String get label => MoodEntry.moodLabels[predictedMood.round()] ?? 'Okay';

  String get weatherIcon {
    final level = predictedMood.round();
    switch (level) {
      case 1: return '⛈️';
      case 2: return '🌧️';
      case 3: return '⛅';
      case 4: return '🌤️';
      case 5: return '☀️';
      default: return '⛅';
    }
  }

  String get weatherLabel {
    final level = predictedMood.round();
    switch (level) {
      case 1: return 'Stormy';
      case 2: return 'Rainy';
      case 3: return 'Partly Cloudy';
      case 4: return 'Mostly Sunny';
      case 5: return 'Bright & Sunny';
      default: return 'Partly Cloudy';
    }
  }
}

class MoodPredictionService {
  static MoodForecast? predictTomorrow(List<MoodEntry> entries) {
    if (entries.length < 5) return null;

    final factors = <String, double>{};
    double totalWeight = 0;
    double weightedSum = 0;

    // Factor 1: Day-of-week pattern (weight: 3)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowWeekday = tomorrow.weekday;
    final sameDayEntries = entries.where((e) => e.createdAt.weekday == tomorrowWeekday).toList();
    if (sameDayEntries.isNotEmpty) {
      final dayAvg = sameDayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / sameDayEntries.length;
      factors['Day of week'] = dayAvg;
      weightedSum += dayAvg * 3;
      totalWeight += 3;
    }

    // Factor 2: Recent trend (last 7 days, weight: 4)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEntries = entries.where((e) => e.createdAt.isAfter(weekAgo)).toList();
    if (recentEntries.isNotEmpty) {
      final recentAvg = recentEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / recentEntries.length;
      factors['Recent trend'] = recentAvg;
      weightedSum += recentAvg * 4;
      totalWeight += 4;
    }

    // Factor 3: Yesterday's mood (weight: 2) - momentum
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayEntries = entries.where((e) => DateHelpers.isSameDay(e.createdAt, yesterday)).toList();
    if (yesterdayEntries.isNotEmpty) {
      final yesterdayAvg = yesterdayEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / yesterdayEntries.length;
      factors['Yesterday'] = yesterdayAvg;
      weightedSum += yesterdayAvg * 2;
      totalWeight += 2;
    }

    // Factor 4: Overall average (weight: 1) - baseline
    final overallAvg = entries.map((e) => e.moodLevel).reduce((a, b) => a + b) / entries.length;
    factors['Baseline'] = overallAvg;
    weightedSum += overallAvg * 1;
    totalWeight += 1;

    if (totalWeight == 0) return null;

    final predicted = weightedSum / totalWeight;

    // Determine confidence based on data consistency
    String confidence;
    String reason;
    if (entries.length >= 30 && sameDayEntries.length >= 4) {
      confidence = 'High';
      reason = _buildReason(factors, tomorrowWeekday);
    } else if (entries.length >= 14) {
      confidence = 'Medium';
      reason = _buildReason(factors, tomorrowWeekday);
    } else {
      confidence = 'Low';
      reason = 'Based on limited data. Keep logging for better predictions!';
    }

    return MoodForecast(
      predictedMood: predicted.clamp(1.0, 5.0),
      confidence: confidence,
      reason: reason,
      factors: factors,
    );
  }

  static String _buildReason(Map<String, double> factors, int weekday) {
    const days = ['', 'Mondays', 'Tuesdays', 'Wednesdays', 'Thursdays', 'Fridays', 'Saturdays', 'Sundays'];
    final parts = <String>[];

    if (factors.containsKey('Day of week')) {
      final dayAvg = factors['Day of week']!;
      if (dayAvg >= 3.5) {
        parts.add('You usually feel good on ${days[weekday]}');
      } else if (dayAvg < 2.5) {
        parts.add('${days[weekday]} tend to be tougher for you');
      }
    }

    if (factors.containsKey('Recent trend')) {
      final recent = factors['Recent trend']!;
      if (recent >= 3.5) {
        parts.add("you've been on an upward trend");
      } else if (recent < 2.5) {
        parts.add("you've had a rough week");
      }
    }

    if (parts.isEmpty) return 'Based on your mood history and patterns';
    return parts.join(' and ');
  }

  /// Get trend direction over last N days
  static String getTrendDirection(List<MoodEntry> entries, {int days = 7}) {
    if (entries.length < 3) return 'stable';

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    final recent = entries.where((e) => e.createdAt.isAfter(cutoff)).toList();
    if (recent.length < 2) return 'stable';

    recent.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final firstHalf = recent.sublist(0, recent.length ~/ 2);
    final secondHalf = recent.sublist(recent.length ~/ 2);

    final firstAvg = firstHalf.map((e) => e.moodLevel).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.moodLevel).reduce((a, b) => a + b) / secondHalf.length;

    final diff = secondAvg - firstAvg;
    if (diff > 0.3) return 'improving';
    if (diff < -0.3) return 'declining';
    return 'stable';
  }
}
