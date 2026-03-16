class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int requirement;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.requirement,
    required this.type,
  });

  static const List<Achievement> all = [
    Achievement(id: 'first_entry', title: 'First Step', description: 'Log your first mood', emoji: '🌱', requirement: 1, type: AchievementType.totalEntries),
    Achievement(id: 'entries_10', title: 'Getting Started', description: 'Log 10 mood entries', emoji: '🌿', requirement: 10, type: AchievementType.totalEntries),
    Achievement(id: 'entries_50', title: 'Mood Explorer', description: 'Log 50 mood entries', emoji: '🌳', requirement: 50, type: AchievementType.totalEntries),
    Achievement(id: 'entries_100', title: 'Mood Master', description: 'Log 100 mood entries', emoji: '🏆', requirement: 100, type: AchievementType.totalEntries),
    Achievement(id: 'entries_500', title: 'Mood Legend', description: 'Log 500 mood entries', emoji: '👑', requirement: 500, type: AchievementType.totalEntries),
    Achievement(id: 'streak_3', title: 'Hat Trick', description: '3-day logging streak', emoji: '🔥', requirement: 3, type: AchievementType.streak),
    Achievement(id: 'streak_7', title: 'Week Warrior', description: '7-day logging streak', emoji: '⚡', requirement: 7, type: AchievementType.streak),
    Achievement(id: 'streak_14', title: 'Two Weeks Strong', description: '14-day logging streak', emoji: '💪', requirement: 14, type: AchievementType.streak),
    Achievement(id: 'streak_30', title: 'Monthly Champion', description: '30-day logging streak', emoji: '🌟', requirement: 30, type: AchievementType.streak),
    Achievement(id: 'streak_100', title: 'Centurion', description: '100-day logging streak', emoji: '💎', requirement: 100, type: AchievementType.streak),
    Achievement(id: 'journal_5', title: 'Dear Diary', description: 'Write 5 journal entries', emoji: '📖', requirement: 5, type: AchievementType.journalEntries),
    Achievement(id: 'journal_25', title: 'Storyteller', description: 'Write 25 journal entries', emoji: '✍️', requirement: 25, type: AchievementType.journalEntries),
  ];
}

enum AchievementType {
  totalEntries,
  streak,
  journalEntries,
}
