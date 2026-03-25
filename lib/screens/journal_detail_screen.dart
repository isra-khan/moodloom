import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/mood_colors.dart';
import '../widgets/emoji_widget.dart';

class JournalDetailScreen extends StatefulWidget {
  final MoodEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late TextEditingController _journalController;
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _journalController = TextEditingController(text: widget.entry.journalEntry ?? '');
    _noteController = TextEditingController(text: widget.entry.note ?? '');
  }

  @override
  void dispose() {
    _journalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  NeuButton(
                    onPressed: () => Navigator.pop(context),
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.darkTeal),
                  ),
                  const Spacer(),
                  NeuButton(
                    onPressed: () {
                      if (_isEditing) {
                        _saveChanges();
                      }
                      setState(() => _isEditing = !_isEditing);
                    },
                    borderRadius: 12,
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      size: 18,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 24),

              // Mood display
              Center(
                child: NeuBox(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'mood_emoji_${widget.entry.id}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                MoodColors.getColor(widget.entry.moodLevel).withValues(alpha: 0.3),
                                MoodColors.getColor(widget.entry.moodLevel).withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: EmojiWidget(emoji: widget.entry.emoji, size: 42),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.entry.label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateHelpers.formatDateTime(widget.entry.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.darkTeal.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 20),

              // Tags
              if (widget.entry.tags.isNotEmpty) ...[
                NeuBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.entry.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
              ],

              // Note
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add a note...',
                          hintStyle: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: AppTheme.darkTeal),
                      )
                    else
                      Text(
                        widget.entry.note?.isNotEmpty == true ? widget.entry.note! : 'No note',
                        style: TextStyle(
                          fontSize: 15,
                          color: widget.entry.note?.isNotEmpty == true
                              ? AppTheme.darkTeal
                              : AppTheme.darkTeal.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),

              // Journal entry
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Journal Entry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isEditing)
                      TextField(
                        controller: _journalController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Write about your day...',
                          hintStyle: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: AppTheme.darkTeal),
                      )
                    else
                      Text(
                        widget.entry.journalEntry?.isNotEmpty == true
                            ? widget.entry.journalEntry!
                            : 'No journal entry',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: widget.entry.journalEntry?.isNotEmpty == true
                              ? AppTheme.darkTeal
                              : AppTheme.darkTeal.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    final updated = widget.entry.copyWith(
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      journalEntry: _journalController.text.isNotEmpty ? _journalController.text : null,
    );
    context.read<MoodProvider>().updateEntry(updated);
  }
}
