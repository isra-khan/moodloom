import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/breathing_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emoji_widget.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  BreathingExercise? _selectedExercise;
  bool _isRunning = false;
  int _currentPhase = 0;
  int _currentCycle = 0;
  int _phaseSecondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise(BreathingExercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _isRunning = true;
      _currentPhase = 0;
      _currentCycle = 0;
      _phaseSecondsLeft = exercise.phases[0].durationSeconds;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _phaseSecondsLeft--;
        if (_phaseSecondsLeft <= 0) {
          _nextPhase();
        }
      });
    });
  }

  void _nextPhase() {
    final exercise = _selectedExercise!;
    _currentPhase++;
    if (_currentPhase >= exercise.phases.length) {
      _currentPhase = 0;
      _currentCycle++;
      if (_currentCycle >= exercise.totalCycles) {
        _stopExercise();
        return;
      }
    }
    _phaseSecondsLeft = exercise.phases[_currentPhase].durationSeconds;
  }

  void _stopExercise() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentPhase = 0;
      _currentCycle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: _isRunning ? _buildExerciseView(textColor) : _buildSelectionView(textColor),
      ),
    );
  }

  Widget _buildSelectionView(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuButton(
                onPressed: () => Navigator.pop(context),
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
              ),
              const SizedBox(width: 16),
              Text(
                'Breathing Exercises',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            'Take a moment to breathe and center yourself',
            style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.6)),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 24),
          ...BreathingService.exercises.asMap().entries.map((entry) {
            final i = entry.key;
            final exercise = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: NeuButton(
                onPressed: () => _startExercise(exercise),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: EmojiWidget(emoji: exercise.emoji, size: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.description,
                            style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.6)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise.totalCycles} cycles  •  ~${exercise.totalDurationSeconds}s',
                            style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.play_circle_fill, color: AppTheme.primaryTeal, size: 32),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 150 + i * 80)).fadeIn().slideY(begin: 0.1, end: 0),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseView(Color textColor) {
    final exercise = _selectedExercise!;
    final phase = exercise.phases[_currentPhase];
    final totalPhaseSeconds = phase.durationSeconds;
    final progress = 1.0 - (_phaseSecondsLeft / totalPhaseSeconds);

    Color phaseColor;
    switch (phase.action) {
      case BreathingAction.breatheIn:
        phaseColor = AppTheme.lightTeal;
      case BreathingAction.hold:
        phaseColor = AppTheme.primaryTeal;
      case BreathingAction.breatheOut:
        phaseColor = AppTheme.darkTeal;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeuButton(
                onPressed: _stopExercise,
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.close, size: 18, color: textColor),
              ),
              Text(
                exercise.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
              ),
              Text(
                'Cycle ${_currentCycle + 1}/${exercise.totalCycles}',
                style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated breathing circle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.6, end: phase.action == BreathingAction.breatheIn ? 1.0 : (phase.action == BreathingAction.hold ? 1.0 : 0.6)),
                        duration: Duration(seconds: totalPhaseSeconds),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    phaseColor.withValues(alpha: 0.3),
                                    phaseColor.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(color: phaseColor.withValues(alpha: 0.5), width: 3),
                              ),
                            ),
                          );
                        },
                      ),
                      // Progress ring
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: phaseColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(phaseColor),
                        ),
                      ),
                      // Timer text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_phaseSecondsLeft',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: phaseColor),
                          ),
                          Text(
                            phase.instruction,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Phase indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: exercise.phases.asMap().entries.map((entry) {
                    final i = entry.key;
                    final p = entry.value;
                    final isActive = i == _currentPhase;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isActive ? 14 : 10,
                            height: isActive ? 14 : 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? phaseColor : textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${p.durationSeconds}s',
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive ? phaseColor : textColor.withValues(alpha: 0.4),
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                NeuButton(
                  onPressed: _stopExercise,
                  child: const Text('Stop', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
