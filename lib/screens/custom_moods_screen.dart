import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/emoji_widget.dart';

class CustomMoodsScreen extends StatefulWidget {
  const CustomMoodsScreen({super.key});

  @override
  State<CustomMoodsScreen> createState() => _CustomMoodsScreenState();
}

class _CustomMoodsScreenState extends State<CustomMoodsScreen> {
  final Map<int, String> _customLabels = {};
  final Map<int, TextEditingController> _controllers = {};

  static const defaultLabels = {
    1: 'Terrible',
    2: 'Bad',
    3: 'Okay',
    4: 'Good',
    5: 'Great',
  };

  static const emojis = {1: '😢', 2: '😔', 3: '😐', 4: '😊', 5: '😄'};

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 5; i++) {
      _controllers[i] = TextEditingController();
    }
    _loadCustomLabels();
  }

  Future<void> _loadCustomLabels() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 5; i++) {
      final label = prefs.getString('custom_mood_label_$i') ?? defaultLabels[i]!;
      _customLabels[i] = label;
      _controllers[i]!.text = label;
    }
    setState(() {});
  }

  Future<void> _saveLabels() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 5; i++) {
      final label = _controllers[i]!.text.trim();
      if (label.isNotEmpty) {
        await prefs.setString('custom_mood_label_$i', label);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Custom mood labels saved!'),
          backgroundColor: AppTheme.primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _resetDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 5; i++) {
      await prefs.remove('custom_mood_label_$i');
      _controllers[i]!.text = defaultLabels[i]!;
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
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
                  Text(
                    'Custom Mood Scale',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                ],
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Text(
                'Personalize your mood labels to match how you feel',
                style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 24),

              ...List.generate(5, (index) {
                final level = 5 - index; // Show from 5 to 1
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeuBox(
                    child: Row(
                      children: [
                        EmojiWidget(emoji: emojis[level]!, size: 36),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Level $level',
                                style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.4)),
                              ),
                              TextField(
                                controller: _controllers[level],
                                decoration: InputDecoration(
                                  hintText: defaultLabels[level],
                                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: index * 80))
                      .fadeIn()
                      .slideX(begin: 0.05, end: 0),
                );
              }),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      onPressed: _resetDefaults,
                      child: Text('Reset', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _saveLabels,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.tealGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Save Labels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
