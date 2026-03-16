import 'package:flutter/material.dart';

class MoodColors {
  static const Map<int, Color> moodColorMap = {
    1: Color(0xFFEF5350),  // Very Sad - Red
    2: Color(0xFFFF8A65),  // Sad - Orange
    3: Color(0xFFFFD54F),  // Okay - Yellow
    4: Color(0xFF69F0AE),  // Good - Light Green
    5: Color(0xFF00C853),  // Great - Green
  };

  static Color getColor(int moodLevel) => moodColorMap[moodLevel] ?? Colors.grey;

  static Color getColorWithOpacity(int moodLevel, double opacity) =>
      getColor(moodLevel).withValues(alpha: opacity);
}
