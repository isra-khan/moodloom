import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../models/time_capsule.dart';
import '../providers/mood_provider.dart';
import '../services/database_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/id_generator.dart';

class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({super.key});

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  List<TimeCapsule> _capsules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCapsules();
  }

  Future<void> _loadCapsules() async {
    final capsules = await DatabaseService().getAllTimeCapsules();
    if (mounted) {
      setState(() {
        _capsules = capsules;
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
                      Text('Time Capsule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Write letters to your future self',
                    style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
                  ).animate(delay: 100.ms).fadeIn(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                  : _capsules.isEmpty
                      ? _buildEmpty(textColor)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _capsules.length,
                          itemBuilder: (context, index) {
                            final capsule = _capsules[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CapsuleTile(
                                capsule: capsule,
                                currentMood: _getCurrentMoodAvg(),
                                onOpen: () => _openCapsule(capsule),
                                onDelete: () => _deleteCapsule(capsule.id),
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
          onPressed: _showCreateCapsule,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  double _getCurrentMoodAvg() {
    final today = context.read<MoodProvider>().todayEntries;
    if (today.isEmpty) return 3;
    return today.map((e) => e.moodLevel).reduce((a, b) => a + b) / today.length;
  }

  Widget _buildEmpty(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: NeuBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💌', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No time capsules yet', style: TextStyle(fontSize: 16, color: textColor.withValues(alpha: 0.6))),
              const SizedBox(height: 4),
              Text('Write a letter to your future self', style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.4))),
            ],
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
      ),
    );
  }

  void _showCreateCapsule() {
    final msgController = TextEditingController();
    int moodLevel = 3;
    DateTime unlockDate = DateTime.now().add(const Duration(days: 30));
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
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: textColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Text('New Time Capsule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 16),
                    Text('How are you feeling right now?', style: TextStyle(fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (i) {
                        final level = i + 1;
                        final isSelected = moodLevel == level;
                        return GestureDetector(
                          onTap: () => setSheetState(() => moodLevel = level),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppTheme.primaryTeal : textColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(MoodEntry.moodEmojis[level]!, style: const TextStyle(fontSize: 28)),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Letter to future you', style: TextStyle(fontSize: 14, color: textColor)),
                        const Spacer(),
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
                                  msgController.text = msgController.text.isEmpty
                                      ? text
                                      : '${msgController.text} $text';
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isListening ? AppTheme.primaryTeal : Theme.of(ctx).colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: isListening ? AppTheme.primaryTeal : textColor.withValues(alpha: 0.2)),
                            ),
                            child: Icon(
                              isListening ? Icons.stop : Icons.mic,
                              size: 18,
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: msgController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Dear future me...',
                        hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    Text('Open on', style: TextStyle(fontSize: 14, color: textColor)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: unlockDate,
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setSheetState(() => unlockDate = date);
                      },
                      child: NeuBox(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryTeal),
                            const SizedBox(width: 10),
                            Text(DateHelpers.formatDate(unlockDate), style: TextStyle(fontSize: 14, color: textColor)),
                            const Spacer(),
                            Text(
                              '${unlockDate.difference(DateTime.now()).inDays} days away',
                              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () async {
                          if (msgController.text.trim().isEmpty) return;
                          final capsule = TimeCapsule(
                            id: IdGenerator.generate(),
                            message: msgController.text.trim(),
                            moodWhenWritten: moodLevel,
                            createdAt: DateTime.now(),
                            unlockAt: unlockDate,
                          );
                          await DatabaseService().insertTimeCapsule(capsule);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadCapsules();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(gradient: AppTheme.tealGradient, borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                            child: Text('Seal Capsule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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

  Future<void> _openCapsule(TimeCapsule capsule) async {
    await DatabaseService().openTimeCapsule(capsule.id);
    _loadCapsules();
    if (!mounted) return;

    final textColor = Theme.of(context).colorScheme.onSurface;
    final currentMood = _getCurrentMoodAvg();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('💌 ', style: TextStyle(fontSize: 24)),
            Text('Time Capsule Opened!', style: TextStyle(fontSize: 18, color: textColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Written on ${DateHelpers.formatDate(capsule.createdAt)}',
              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 4),
            Text(
              'You were feeling: ${MoodEntry.moodEmojis[capsule.moodWhenWritten]} ${MoodEntry.moodLabels[capsule.moodWhenWritten]}',
              style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(capsule.message, style: TextStyle(fontSize: 14, color: textColor)),
            ),
            const SizedBox(height: 12),
            Text(
              'Today you feel: ${MoodEntry.moodEmojis[currentMood.round()]} ${MoodEntry.moodLabels[currentMood.round()]}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryTeal)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCapsule(String id) async {
    await DatabaseService().deleteTimeCapsule(id);
    _loadCapsules();
  }
}

class _CapsuleTile extends StatelessWidget {
  final TimeCapsule capsule;
  final double currentMood;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _CapsuleTile({
    required this.capsule,
    required this.currentMood,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isUnlocked = capsule.isUnlocked;

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isUnlocked ? (capsule.isOpened ? '💌' : '🔓') : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked
                          ? (capsule.isOpened ? 'Opened' : 'Ready to open!')
                          : 'Locked',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked && !capsule.isOpened ? AppTheme.primaryTeal : textColor,
                      ),
                    ),
                    Text(
                      isUnlocked
                          ? 'Written ${DateHelpers.formatDate(capsule.createdAt)}'
                          : 'Opens ${DateHelpers.formatDate(capsule.unlockAt)} (${capsule.timeRemaining.inDays}d left)',
                      style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, size: 18, color: textColor.withValues(alpha: 0.4)),
              ),
            ],
          ),
          if (capsule.isOpened) ...[
            const SizedBox(height: 8),
            Text(
              capsule.message,
              style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Mood then: ${MoodEntry.moodEmojis[capsule.moodWhenWritten]}  •  Mood now: ${MoodEntry.moodEmojis[currentMood.round()]}',
              style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5)),
            ),
          ] else if (isUnlocked && !capsule.isOpened) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: NeuButton(
                onPressed: onOpen,
                child: const Text('Open Capsule', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '✨ A message from past you is waiting...',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: textColor.withValues(alpha: 0.5)),
            ),
          ],
        ],
      ),
    );
  }
}
