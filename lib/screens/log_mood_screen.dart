import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../providers/tag_provider.dart';
import '../services/face_mood_service.dart';
import '../services/sentiment_service.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';
import '../utils/quotes.dart';
import '../services/location_service.dart';
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
  final SpeechService _speechService = SpeechService();
  final FaceMoodService _faceMoodService = FaceMoodService();
  bool _isListeningNote = false;
  bool _isListeningJournal = false;
  String? _moodSuggestionText;
  bool _isDetectingFace = false;
  bool _locationEnabled = false;
  LocationResult? _location;
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _noteController.dispose();
    _journalController.dispose();
    _tagController.dispose();
    _faceMoodService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBgColor = isDark ? AppTheme.darkCard : AppTheme.surfaceColor;
    final chipBgColor = isDark ? AppTheme.darkCard : AppTheme.surfaceColor;
    final shadowLight = isDark ? AppTheme.darkShadowLight : AppTheme.shadowLight;
    final shadowDark = isDark ? AppTheme.darkShadowDark : AppTheme.shadowDark;
    final textColor = isDark ? Colors.white : AppTheme.darkTeal;
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.3) : AppTheme.darkTeal.withValues(alpha: 0.3);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select your mood',
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isDetectingFace ? null : _detectMoodFromCamera,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isDetectingFace ? AppTheme.primaryTeal : inputBgColor,
                              shape: BoxShape.circle,
                              boxShadow: _isDetectingFace
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: shadowDark.withValues(alpha: 0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                      BoxShadow(
                                        color: shadowLight.withValues(alpha: 0.7),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: _isDetectingFace ? Colors.white : AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isDetectingFace)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Analyzing your expression...',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal.withValues(alpha: 0.7)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    MoodEmojiPicker(
                      selectedMood: _selectedMood,
                      onMoodSelected: (level) => setState(() {
                        _selectedMood = level;
                        _moodSuggestionText = null;
                      }),
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
                    if (_moodSuggestionText != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _moodSuggestionText!,
                                style: const TextStyle(fontSize: 12, color: AppTheme.primaryTeal),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick note (optional)',
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                        GestureDetector(
                          onTap: () => _toggleListening(isNote: true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isListeningNote ? AppTheme.primaryTeal : inputBgColor,
                              shape: BoxShape.circle,
                              boxShadow: _isListeningNote
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: shadowDark.withValues(alpha: 0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                      BoxShadow(
                                        color: shadowLight.withValues(alpha: 0.7),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            child: Icon(
                              _isListeningNote ? Icons.stop : Icons.mic,
                              size: 20,
                              color: _isListeningNote ? Colors.white : AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isListeningNote)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          'Listening... speak now',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal.withValues(alpha: 0.7)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: shadowDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: shadowLight.withValues(alpha: 0.7),
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
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: TextStyle(color: textColor),
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
                    Text(
                      'Tags',
                      style: TextStyle(fontSize: 14, color: textColor),
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
                                  color: isSelected ? AppTheme.primaryTeal : chipBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: shadowDark.withValues(alpha: 0.2),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: shadowLight.withValues(alpha: 0.7),
                                            offset: const Offset(-2, -2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : textColor,
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
                                color: hintColor,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: 13, color: textColor),
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

              // Location toggle
              NeuBox(
                child: Row(
                  children: [
                    Icon(
                      _locationEnabled ? Icons.location_on : Icons.location_off_outlined,
                      color: _locationEnabled ? AppTheme.primaryTeal : textColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Track Location', style: TextStyle(fontSize: 14, color: textColor)),
                          if (_location != null)
                            Text(_location!.displayName, style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal)),
                          if (_isFetchingLocation)
                            Text('Getting location...', style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Switch(
                      value: _locationEnabled,
                      activeThumbColor: AppTheme.primaryTeal,
                      activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                      trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
                      onChanged: (value) async {
                        setState(() => _locationEnabled = value);
                        if (value) {
                          setState(() => _isFetchingLocation = true);
                          final loc = await LocationService.getCurrentLocation();
                          if (mounted) {
                            setState(() {
                              _location = loc;
                              _isFetchingLocation = false;
                              if (loc == null) _locationEnabled = false;
                            });
                          }
                        } else {
                          setState(() => _location = null);
                        }
                      },
                    ),
                  ],
                ),
              ).animate(delay: 325.ms).fadeIn().slideY(begin: 0.1, end: 0),
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
                          color: textColor.withValues(alpha: 0.7),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Journal entry (optional)',
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                        GestureDetector(
                          onTap: () => _toggleListening(isNote: false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isListeningJournal ? AppTheme.primaryTeal : inputBgColor,
                              shape: BoxShape.circle,
                              boxShadow: _isListeningJournal
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: shadowDark.withValues(alpha: 0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                      BoxShadow(
                                        color: shadowLight.withValues(alpha: 0.7),
                                        offset: const Offset(-2, -2),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            child: Icon(
                              _isListeningJournal ? Icons.stop : Icons.mic,
                              size: 20,
                              color: _isListeningJournal ? Colors.white : AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isListeningJournal)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          'Listening... speak now',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal.withValues(alpha: 0.7)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: inputBgColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: shadowDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: shadowLight.withValues(alpha: 0.7),
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
                          hintStyle: TextStyle(color: hintColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: TextStyle(color: textColor),
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

  Future<void> _toggleListening({required bool isNote}) async {
    // Stop any active listening first
    if (_speechService.isListening) {
      await _speechService.stopListening(
        onListening: (_) => setState(() {
          _isListeningNote = false;
          _isListeningJournal = false;
        }),
      );
      return;
    }

    final available = await _speechService.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Speech recognition not available on this device'),
            backgroundColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isListeningNote = isNote;
      _isListeningJournal = !isNote;
    });

    await _speechService.startListening(
      onResult: (translatedText) {
        setState(() {
          if (isNote) {
            _noteController.text = _noteController.text.isEmpty
                ? translatedText
                : '${_noteController.text} $translatedText';
          } else {
            _journalController.text = _journalController.text.isEmpty
                ? translatedText
                : '${_journalController.text} $translatedText';
          }
          _isListeningNote = false;
          _isListeningJournal = false;

          // Auto-suggest mood from text sentiment
          final allText = '${_noteController.text} ${_journalController.text}'.trim();
          final suggestedMood = SentimentService.analyzeMood(allText);
          if (suggestedMood != null && _selectedMood == null) {
            _selectedMood = suggestedMood;
            _moodSuggestionText = SentimentService.getMoodReason(allText);
          }
        });
      },
      onListening: (listening) {
        if (!listening) {
          setState(() {
            _isListeningNote = false;
            _isListeningJournal = false;
          });
        }
      },
    );
  }

  Future<void> _detectMoodFromCamera() async {
    setState(() => _isDetectingFace = true);

    try {
      final cameras = await availableCameras();
      // Prefer front camera
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      final image = await controller.takePicture();
      await controller.dispose();

      final result = await _faceMoodService.detectMoodFromImage(image);

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _selectedMood = result.moodLevel;
          _moodSuggestionText = result.label;
          _isDetectingFace = false;
        });
      } else {
        setState(() => _isDetectingFace = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No face detected. Please try again.'),
            backgroundColor: AppTheme.primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDetectingFace = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not access camera. Please check permissions.'),
          backgroundColor: AppTheme.primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
          latitude: _location?.latitude,
          longitude: _location?.longitude,
          locationName: _location?.displayName,
        );

    Navigator.pop(context);
  }
}
