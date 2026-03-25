import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../services/mood_avatar_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emoji_widget.dart';
import '../widgets/mood_tree_painter.dart';

class MoodAvatarScreen extends StatelessWidget {
  const MoodAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, mood, _) {
            final state = MoodAvatarService.calculateState(mood.allEntries);
            final milestones = MoodAvatarService.getMilestones(mood.allEntries, state.streak);

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
                      Text('Your MoodLoom Tree', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 24),

                  // Tree visualization
                  Center(
                    child: NeuBox(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          MoodTreeWidget(state: state, size: 260)
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 600.ms)
                              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),
                          const SizedBox(height: 16),
                          Text(
                            _getStageName(state.stage),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.message,
                            style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),

                  // Health bar
                  NeuBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const EmojiWidget(emoji: '🌡️', size: 18),
                            const SizedBox(width: 8),
                            Text('Tree Health', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                            const Spacer(),
                            Text(
                              '${(state.health * 100).round()}%',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getHealthColor(state.health)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.health,
                            minHeight: 12,
                            backgroundColor: Colors.grey.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(_getHealthColor(state.health)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _miniStat('🔥', 'Streak', '${state.streak} days', textColor),
                            _miniStat('📊', 'Avg Mood', state.recentAvg.toStringAsFixed(1), textColor),
                            _miniStat('🌱', 'Stage', _getStageName(state.stage), textColor),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),

                  // Active decorations
                  Text('Active Decorations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  NeuBox(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _buildDecorationChips(state.decoration, textColor),
                    ),
                  ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),

                  // Milestones
                  Text('Growth Milestones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  ...milestones.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NeuBox(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            EmojiWidget(emoji: m.emoji, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                                  Text(m.description, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5))),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 20),
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: 500 + i * 60)).fadeIn().slideX(begin: 0.1, end: 0),
                    );
                  }),

                  // Next milestones (locked)
                  if (milestones.length < 9) ...[
                    const SizedBox(height: 12),
                    Text('Next Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    ..._buildLockedMilestones(mood.allEntries.length, state.streak, textColor),
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

  String _getStageName(TreeStage stage) {
    switch (stage) {
      case TreeStage.blooming: return 'Blooming';
      case TreeStage.healthy: return 'Healthy';
      case TreeStage.steady: return 'Steady';
      case TreeStage.wilting: return 'Wilting';
      case TreeStage.withered: return 'Withered';
    }
  }

  Color _getHealthColor(double health) {
    if (health >= 0.7) return const Color(0xFF43A047);
    if (health >= 0.4) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  Widget _miniStat(String emoji, String label, String value, Color textColor) {
    return Column(
      children: [
        EmojiWidget(emoji: emoji, size: 16),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.5))),
      ],
    );
  }

  List<Widget> _buildDecorationChips(TreeDecoration deco, Color textColor) {
    final items = <Widget>[];

    void addChip(String emoji, String label, bool active) {
      items.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryTeal.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppTheme.primaryTeal.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmojiWidget(emoji: emoji, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? textColor : textColor.withValues(alpha: 0.3),
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    addChip('☀️', 'Sunshine', deco.hasSunshine);
    addChip('🌸', 'Flowers', deco.hasFlowers);
    addChip('🐦', 'Birds', deco.hasBirds);
    addChip('🦋', 'Butterflies', deco.hasButterflies);
    addChip('✨', 'Fairy Lights', deco.hasFairyLights);
    addChip('⭐', 'Stars', deco.hasStars);
    addChip('🌈', 'Rainbow', deco.hasRainbow);

    return items;
  }

  List<Widget> _buildLockedMilestones(int totalEntries, int streak, Color textColor) {
    final locked = <Widget>[];

    void addLocked(String emoji, String title, String desc) {
      locked.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: NeuBox(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            intensity: 0.4,
            child: Row(
              children: [
                EmojiWidget(emoji: emoji, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.4))),
                      Text(desc, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
                Icon(Icons.lock_outline, size: 18, color: textColor.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ),
      );
    }

    if (totalEntries < 10) addLocked('🌿', 'Sprout', 'Log 10 moods');
    if (totalEntries < 25) addLocked('🪴', 'Sapling', 'Log 25 moods');
    if (totalEntries < 50) addLocked('🌳', 'Young Tree', 'Log 50 moods');
    if (totalEntries < 100) addLocked('🌲', 'Mighty Oak', 'Log 100 moods');
    if (streak < 7) addLocked('🦋', 'Butterfly Effect', 'Reach a 7-day streak');
    if (streak < 14) addLocked('✨', 'Fairy Lights', 'Reach a 14-day streak');
    if (streak < 30) addLocked('👑', 'Tree Guardian', 'Reach a 30-day streak');

    return locked.take(3).toList();
  }
}
