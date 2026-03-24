import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/mood_colors.dart';

class MoodMapScreen extends StatelessWidget {
  const MoodMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, mood, _) {
            final locationEntries = mood.allEntries
                .where((e) => e.latitude != null && e.longitude != null)
                .toList();

            // Group by location name
            final locationMoods = <String, List<MoodEntry>>{};
            for (final e in locationEntries) {
              final key = e.locationName ?? '${e.latitude!.toStringAsFixed(2)}, ${e.longitude!.toStringAsFixed(2)}';
              locationMoods.putIfAbsent(key, () => []).add(e);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text('Mood Weather Map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'How you feel in different places',
                    style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 24),

                  if (locationMoods.isEmpty)
                    _buildEmpty(textColor)
                  else ...[
                    // Summary card
                    _buildSummary(locationMoods, textColor),
                    const SizedBox(height: 20),

                    Text('Your Places', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 12),

                    ..._buildLocationTiles(locationMoods, textColor),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: NeuBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No location data yet', style: TextStyle(fontSize: 16, color: textColor.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text(
                'Enable location when logging moods to see your mood map',
                style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.4)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }

  Widget _buildSummary(Map<String, List<MoodEntry>> locationMoods, Color textColor) {
    String? happiestPlace;
    double happiestAvg = 0;
    String? saddestPlace;
    double saddestAvg = 6;

    for (final entry in locationMoods.entries) {
      final avg = entry.value.map((e) => e.moodLevel).reduce((a, b) => a + b) / entry.value.length;
      if (avg > happiestAvg) {
        happiestAvg = avg;
        happiestPlace = entry.key;
      }
      if (avg < saddestAvg) {
        saddestAvg = avg;
        saddestPlace = entry.key;
      }
    }

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Location Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
          const SizedBox(height: 12),
          if (happiestPlace != null)
            _insightRow('Happiest place', happiestPlace, happiestAvg, textColor),
          if (saddestPlace != null && saddestPlace != happiestPlace) ...[
            const SizedBox(height: 8),
            _insightRow('Toughest place', saddestPlace, saddestAvg, textColor),
          ],
          const SizedBox(height: 8),
          Text(
            '${locationMoods.length} places tracked',
            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _insightRow(String label, String place, double avg, Color textColor) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6))),
        Expanded(
          child: Text(place, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor), overflow: TextOverflow.ellipsis),
        ),
        Text(MoodEntry.moodEmojis[avg.round()] ?? '😐', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(avg.toStringAsFixed(1), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6))),
      ],
    );
  }

  List<Widget> _buildLocationTiles(Map<String, List<MoodEntry>> locationMoods, Color textColor) {
    final sorted = locationMoods.entries.toList()
      ..sort((a, b) {
        final avgA = a.value.map((e) => e.moodLevel).reduce((x, y) => x + y) / a.value.length;
        final avgB = b.value.map((e) => e.moodLevel).reduce((x, y) => x + y) / b.value.length;
        return avgB.compareTo(avgA);
      });

    return sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final loc = entry.value;
      final avg = loc.value.map((e) => e.moodLevel).reduce((a, b) => a + b) / loc.value.length;
      final color = MoodColors.getColor(avg.round());

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeuBox(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(MoodEntry.moodEmojis[avg.round()] ?? '😐', style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loc.key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 2),
                    Text(
                      '${loc.value.length} entries  •  avg ${avg.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avg / 5,
                    minHeight: 6,
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: 300 + i * 80)).fadeIn().slideX(begin: 0.1, end: 0);
    }).toList();
  }
}
