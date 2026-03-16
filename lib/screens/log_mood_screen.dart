import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/tag_provider.dart';
import '../theme/app_theme.dart';
import '../utils/quotes.dart';
import '../widgets/mood_emoji_picker.dart';

class LogMoodScreen extends StatefulWidget {
  const LogMoodScreen({super.key});

  @override
  State<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends State<LogMoodScreen> {
  int? _selectedMood;
  final _noteController = TextEditingController();
  final _journalController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _noteController.dispose();
    _journalController.dispose();
    _tagController.dispose();
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
                  const SizedBox(width: 16),
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              const SizedBox(height: 32),

              // Emoji Picker
              NeuBox(
                child: Column(
                  children: [
                    const Text(
                      'Select your mood',
                      style: TextStyle(fontSize: 16, color: AppTheme.darkTeal),
                    ),
                    const SizedBox(height: 16),
                    MoodEmojiPicker(
                      selectedMood: _selectedMood,
                      onMoodSelected: (level) => setState(() => _selectedMood = level),
                    ),
                    if (_selectedMood != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _getMoodLabel(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ).animate().fadeIn().scale(),
                    ],
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Quick Note
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick note (optional)',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkTeal),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: AppTheme.shadowLight.withValues(alpha: 0.7),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          hintStyle: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(color: AppTheme.darkTeal),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Tags
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkTeal),
                    ),
                    const SizedBox(height: 8),
                    Consumer<TagProvider>(
                      builder: (context, tagProvider, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tagProvider.tags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTags.remove(tag);
                                  } else {
                                    _selectedTags.add(tag);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppTheme.shadowDark.withValues(alpha: 0.2),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: AppTheme.shadowLight.withValues(alpha: 0.7),
                                            offset: const Offset(-2, -2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : AppTheme.darkTeal,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Add custom tag...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: AppTheme.darkTeal.withValues(alpha: 0.3),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13, color: AppTheme.darkTeal),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppTheme.primaryTeal),
                          onPressed: () {
                            if (_tagController.text.trim().isNotEmpty) {
                              context.read<TagProvider>().addTag(_tagController.text.trim());
                              _selectedTags.add(_tagController.text.trim());
                              _tagController.clear();
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Reflection prompt
              NeuBox(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Text('🪞', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Quotes.getDailyPrompt(),
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.darkTeal.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Journal
              NeuBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Journal entry (optional)',
                      style: TextStyle(fontSize: 14, color: AppTheme.darkTeal),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: AppTheme.shadowLight.withValues(alpha: 0.7),
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _journalController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Write about your day...',
                          hintStyle: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(color: AppTheme.darkTeal),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _saveMood,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: _selectedMood != null ? AppTheme.tealGradient : null,
                      color: _selectedMood == null ? AppTheme.shadowDark : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _selectedMood != null
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: const Center(
                      child: Text(
                        'Save Mood',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getMoodLabel() {
    const labels = {1: 'Terrible', 2: 'Bad', 3: 'Okay', 4: 'Good', 5: 'Great'};
    return labels[_selectedMood] ?? '';
  }

  void _saveMood() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a mood'),
          backgroundColor: AppTheme.primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<MoodProvider>().addMoodEntry(
          moodLevel: _selectedMood!,
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          journalEntry: _journalController.text.isNotEmpty ? _journalController.text : null,
          tags: _selectedTags,
        );

    Navigator.pop(context);
  }
}
