import 'package:flutter/material.dart';

class AppTheme {
  // Hot Pink / Magenta palette
  // (Names kept as *Teal for backwards compatibility with existing references.)
  static const Color primaryTeal = Color(0xFFD63384);
  static const Color lightTeal = Color(0xFFE872AB);
  static const Color darkTeal = Color(0xFF8E1F58);
  static const Color accentTeal = Color(0xFFF5C2DC);
  static const Color surfaceColor = Color(0xFFFAF0F5);
  static const Color darkSurface = Color(0xFFEFD4E1);
  static const Color white = Colors.white;
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0xFFD0A8BC);

  // Dark mode colors
  static const Color darkBg = Color(0xFF24121C);
  static const Color darkCard = Color(0xFF351B2A);
  static const Color darkShadowLight = Color(0xFF482638);
  static const Color darkShadowDark = Color(0xFF160910);
  static const Color darkText = Color(0xFFF5DEEB);

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightTeal, primaryTeal, darkTeal],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBE5EF), Color(0xFFF5C2DC)],
  );

  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: surfaceColor,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primaryTeal,
          secondary: lightTeal,
          surface: surfaceColor,
          onPrimary: white,
          onSecondary: white,
          onSurface: darkTeal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: darkTeal,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryTeal,
          foregroundColor: white,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: darkBg,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: lightTeal,
          secondary: accentTeal,
          surface: darkCard,
          onPrimary: darkBg,
          onSecondary: darkBg,
          onSurface: darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: darkText,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryTeal,
          foregroundColor: white,
        ),
      );

  // Keep old getter for compatibility
  static ThemeData get theme => lightTheme;
}

class NeuBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isPressed;
  final double intensity;

  const NeuBox({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.isPressed = false,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkCard : AppTheme.surfaceColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            offset: Offset(0, isPressed ? 1 : 2),
            blurRadius: isPressed ? 4 : 8,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeuButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsets padding;

  const NeuButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: NeuBox(
          isPressed: _isPressed,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}
