import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTeal = Color(0xFF008080);
  static const Color lightTeal = Color(0xFF4DB6AC);
  static const Color darkTeal = Color(0xFF00695C);
  static const Color accentTeal = Color(0xFF80CBC4);
  static const Color surfaceColor = Color(0xFFE8F0F0);
  static const Color darkSurface = Color(0xFFD0DEDE);
  static const Color white = Colors.white;
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0xFFB0C4C4);

  // Dark mode colors
  static const Color darkBg = Color(0xFF1A2E2E);
  static const Color darkCard = Color(0xFF243B3B);
  static const Color darkShadowLight = Color(0xFF2D4A4A);
  static const Color darkShadowDark = Color(0xFF0F1E1E);
  static const Color darkText = Color(0xFFE0F2F1);

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightTeal, primaryTeal, darkTeal],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
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
    final shadowL = isDark ? AppTheme.darkShadowLight : AppTheme.shadowLight;
    final shadowD = isDark ? AppTheme.darkShadowDark : AppTheme.shadowDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: shadowD.withValues(alpha: 0.3 * intensity),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: shadowL.withValues(alpha: 0.7 * intensity),
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowD.withValues(alpha: 0.4 * intensity),
                  offset: const Offset(6, 6),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: shadowL.withValues(alpha: isDark ? 0.3 : 0.9 * intensity),
                  offset: const Offset(-6, -6),
                  blurRadius: 15,
                  spreadRadius: 1,
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

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: NeuBox(
        isPressed: _isPressed,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}
