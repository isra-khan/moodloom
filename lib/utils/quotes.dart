import 'dart:math';

class Quotes {
  static final _random = Random();

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

  static String getDailyQuote() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return motivationalQuotes[dayOfYear % motivationalQuotes.length];
  }

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
