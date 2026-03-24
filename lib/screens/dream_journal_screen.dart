import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/dream_entry.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../services/database_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/id_generator.dart';

class DreamJournalScreen extends StatefulWidget {
  const DreamJournalScreen({super.key});

  @override
  State<DreamJournalScreen> createState() => _DreamJournalScreenState();
}

class _DreamJournalScreenState extends State<DreamJournalScreen> {
  List<DreamEntry> _dreams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDreams();
  }

  Future<void> _loadDreams() async {
    final db = DatabaseService();
    final dreams = await db.getAllDreamEntries();
    if (mounted) {
      setState(() {
        _dreams = dreams;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                      Text(
                        'Dream Journal',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Track your dreams and discover mood correlations',
                    style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 16),
                  if (_dreams.length >= 3) _buildCorrelation(textColor),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                  : _dreams.isEmpty
                      ? _buildEmpty(textColor)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _dreams.length,
                          itemBuilder: (context, index) {
                            final dream = _dreams[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DreamTile(
                                dream: dream,
                                onDelete: () => _deleteDream(dream.id),
                              ).animate(delay: Duration(milliseconds: index * 60))
                                  .fadeIn()
                                  .slideX(begin: 0.1, end: 0),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.tealGradient,
          boxShadow: [
            BoxShadow(color: AppTheme.primaryTeal.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddDream,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmpty(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: NeuBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No dreams logged yet', style: TextStyle(fontSize: 16, color: textColor.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text('Tap + to record your first dream', style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.4))),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }

  Widget _buildCorrelation(Color textColor) {
    final moodEntries = context.read<MoodProvider>().allEntries;
    if (moodEntries.isEmpty) return const SizedBox();

    // Find average mood on days after good vs bad sleep
    double goodSleepMoodAvg = 0;
    int goodSleepCount = 0;
    double badSleepMoodAvg = 0;
    int badSleepCount = 0;

    for (final dream in _dreams) {
      final nextDay = dream.createdAt.add(const Duration(days: 1));
      final nextDayMoods = moodEntries.where((e) => DateHelpers.isSameDay(e.createdAt, nextDay)).toList();
      if (nextDayMoods.isEmpty) continue;

      final avgMood = nextDayMoods.map((e) => e.moodLevel).reduce((a, b) => a + b) / nextDayMoods.length;
      if (dream.sleepQuality >= 4) {
        goodSleepMoodAvg += avgMood;
        goodSleepCount++;
      } else if (dream.sleepQuality <= 2) {
        badSleepMoodAvg += avgMood;
        badSleepCount++;
      }
    }

    if (goodSleepCount == 0 && badSleepCount == 0) return const SizedBox();

    final goodAvg = goodSleepCount > 0 ? goodSleepMoodAvg / goodSleepCount : 0.0;
    final badAvg = badSleepCount > 0 ? badSleepMoodAvg / badSleepCount : 0.0;

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Sleep → Mood Correlation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
          const SizedBox(height: 10),
          if (goodSleepCount > 0)
            Row(
              children: [
                const Text('Good sleep →', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text(
                  '${MoodEntry.moodEmojis[goodAvg.round()]} avg mood ${goodAvg.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
          if (badSleepCount > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Bad sleep  →', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Text(
                  '${MoodEntry.moodEmojis[badAvg.round()]} avg mood ${badAvg.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showAddDream() {
    final descController = TextEditingController();
    int sleepQuality = 3;
    bool remembered = true;
    final speechService = SpeechService();
    bool isListening = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final textColor = Theme.of(ctx).colorScheme.onSurface;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 40, height: 4, decoration: BoxDecoration(color: textColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
                    ),
                    const SizedBox(height: 16),
                    Text('Log Dream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),
                    Text('Sleep Quality', style: TextStyle(fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        final level = i + 1;
                        final isSelected = sleepQuality == level;
                        return GestureDetector(
                          onTap: () => setSheetState(() => sleepQuality = level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryTeal : Theme.of(ctx).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppTheme.primaryTeal : textColor.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              children: [
                                Text(DreamEntry.sleepEmojis[level]!, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 2),
                                Text(
                                  DreamEntry.sleepLabels[level]!,
                                  style: TextStyle(fontSize: 9, color: isSelected ? Colors.white : textColor.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Remembered dream?', style: TextStyle(fontSize: 14, color: textColor)),
                        const Spacer(),
                        Switch(
                          value: remembered,
                          activeThumbColor: AppTheme.primaryTeal,
                          activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                          trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                          onChanged: (v) => setSheetState(() => remembered = v),
                        ),
                      ],
                    ),
                    if (remembered) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: descController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Describe your dream...',
                                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              if (speechService.isListening) {
                                await speechService.stopListening(
                                  onListening: (_) => setSheetState(() => isListening = false),
                                );
                                return;
                              }
                              final available = await speechService.initialize();
                              if (!available) return;
                              setSheetState(() => isListening = true);
                              await speechService.startListening(
                                onResult: (text) {
                                  setSheetState(() {
                                    descController.text = descController.text.isEmpty
                                        ? text
                                        : '${descController.text} $text';
                                    isListening = false;
                                  });
                                },
                                onListening: (listening) {
                                  if (!listening) setSheetState(() => isListening = false);
                                },
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isListening ? AppTheme.primaryTeal : Theme.of(ctx).colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: isListening ? AppTheme.primaryTeal : textColor.withValues(alpha: 0.2)),
                              ),
                              child: Icon(
                                isListening ? Icons.stop : Icons.mic,
                                size: 20,
                                color: isListening ? Colors.white : AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isListening)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Listening... speak now',
                            style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal.withValues(alpha: 0.7)),
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          final dream = DreamEntry(
                            id: IdGenerator.generate(),
                            description: descController.text.trim(),
                            sleepQuality: sleepQuality,
                            remembered: remembered,
                            tags: [],
                            createdAt: DateTime.now(),
                          );
                          await DatabaseService().insertDreamEntry(dream);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadDreams();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(gradient: AppTheme.tealGradient, borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                            child: Text('Save Dream', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDream(String id) async {
    await DatabaseService().deleteDreamEntry(id);
    _loadDreams();
  }
}

class _DreamTile extends StatelessWidget {
  final DreamEntry dream;
  final VoidCallback onDelete;

  const _DreamTile({required this.dream, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dream.sleepEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep: ${dream.sleepLabel}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    Text(
                      DateHelpers.formatDateTime(dream.createdAt),
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              if (dream.remembered) const Text('💭', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, size: 18, color: textColor.withValues(alpha: 0.4)),
              ),
            ],
          ),
          if (dream.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dream.description,
              style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
