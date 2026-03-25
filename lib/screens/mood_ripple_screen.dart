import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/mood_colors.dart';
import '../widgets/emoji_widget.dart';

class MoodRippleScreen extends StatefulWidget {
  const MoodRippleScreen({super.key});

  @override
  State<MoodRippleScreen> createState() => _MoodRippleScreenState();
}

class _MoodRippleScreenState extends State<MoodRippleScreen> {
  Map<int, double> _communityMoods = {};
  bool _isLoading = true;
  bool _hasContributed = false;

  @override
  void initState() {
    super.initState();
    _loadCommunityPulse();
  }

  Future<void> _loadCommunityPulse() async {
    final mood = context.read<MoodProvider>();
    _hasContributed = mood.todayEntries.isNotEmpty;

    // Generate community distribution (simulate)
    // In production, this would be: supabase.from('mood_entries').select().eq('date', today)
    final distribution = <int, double>{
      1: 8 + (DateTime.now().millisecond % 5),
      2: 14 + (DateTime.now().second % 8),
      3: 28 + (DateTime.now().minute % 10),
      4: 30 + (DateTime.now().hour % 8),
      5: 20 + (DateTime.now().day % 6),
    };

    // Normalize to percentages
    final total = distribution.values.reduce((a, b) => a + b);
    final normalized = distribution.map((k, v) => MapEntry(k, (v / total) * 100));

    if (mounted) {
      setState(() {
        _communityMoods = normalized;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  Text('Mood Ripple', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                "See how the world is feeling today",
                style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                ))
              else ...[
                // Community pulse visualization
                _buildPulseCircle(textColor),
                const SizedBox(height: 24),

                // Distribution bars
                Text('Community Mood', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 12),
                NeuBox(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((level) {
                      final pct = _communityMoods[level] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            EmojiWidget(emoji: MoodEntry.moodEmojis[level]!, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  minHeight: 14,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(MoodColors.getColor(level)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 42,
                              child: Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                // Contribution status
                NeuBox(
                  child: Row(
                    children: [
                      EmojiWidget(emoji: _hasContributed ? '✅' : '💤', size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasContributed
                                  ? "You've contributed today!"
                                  : "You haven't logged a mood today",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                            ),
                            Text(
                              _hasContributed
                                  ? 'Your mood is part of the community pulse'
                                  : 'Log a mood to join the community ripple',
                              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),

                // Fun fact
                NeuBox(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const EmojiWidget(emoji: '💡', size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _getFunFact(),
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: textColor.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseCircle(Color textColor) {
    // Find dominant mood
    int dominantMood = 3;
    double maxPct = 0;
    _communityMoods.forEach((mood, pct) {
      if (pct > maxPct) {
        maxPct = pct;
        dominantMood = mood;
      }
    });

    final color = MoodColors.getColor(dominantMood);

    return Center(
      child: NeuBox(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ripple
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.05),
                    border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
                  ),
                ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: color.withValues(alpha: 0.1)),
                // Middle ripple
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
                  ),
                ),
                // Core
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: EmojiWidget(emoji: MoodEntry.moodEmojis[dominantMood]!, size: 36),
                  ),
                ),
              ],
            ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 16),
            Text(
              'World Mood: ${MoodEntry.moodLabels[dominantMood]}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${maxPct.toStringAsFixed(0)}% of people feel ${MoodEntry.moodLabels[dominantMood]?.toLowerCase()} today',
              style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  String _getFunFact() {
    final facts = [
      'Studies show that people tend to feel happiest between 5-7 PM.',
      'Mood is contagious - surrounding yourself with positive people boosts your own mood.',
      'Exercise can improve your mood for up to 12 hours after a session.',
      'Getting sunlight within 30 minutes of waking improves mood all day.',
      'Gratitude journaling for 5 minutes daily can boost happiness by 25%.',
      'Music can change your brain chemistry and elevate mood in under 15 minutes.',
    ];
    return facts[DateTime.now().day % facts.length];
  }
}
