import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/mood_colors.dart';
import '../widgets/emoji_widget.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _showComparison = false;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, mood, _) {
            if (mood.allEntries.isEmpty) {
              return Center(
                child: NeuBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const EmojiWidget(emoji: '📊', size: 48),
                      const SizedBox(height: 12),
                      Text('No data yet', style: TextStyle(fontSize: 18, color: textColor.withValues(alpha: 0.6))),
                      const SizedBox(height: 4),
                      Text('Start logging moods to see insights', style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insights',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 24),

                  // Stats cards
                  Row(
                    children: [
                      _InsightCard(emoji: '🔥', label: 'Streak', value: '${mood.currentStreak} days'),
                      const SizedBox(width: 12),
                      _InsightCard(emoji: '😊', label: 'Most Common', value: mood.getMostCommonMood()),
                    ],
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InsightCard(emoji: '🌟', label: 'Happiest Day', value: mood.getHappiestDayOfWeek()),
                      const SizedBox(width: 12),
                      _InsightCard(emoji: '📈', label: 'Average', value: mood.getAverageMood().toStringAsFixed(1)),
                    ],
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Weekly bar chart with comparison toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showComparison ? 'Week Comparison' : 'This Week',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      NeuButton(
                        onPressed: () => setState(() => _showComparison = !_showComparison),
                        borderRadius: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              _showComparison ? Icons.bar_chart : Icons.compare_arrows,
                              size: 16,
                              color: AppTheme.primaryTeal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showComparison ? 'Single' : 'Compare',
                              style: const TextStyle(fontSize: 12, color: AppTheme.primaryTeal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  NeuBox(
                    child: SizedBox(
                      height: 200,
                      child: _showComparison
                          ? _buildComparisonChart(mood)
                          : _buildWeeklyChart(mood),
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Mood distribution
                  Text('Mood Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  NeuBox(
                    child: SizedBox(height: 220, child: _buildDistributionChart(mood)),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Mood triggers/patterns
                  Text('Tag Patterns', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  _buildTagPatterns(mood)
                      .animate(delay: 450.ms)
                      .fadeIn()
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),

                  // Breakdown
                  Text('Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  _buildMoodBreakdown(mood).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(MoodProvider mood) {
    final weeklyAvg = mood.getWeeklyAverages();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final textColor = Theme.of(context).colorScheme.onSurface;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${days[group.x]} ${rod.toY.toStringAsFixed(1)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(days[value.toInt()], style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          final avg = weeklyAvg[i] ?? 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: avg,
                width: 22,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: avg > 0
                      ? [MoodColors.getColor(avg.round()).withValues(alpha: 0.4), MoodColors.getColor(avg.round())]
                      : [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.2)],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildComparisonChart(MoodProvider mood) {
    final now = DateTime.now();
    final thisWeekStart = DateHelpers.startOfWeek(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final textColor = Theme.of(context).colorScheme.onSurface;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(days[value.toInt()], style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.5)));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          final thisDay = thisWeekStart.add(Duration(days: i));
          final lastDay = lastWeekStart.add(Duration(days: i));
          final thisEntries = mood.getEntriesForDate(thisDay);
          final lastEntries = mood.getEntriesForDate(lastDay);

          double thisAvg = 0;
          double lastAvg = 0;
          if (thisEntries.isNotEmpty) {
            thisAvg = thisEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / thisEntries.length;
          }
          if (lastEntries.isNotEmpty) {
            lastAvg = lastEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / lastEntries.length;
          }

          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: lastAvg,
                width: 10,
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.accentTeal.withValues(alpha: 0.5),
              ),
              BarChartRodData(
                toY: thisAvg,
                width: 10,
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.primaryTeal,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDistributionChart(MoodProvider mood) {
    final dist = mood.getMoodDistribution();
    final total = dist.values.fold(0, (a, b) => a + b);
    if (total == 0) return const Center(child: Text('No data'));

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: dist.entries.map((e) {
          final pct = (e.value / total * 100).round();
          return PieChartSectionData(
            value: e.value.toDouble(),
            title: '${MoodEntry.moodEmojis[e.key]} $pct%',
            color: MoodColors.getColor(e.key),
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagPatterns(MoodProvider mood) {
    // Calculate average mood per tag
    final tagMoods = <String, List<int>>{};
    for (final entry in mood.allEntries) {
      for (final tag in entry.tags) {
        tagMoods.putIfAbsent(tag, () => []).add(entry.moodLevel);
      }
    }

    if (tagMoods.isEmpty) {
      return NeuBox(
        child: Center(
          child: Text(
            'Add tags to your entries to see patterns',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final textColor = Theme.of(context).colorScheme.onSurface;
    final sortedTags = tagMoods.entries.toList()
      ..sort((a, b) {
        final avgA = a.value.reduce((x, y) => x + y) / a.value.length;
        final avgB = b.value.reduce((x, y) => x + y) / b.value.length;
        return avgB.compareTo(avgA);
      });

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activities & their mood correlation',
            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 12),
          ...sortedTags.take(8).map((entry) {
            final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  EmojiWidget(emoji: MoodEntry.moodEmojis[avg.round()] ?? '😐', size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avg / 5,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(MoodColors.getColor(avg.round())),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown(MoodProvider mood) {
    final dist = mood.getMoodDistribution();
    final total = dist.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();
    final textColor = Theme.of(context).colorScheme.onSurface;

    return NeuBox(
      child: Column(
        children: [5, 4, 3, 2, 1].map((level) {
          final count = dist[level] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                EmojiWidget(emoji: MoodEntry.moodEmojis[level]!, size: 24),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Text(MoodEntry.moodLabels[level]!, style: TextStyle(fontSize: 13, color: textColor)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(MoodColors.getColor(level)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _InsightCard({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Expanded(
      child: NeuBox(
        child: Column(
          children: [
            EmojiWidget(emoji: emoji, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}
