import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;


class Quotes {
  static final _random = Random();
  static String? _cachedQuote;
  static String? _cachedAuthor;
  static bool _isFetching = false;

  static const List<String> motivationalQuotes = [
    "Every day is a fresh start. 🌅",
    "You are stronger than you think. 💪",
    "Small steps lead to big changes. 👣",
    "Be kind to yourself today. 💚",
    "Your feelings are valid. 🌿",
    "Progress, not perfection. ✨",
    "This too shall pass. 🌊",
    "You deserve happiness. 🌻",
    "Breathe. You've got this. 🌬️",
    "One moment at a time. ⏳",
    "Embrace the journey. 🛤️",
    "You are enough, just as you are. 🌸",
    "Let go of what you can't control. 🍃",
    "Choose joy whenever you can. ☀️",
    "Your mental health matters. 🧠",
    "Be present in this moment. 🧘",
    "It's okay to not be okay. 💙",
    "Tomorrow is full of possibilities. 🌈",
    "Gratitude turns what we have into enough. 🙏",
    "You are a work of art in progress. 🎨",
    "Healing is not linear. 🌀",
    "Take it one breath at a time. 🌬️",
    "You matter more than you know. 💫",
    "Find beauty in the ordinary. 🌼",
    "Rest is productive too. 😴",
    "Your story isn't over yet. 📖",
    "Be the light you wish to see. 🕯️",
    "Growth happens in uncomfortable moments. 🌱",
    "Smile. It's contagious. 😊",
    "The best time for self-care is now. 🛁",
  ];

  static const List<String> reflectionPrompts = [
    "What made you smile today?",
    "What are you grateful for right now?",
    "What's one thing you did well today?",
    "How did you take care of yourself today?",
    "What challenged you today and how did you handle it?",
    "What's something positive that happened?",
    "Who made a difference in your day?",
    "What would make tomorrow even better?",
    "What emotion felt strongest today?",
    "What's one thing you're looking forward to?",
    "Describe your day in three words.",
    "What did you learn about yourself today?",
    "What moment would you relive from today?",
    "How did you show kindness today?",
    "What would you tell your future self?",
    "What's weighing on your mind right now?",
    "What brought you peace today?",
    "How are you really feeling right now?",
    "What boundaries did you set today?",
    "What's one small win from today?",
  ];

  /// Fetches a fresh quote from the API every time the screen loads.
  static Future<void> fetchDailyQuote() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          _cachedQuote = data[0]['q'] as String?;
          _cachedAuthor = data[0]['a'] as String?;
        }
      }
    } catch (_) {
      // Silently fall back to local quotes
    } finally {
      _isFetching = false;
    }
  }

  /// Returns the API quote if available, otherwise a local daily quote.
  static String getDailyQuote() {
    if (_cachedQuote != null && _cachedQuote!.isNotEmpty) {
      return '"$_cachedQuote"';
    }
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return motivationalQuotes[dayOfYear % motivationalQuotes.length];
  }

  /// Returns the author of the API quote, or null if using local.
  static String? getQuoteAuthor() => _cachedAuthor;

  static String getRandomQuote() {
    return motivationalQuotes[_random.nextInt(motivationalQuotes.length)];
  }

  static String getDailyPrompt() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return reflectionPrompts[dayOfYear % reflectionPrompts.length];
  }

  static String getRandomPrompt() {
    return reflectionPrompts[_random.nextInt(reflectionPrompts.length)];
  }
}
