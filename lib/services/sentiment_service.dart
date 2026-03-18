/// Analyzes English text sentiment and maps it to a mood level (1-5).
/// Uses keyword-based analysis — no API or ML model needed.
class SentimentService {
  static const Map<String, double> _positiveWords = {
    // Strong positive
    'amazing': 2.0, 'wonderful': 2.0, 'fantastic': 2.0, 'excellent': 2.0,
    'incredible': 2.0, 'awesome': 2.0, 'love': 2.0, 'perfect': 2.0,
    'brilliant': 2.0, 'thrilled': 2.0, 'ecstatic': 2.0, 'overjoyed': 2.0,
    'blessed': 2.0, 'grateful': 1.8, 'excited': 1.8, 'delighted': 1.8,
    'joyful': 1.8, 'euphoric': 2.0, 'elated': 2.0, 'magnificent': 2.0,

    // Moderate positive
    'happy': 1.5, 'good': 1.2, 'great': 1.5, 'nice': 1.0, 'glad': 1.2,
    'pleased': 1.2, 'cheerful': 1.3, 'content': 1.0, 'satisfied': 1.0,
    'enjoy': 1.3, 'fun': 1.2, 'proud': 1.3, 'hopeful': 1.2,
    'peaceful': 1.2, 'calm': 1.0, 'relaxed': 1.0, 'comfortable': 1.0,
    'thankful': 1.3, 'positive': 1.2, 'better': 1.0, 'smile': 1.2,
    'laugh': 1.3, 'beautiful': 1.3, 'kind': 1.0, 'warm': 1.0,

    // Mild positive
    'okay': 0.3, 'fine': 0.3, 'alright': 0.3, 'decent': 0.3,
    'normal': 0.1, 'stable': 0.2, 'manageable': 0.2,
  };

  static const Map<String, double> _negativeWords = {
    // Strong negative
    'terrible': -2.0, 'horrible': -2.0, 'awful': -2.0, 'miserable': -2.0,
    'devastated': -2.0, 'depressed': -2.0, 'hopeless': -2.0, 'hate': -2.0,
    'suicidal': -2.0, 'worthless': -2.0, 'destroyed': -2.0, 'agony': -2.0,
    'nightmare': -1.8, 'heartbroken': -2.0, 'desperate': -1.8,
    'suffering': -1.8, 'tormented': -2.0, 'anguish': -2.0,

    // Moderate negative
    'sad': -1.5, 'angry': -1.5, 'upset': -1.3, 'frustrated': -1.3,
    'anxious': -1.3, 'worried': -1.2, 'stressed': -1.3, 'tired': -1.0,
    'exhausted': -1.3, 'lonely': -1.5, 'scared': -1.3, 'afraid': -1.3,
    'disappointed': -1.3, 'annoyed': -1.0, 'irritated': -1.0,
    'overwhelmed': -1.3, 'nervous': -1.0, 'unhappy': -1.5, 'pain': -1.3,
    'hurt': -1.3, 'bad': -1.2, 'cry': -1.5, 'crying': -1.5,
    'sick': -1.2, 'weak': -1.0, 'lost': -1.0, 'confused': -1.0,
    'regret': -1.2, 'shame': -1.3, 'guilt': -1.2, 'fear': -1.3,

    // Mild negative
    'bored': -0.5, 'meh': -0.5, 'blah': -0.5, 'dull': -0.5,
    'numb': -0.7, 'empty': -0.8, 'indifferent': -0.3,
  };

  /// Analyze text and return a mood level from 1-5.
  /// Returns null if text is too short or neutral to determine mood.
  static int? analyzeMood(String text) {
    if (text.trim().isEmpty) return null;

    final words = text.toLowerCase().split(RegExp(r'[\s,.!?;:]+'));
    if (words.isEmpty) return null;

    double score = 0;
    int matchedWords = 0;
    bool hasNegation = false;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      // Track negation words
      if (word == 'not' || word == "don't" || word == "dont" ||
          word == "no" || word == "never" || word == "isn't" ||
          word == "wasn't" || word == "can't" || word == "cannot" ||
          word == "won't" || word == "couldn't" || word == "shouldn't") {
        hasNegation = true;
        continue;
      }

      double? wordScore;
      if (_positiveWords.containsKey(word)) {
        wordScore = _positiveWords[word]!;
      } else if (_negativeWords.containsKey(word)) {
        wordScore = _negativeWords[word]!;
      }

      if (wordScore != null) {
        // Flip score if preceded by negation
        if (hasNegation) {
          wordScore = -wordScore * 0.7; // Negation dampens the flip slightly
        }
        score += wordScore;
        matchedWords++;
        hasNegation = false;
      }
    }

    // Need at least one sentiment word to suggest a mood
    if (matchedWords == 0) return null;

    // Normalize score
    final normalized = score / matchedWords;

    // Map to 1-5 mood scale
    if (normalized >= 1.3) return 5;  // Great
    if (normalized >= 0.6) return 4;  // Good
    if (normalized >= -0.3) return 3; // Okay
    if (normalized >= -1.0) return 2; // Bad
    return 1;                         // Terrible
  }

  /// Get a label describing why this mood was suggested
  static String getMoodReason(String text) {
    final mood = analyzeMood(text);
    if (mood == null) return '';
    switch (mood) {
      case 5: return 'Your words sound very positive!';
      case 4: return 'Sounds like you\'re doing well';
      case 3: return 'Sounds like a neutral day';
      case 2: return 'It seems like a rough time';
      case 1: return 'Your words suggest you\'re struggling';
      default: return '';
    }
  }
}
