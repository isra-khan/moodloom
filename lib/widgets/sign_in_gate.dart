import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/auth/login_screen.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import 'emoji_widget.dart';

/// Full-screen prompt shown in tabs that require an authenticated account.
/// Tapping "Sign In" pushes the LoginScreen modally; on successful auth it
/// pops itself, and the caller's [onSignedIn] is invoked so the parent can
/// re-check auth state and rebuild.
class SignInGate extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onSignedIn;

  const SignInGate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onSignedIn,
    this.emoji = '✨',
  });

  Future<void> _openSignIn(BuildContext context) async {
    await Navigator.push(
      context,
      smoothPageRoute(
        page: LoginScreen(
          onLoginSuccess: () => Navigator.of(context).pop(),
        ),
      ),
    );
    onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: EmojiWidget(emoji: emoji, size: 60),
                ).animate().fadeIn(duration: 400.ms).scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                    ),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.15, end: 0),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => _openSignIn(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
