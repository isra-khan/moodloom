import 'package:flutter/material.dart';
import '../services/mood_avatar_service.dart';

class MoodTreeWidget extends StatelessWidget {
  final AvatarState state;
  final double size;

  const MoodTreeWidget({super.key, required this.state, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TreePainter(state: state),
        child: _buildOverlayDecorations(),
      ),
    );
  }

  Widget _buildOverlayDecorations() {
    final deco = state.decoration;
    final widgets = <Widget>[];

    // Sunshine
    if (deco.hasSunshine) {
      widgets.add(
        Positioned(
          top: 5,
          right: 15,
          child: Text('☀️', style: TextStyle(fontSize: size * 0.12)),
        ),
      );
    }

    // Rain drops
    if (deco.hasRain) {
      for (int i = 0; i < 5; i++) {
        widgets.add(
          Positioned(
            top: 10 + (i * 18.0),
            left: 30 + (i * 35.0),
            child: Text('💧', style: TextStyle(fontSize: size * 0.06)),
          ),
        );
      }
    }

    // Rainbow
    if (deco.hasRainbow) {
      widgets.add(
        Positioned(
          top: 10,
          left: 20,
          child: Text('🌈', style: TextStyle(fontSize: size * 0.14)),
        ),
      );
    }

    // Birds
    if (deco.hasBirds) {
      widgets.add(
        Positioned(
          top: 20,
          left: 30,
          child: Text('🐦', style: TextStyle(fontSize: size * 0.08)),
        ),
      );
      widgets.add(
        Positioned(
          top: 35,
          right: 40,
          child: Text('🐦', style: TextStyle(fontSize: size * 0.07)),
        ),
      );
    }

    // Butterflies
    if (deco.hasButterflies) {
      widgets.add(
        Positioned(
          top: size * 0.3,
          right: 25,
          child: Text('🦋', style: TextStyle(fontSize: size * 0.09)),
        ),
      );
    }

    // Flowers at base
    if (deco.hasFlowers) {
      widgets.add(
        Positioned(
          bottom: size * 0.08,
          left: size * 0.15,
          child: Text('🌸', style: TextStyle(fontSize: size * 0.08)),
        ),
      );
      widgets.add(
        Positioned(
          bottom: size * 0.1,
          right: size * 0.2,
          child: Text('🌷', style: TextStyle(fontSize: size * 0.07)),
        ),
      );
      widgets.add(
        Positioned(
          bottom: size * 0.06,
          left: size * 0.4,
          child: Text('🌼', style: TextStyle(fontSize: size * 0.07)),
        ),
      );
    }

    // Fairy lights
    if (deco.hasFairyLights) {
      widgets.add(
        Positioned(
          top: size * 0.25,
          left: size * 0.25,
          child: Text('✨', style: TextStyle(fontSize: size * 0.06)),
        ),
      );
      widgets.add(
        Positioned(
          top: size * 0.35,
          right: size * 0.28,
          child: Text('✨', style: TextStyle(fontSize: size * 0.05)),
        ),
      );
      widgets.add(
        Positioned(
          top: size * 0.45,
          left: size * 0.35,
          child: Text('✨', style: TextStyle(fontSize: size * 0.06)),
        ),
      );
    }

    // Stars
    if (deco.hasStars) {
      widgets.add(
        Positioned(
          top: 5,
          left: 15,
          child: Text('⭐', style: TextStyle(fontSize: size * 0.06)),
        ),
      );
    }

    return Stack(children: widgets);
  }
}

class _TreePainter extends CustomPainter {
  final AvatarState state;

  _TreePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height * 0.85;

    // Draw ground
    _drawGround(canvas, size, groundY);

    // Draw trunk
    _drawTrunk(canvas, cx, groundY, size);

