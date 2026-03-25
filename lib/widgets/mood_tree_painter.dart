import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/mood_avatar_service.dart';

class MoodTreeWidget extends StatefulWidget {
  final AvatarState state;
  final double size;

  const MoodTreeWidget({super.key, required this.state, this.size = 250});

  @override
  State<MoodTreeWidget> createState() => _MoodTreeWidgetState();
}

class _MoodTreeWidgetState extends State<MoodTreeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              final shimmerPos = _shimmerController.value * 2.0 - 0.5;
              return LinearGradient(
                begin: Alignment(shimmerPos - 0.3, -1),
                end: Alignment(shimmerPos + 0.3, 1),
                colors: const [
                  Color(0x00FFFFFF),
                  Color(0x44FFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: child,
          );
        },
        child: CustomPaint(
          painter: _TreePainter(state: widget.state),
          child: _buildOverlayDecorations(),
        ),
      ),
    );
  }

  Widget _buildOverlayDecorations() {
    final deco = widget.state.decoration;
    final size = widget.size;
    final widgets = <Widget>[];

    // Sparkle particles animated
    _addSparkles(widgets, size);

    // Sunshine
    if (deco.hasSunshine) {
      widgets.add(
        Positioned(
          top: 5,
          right: 15,
          child: _AnimatedFloat(
            child: Text('☀️', style: TextStyle(fontSize: size * 0.12)),
          ),
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
          child: _AnimatedFloat(
            offset: 0.3,
            child: Text('🐦', style: TextStyle(fontSize: size * 0.08)),
          ),
        ),
      );
      widgets.add(
        Positioned(
          top: 35,
          right: 40,
          child: _AnimatedFloat(
            offset: 0.7,
            child: Text('🐦', style: TextStyle(fontSize: size * 0.07)),
          ),
        ),
      );
    }

    // Butterflies
    if (deco.hasButterflies) {
      widgets.add(
        Positioned(
          top: size * 0.3,
          right: 25,
          child: _AnimatedFloat(
            child: Text('🦋', style: TextStyle(fontSize: size * 0.09)),
          ),
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
          child: _PulsingGlow(
            color: const Color(0xFFFFD54F),
            child: Text('✨', style: TextStyle(fontSize: size * 0.06)),
          ),
        ),
      );
      widgets.add(
        Positioned(
          top: size * 0.35,
          right: size * 0.28,
          child: _PulsingGlow(
            color: const Color(0xFFFFD54F),
            delay: 0.3,
            child: Text('✨', style: TextStyle(fontSize: size * 0.05)),
          ),
        ),
      );
      widgets.add(
        Positioned(
          top: size * 0.45,
          left: size * 0.35,
          child: _PulsingGlow(
            color: const Color(0xFFFFD54F),
            delay: 0.6,
            child: Text('✨', style: TextStyle(fontSize: size * 0.06)),
          ),
        ),
      );
    }

    // Stars
    if (deco.hasStars) {
      widgets.add(
        Positioned(
          top: 5,
          left: 15,
          child: _PulsingGlow(
            color: const Color(0xFFFFD54F),
            child: Text('⭐', style: TextStyle(fontSize: size * 0.06)),
          ),
        ),
      );
    }

    return Stack(children: widgets);
  }

  void _addSparkles(List<Widget> widgets, double size) {
    // Floating shimmer particles around the canopy
    final random = math.Random(42);
    for (int i = 0; i < 4; i++) {
      final x = size * 0.2 + random.nextDouble() * size * 0.6;
      final y = size * 0.1 + random.nextDouble() * size * 0.5;
      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: _ShimmerDot(delay: i * 0.25),
        ),
      );
    }
  }
}

/// A dot that fades in/out with a shimmer effect.
class _ShimmerDot extends StatefulWidget {
  final double delay;
  const _ShimmerDot({this.delay = 0});

  @override
  State<_ShimmerDot> createState() => _ShimmerDotState();
}

class _ShimmerDotState extends State<_ShimmerDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0), weight: 1),
    ]).animate(_controller);

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gently floats a widget up and down.
class _AnimatedFloat extends StatefulWidget {
  final Widget child;
  final double offset;
  const _AnimatedFloat({required this.child, this.offset = 0});

  @override
  State<_AnimatedFloat> createState() => _AnimatedFloatState();
}

class _AnimatedFloatState extends State<_AnimatedFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.15),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: (widget.offset * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// Adds a pulsing glow behind a widget.
class _PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double delay;
  const _PulsingGlow({required this.child, required this.color, this.delay = 0});

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
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
