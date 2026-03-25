import 'package:flutter/material.dart';
import 'package:twemoji/twemoji.dart' as tw;

class EmojiWidget extends StatelessWidget {
  final String emoji;
  final double size;

  const EmojiWidget({
    super.key,
    required this.emoji,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return tw.Twemoji(
      emoji: emoji,
      height: size,
      width: size,
    );
  }
}
