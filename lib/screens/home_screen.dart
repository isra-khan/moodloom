import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/quotes.dart';
import '../widgets/mood_entry_tile.dart';
import 'log_mood_screen.dart';
import 'search_screen.dart';
import 'journal_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _quote = Quotes.getDailyQuote();
  String? _author = Quotes.getQuoteAuthor();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadTodayEntries();
      context.read<MoodProvider>().loadAllEntries();
    });
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    await Quotes.fetchDailyQuote();
    if (mounted) {
      setState(() {
        _quote = Quotes.getDailyQuote();
        _author = Quotes.getQuoteAuthor();
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, mood, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withValues(alpha: 0.6),
                                  ),
                                ).animate().fadeIn(duration: 400.ms),
                                const SizedBox(height: 4),
                                Text(
                                  'MoodLoom',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                              ],
                            ),
                            NeuButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const SearchScreen(),
                                ));
                              },
                              borderRadius: 14,
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.search, color: AppTheme.primaryTeal),
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Daily motivational quote
                        NeuBox(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _quote,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: textColor.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    if (_author != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '— $_author',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: textColor.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 16),

                        // Quick mood buttons
                        Text(
                          'Quick Log',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _QuickMoodRow(
                          onMoodSelected: (level) {
                            mood.addMoodEntry(moodLevel: level);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logged: ${MoodEntry.moodEmojis[level]} ${MoodEntry.moodLabels[level]}'),
                                backgroundColor: AppTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Streak',
                                value: '${mood.currentStreak}',
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Today',
                                value: '${mood.todayEntries.length}',
                                icon: Icons.today,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Total',
                                value: '${mood.totalEntries}',
                                icon: Icons.bar_chart,
                                color: AppTheme.lightTeal,
                              ),
                            ),
                          ],
                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 20),

                        // Achievements
                        if (mood.totalEntries > 0) ...[
                          _AchievementsRow(
                            totalEntries: mood.totalEntries,
                            streak: mood.currentStreak,
                            journalCount: mood.allEntries.where((e) => e.journalEntry?.isNotEmpty == true).length,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Daily reflection prompt
                        NeuBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🪞', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Daily Reflection',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Quotes.getDailyPrompt(),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: NeuButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => const LogMoodScreen(),
                                    ));
                                  },
                                  child: const Text(
                                    'Reflect & Log',
                                    style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 20),

                        Text(
                          'Today, ${DateHelpers.formatDate(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (mood.todayEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: NeuBox(
                        child: Column(
                          children: [
                            const Text('🌿', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'No moods logged today',
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use quick log above or tap + for details',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = mood.todayEntries[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: MoodEntryTile(
                            entry: entry,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => JournalDetailScreen(entry: entry),
                              ));
                            },
                            onDelete: () => _confirmDelete(context, mood, entry.id),
                          ).animate(delay: Duration(milliseconds: index * 80))
                              .fadeIn()
                              .slideX(begin: 0.1, end: 0),
                        );
                      },
                      childCount: mood.todayEntries.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.tealGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogMoodScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ).animate().scale(delay: 500.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }

  void _confirmDelete(BuildContext context, MoodProvider mood, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Entry', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: const Text('Are you sure you want to delete this mood entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              mood.deleteEntry(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _QuickMoodRow extends StatelessWidget {
  final ValueChanged<int> onMoodSelected;
  const _QuickMoodRow({required this.onMoodSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final level = index + 1;
        return GestureDetector(
          onTap: () => onMoodSelected(level),
          child: NeuBox(
            borderRadius: 16,
            padding: const EdgeInsets.all(12),
            child: Text(MoodEntry.moodEmojis[level]!, style: const TextStyle(fontSize: 28)),
          ),
        );
      }).animate(interval: 60.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return NeuBox(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  final int totalEntries;
  final int streak;
  final int journalCount;

  const _AchievementsRow({
    required this.totalEntries,
    required this.streak,
    required this.journalCount,
  });

  bool _isUnlocked(Achievement a) {
    switch (a.type) {
      case AchievementType.totalEntries:
        return totalEntries >= a.requirement;
      case AchievementType.streak:
        return streak >= a.requirement;
      case AchievementType.journalEntries:
        return journalCount >= a.requirement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final unlocked = Achievement.all.where(_isUnlocked).toList();
    if (unlocked.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${unlocked.length}/${Achievement.all.length}',
                style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: unlocked.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final a = unlocked[index];
              return NeuBox(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      a.title,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: index * 80))
                  .fadeIn()
                  .scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ),
      ],
    );
  }
}
