class BreathingExercise {
  final String name;
  final String description;
  final String emoji;
  final List<BreathingPhase> phases;
  final int totalCycles;

  const BreathingExercise({
    required this.name,
    required this.description,
    required this.emoji,
    required this.phases,
    this.totalCycles = 4,
  });

  int get cycleDurationSeconds =>
      phases.fold(0, (sum, p) => sum + p.durationSeconds);

  int get totalDurationSeconds => cycleDurationSeconds * totalCycles;
}

class BreathingPhase {
  final String instruction;
  final int durationSeconds;
  final BreathingAction action;

  const BreathingPhase({
    required this.instruction,
    required this.durationSeconds,
    required this.action,
  });
}

enum BreathingAction { breatheIn, hold, breatheOut }

class BreathingService {
  static const List<BreathingExercise> exercises = [
    BreathingExercise(
      name: '4-7-8 Relaxation',
      description: 'A calming technique that reduces anxiety and helps you sleep. Breathe in for 4, hold for 7, out for 8.',
      emoji: '🌊',
      phases: [
        BreathingPhase(instruction: 'Breathe In', durationSeconds: 4, action: BreathingAction.breatheIn),
        BreathingPhase(instruction: 'Hold', durationSeconds: 7, action: BreathingAction.hold),
        BreathingPhase(instruction: 'Breathe Out', durationSeconds: 8, action: BreathingAction.breatheOut),
      ],
      totalCycles: 4,
    ),
    BreathingExercise(
      name: 'Box Breathing',
      description: 'Used by Navy SEALs for focus and calm. Equal counts of 4 for each phase.',
      emoji: '📦',
      phases: [
        BreathingPhase(instruction: 'Breathe In', durationSeconds: 4, action: BreathingAction.breatheIn),
        BreathingPhase(instruction: 'Hold', durationSeconds: 4, action: BreathingAction.hold),
        BreathingPhase(instruction: 'Breathe Out', durationSeconds: 4, action: BreathingAction.breatheOut),
        BreathingPhase(instruction: 'Hold', durationSeconds: 4, action: BreathingAction.hold),
      ],
      totalCycles: 4,
    ),
    BreathingExercise(
      name: 'Energizing Breath',
      description: 'Quick breathing to boost energy and alertness. Short sharp breaths.',
      emoji: '⚡',
      phases: [
        BreathingPhase(instruction: 'Breathe In', durationSeconds: 2, action: BreathingAction.breatheIn),
        BreathingPhase(instruction: 'Breathe Out', durationSeconds: 2, action: BreathingAction.breatheOut),
      ],
      totalCycles: 10,
    ),
    BreathingExercise(
      name: '5-5 Balance',
      description: 'Simple balanced breathing to center yourself and find calm.',
      emoji: '⚖️',
      phases: [
        BreathingPhase(instruction: 'Breathe In', durationSeconds: 5, action: BreathingAction.breatheIn),
        BreathingPhase(instruction: 'Breathe Out', durationSeconds: 5, action: BreathingAction.breatheOut),
      ],
      totalCycles: 6,
    ),
  ];

  static BreathingExercise getRecommendation(int moodLevel) {
    if (moodLevel <= 2) return exercises[0]; // 4-7-8 for low mood
    if (moodLevel == 3) return exercises[3]; // 5-5 Balance for neutral
    return exercises[2]; // Energizing for good mood
  }
}
