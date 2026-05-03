import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../services/auth_service.dart';
import '../services/mood_prediction_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emoji_widget.dart';
import '../widgets/sign_in_gate.dart';
import 'breathing_screen.dart';
import 'dream_journal_screen.dart';
import 'mood_avatar_screen.dart';
import 'mood_map_screen.dart';
import 'mood_ripple_screen.dart';
import 'time_capsule_screen.dart';
import '../utils/page_transitions.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      return SignInGate(
        title: 'Discover is for members',
        subtitle: 'Sign in to unlock your mood tree, breathing exercises, dream journal, time capsule, and more.',
        emoji: '✨',
        onSignedIn: () {
          if (mounted) setState(() {}); // Re-check auth after returning
        },
      );
    }
    return _buildDiscoverContent(context);
  }

  Widget _buildDiscoverContent(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Tools for your wellness journey',
                style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
              ).animate(delay: 50.ms).fadeIn(),
              const SizedBox(height: 20),

              // Mood Forecast card
              Consumer<MoodProvider>(
                builder: (context, mood, _) {
                  final forecast = MoodPredictionService.predictTomorrow(mood.allEntries);
                  if (forecast == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ForecastCard(forecast: forecast),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0);
                },
              ),

              // Feature grid
              _FeatureTile(
                title: 'Your MoodLoom Tree',
                subtitle: 'A living tree that grows with your mood',
                emoji: '🌳',
                color: const Color(0xFF43A047),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const MoodAvatarScreen())),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              _FeatureTile(
                title: 'Breathing Exercises',
                subtitle: 'Guided breathing for calm & focus',
                emoji: '🌊',
                color: const Color(0xFF4DB6AC),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const BreathingScreen())),
              ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              _FeatureTile(
                title: 'Dream Journal',
                subtitle: 'Track dreams & sleep-mood correlation',
                emoji: '🌙',
                color: const Color(0xFF7E57C2),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const DreamJournalScreen())),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              _FeatureTile(
                title: 'Time Capsule',
                subtitle: 'Write letters to your future self',
                emoji: '💌',
                color: const Color(0xFFE91E63),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const TimeCapsuleScreen())),
              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              _FeatureTile(
                title: 'Mood Weather Map',
                subtitle: 'See how places affect your mood',
                emoji: '📍',
                color: const Color(0xFF42A5F5),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const MoodMapScreen())),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),

              _FeatureTile(
                title: 'Mood Ripple',
                subtitle: 'See how the world is feeling today',
                emoji: '🌍',
                color: const Color(0xFF26A69A),
                onTap: () => Navigator.push(context, smoothPageRoute(page: const MoodRippleScreen())),
              ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final MoodForecast forecast;
  const _ForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return NeuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EmojiWidget(emoji: forecast.weatherIcon, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tomorrow's Forecast", style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5))),
                    Text(
                      forecast.weatherLabel,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  EmojiWidget(emoji: forecast.emoji, size: 28),
                  Text(
                    forecast.predictedMood.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            forecast.reason,
            style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${forecast.confidence} confidence',
              style: const TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return NeuButton(
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: EmojiWidget(emoji: emoji, size: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