    // Draw canopy
    _drawCanopy(canvas, cx, groundY, size);
  }

  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _getGroundColor().withValues(alpha: 0.3),
          _getGroundColor().withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, size.height - groundY));

    final groundPath = Path()
      ..moveTo(0, groundY + 10)
      ..quadraticBezierTo(size.width * 0.25, groundY - 5, size.width * 0.5, groundY + 5)
      ..quadraticBezierTo(size.width * 0.75, groundY + 15, size.width, groundY + 5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(groundPath, groundPaint);

    // Small grass tufts
    if (state.stage.index >= TreeStage.steady.index) {
      final grassPaint = Paint()
        ..color = _getLeafColor().withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 8; i++) {
        final x = size.width * 0.1 + (i * size.width * 0.1);
        final baseY = groundY + 8;
        canvas.drawLine(Offset(x, baseY), Offset(x - 3, baseY - 8), grassPaint);
        canvas.drawLine(Offset(x, baseY), Offset(x + 3, baseY - 7), grassPaint);
      }
    }
  }

  void _drawTrunk(Canvas canvas, double cx, double groundY, Size size) {
    final trunkColor = _getTrunkColor();
    final trunkWidth = size.width * 0.06;
    final trunkHeight = size.height * 0.35;
    final trunkTop = groundY - trunkHeight;

    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          trunkColor,
          trunkColor.withValues(alpha: 0.7),
          trunkColor,
        ],
      ).createShader(Rect.fromCenter(center: Offset(cx, groundY - trunkHeight / 2), width: trunkWidth * 2, height: trunkHeight));

    // Main trunk
    final trunkPath = Path()
      ..moveTo(cx - trunkWidth, groundY)
      ..quadraticBezierTo(cx - trunkWidth * 0.8, groundY - trunkHeight * 0.5, cx - trunkWidth * 0.5, trunkTop)
      ..lineTo(cx + trunkWidth * 0.5, trunkTop)
      ..quadraticBezierTo(cx + trunkWidth * 0.8, groundY - trunkHeight * 0.5, cx + trunkWidth, groundY)
      ..close();

    canvas.drawPath(trunkPath, trunkPaint);

    // Branches
    if (state.stage.index >= TreeStage.steady.index) {
      final branchPaint = Paint()
        ..color = trunkColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Left branch
      final leftBranchStart = Offset(cx - trunkWidth * 0.3, trunkTop + trunkHeight * 0.3);
      final leftBranchEnd = Offset(cx - size.width * 0.18, trunkTop + trunkHeight * 0.1);
      canvas.drawLine(leftBranchStart, leftBranchEnd, branchPaint);

      // Right branch
      final rightBranchStart = Offset(cx + trunkWidth * 0.3, trunkTop + trunkHeight * 0.25);
      final rightBranchEnd = Offset(cx + size.width * 0.17, trunkTop + trunkHeight * 0.05);
      canvas.drawLine(rightBranchStart, rightBranchEnd, branchPaint);
    }
  }

  void _drawCanopy(Canvas canvas, double cx, double groundY, Size size) {
    final leafColor = _getLeafColor();
    final trunkHeight = size.height * 0.35;
    final canopyCenterY = groundY - trunkHeight - size.height * 0.1;
    final canopyRadius = size.width * 0.25 * (0.5 + state.health * 0.5);

    if (state.stage == TreeStage.withered) {
      // Just a few sad leaves
      _drawSadCanopy(canvas, cx, canopyCenterY, canopyRadius, leafColor);
      return;
    }

    // Main canopy blob
    final mainPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: [
          leafColor,
          leafColor.withValues(alpha: 0.8),
          leafColor.withValues(alpha: 0.5),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, canopyCenterY), radius: canopyRadius));

    // Draw multiple overlapping circles for organic canopy shape
    canvas.drawCircle(Offset(cx, canopyCenterY), canopyRadius, mainPaint);

    if (state.stage.index >= TreeStage.healthy.index) {
      canvas.drawCircle(Offset(cx - canopyRadius * 0.5, canopyCenterY + canopyRadius * 0.1), canopyRadius * 0.7, mainPaint);
      canvas.drawCircle(Offset(cx + canopyRadius * 0.5, canopyCenterY + canopyRadius * 0.1), canopyRadius * 0.7, mainPaint);
      canvas.drawCircle(Offset(cx, canopyCenterY - canopyRadius * 0.4), canopyRadius * 0.6, mainPaint);
    }

    if (state.stage == TreeStage.blooming) {
      // Extra lush canopy
      canvas.drawCircle(Offset(cx - canopyRadius * 0.7, canopyCenterY - canopyRadius * 0.1), canopyRadius * 0.5, mainPaint);
      canvas.drawCircle(Offset(cx + canopyRadius * 0.7, canopyCenterY - canopyRadius * 0.1), canopyRadius * 0.5, mainPaint);
    }

    // Highlight for depth
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - canopyRadius * 0.2, canopyCenterY - canopyRadius * 0.2), canopyRadius * 0.3, highlightPaint);
  }

  void _drawSadCanopy(Canvas canvas, double cx, double canopyCenterY, double radius, Color color) {
    final paint = Paint()..color = color.withValues(alpha: 0.4);

    // Just a couple small circles
    canvas.drawCircle(Offset(cx, canopyCenterY + 5), radius * 0.5, paint);
    canvas.drawCircle(Offset(cx - radius * 0.3, canopyCenterY + 8), radius * 0.35, paint);
    canvas.drawCircle(Offset(cx + radius * 0.3, canopyCenterY + 10), radius * 0.3, paint);
  }

  Color _getLeafColor() {
    switch (state.stage) {
      case TreeStage.blooming: return const Color(0xFF43A047);
      case TreeStage.healthy: return const Color(0xFF66BB6A);
      case TreeStage.steady: return const Color(0xFF81C784);
      case TreeStage.wilting: return const Color(0xFFBCAAA4);
      case TreeStage.withered: return const Color(0xFF8D6E63);
    }
  }

  Color _getTrunkColor() {
    switch (state.stage) {
      case TreeStage.blooming: return const Color(0xFF5D4037);
      case TreeStage.healthy: return const Color(0xFF6D4C41);
      case TreeStage.steady: return const Color(0xFF795548);
      case TreeStage.wilting: return const Color(0xFF8D6E63);
      case TreeStage.withered: return const Color(0xFF9E9E9E);
    }
  }

  Color _getGroundColor() {
    switch (state.stage) {
      case TreeStage.blooming: return const Color(0xFF66BB6A);
      case TreeStage.healthy: return const Color(0xFF81C784);
      case TreeStage.steady: return const Color(0xFFA5D6A7);
      case TreeStage.wilting: return const Color(0xFFBCAAA4);
      case TreeStage.withered: return const Color(0xFF9E9E9E);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.state.stage != state.stage ||
        oldDelegate.state.health != state.health;
  }
}
