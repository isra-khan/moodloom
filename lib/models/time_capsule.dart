class TimeCapsule {
  final String id;
  final String message;
  final int moodWhenWritten; // 1-5
  final DateTime createdAt;
  final DateTime unlockAt;
  final bool isOpened;

  TimeCapsule({
    required this.id,
    required this.message,
    required this.moodWhenWritten,
    required this.createdAt,
    required this.unlockAt,
    this.isOpened = false,
  });

  bool get isUnlocked => DateTime.now().isAfter(unlockAt);

  Duration get timeRemaining => unlockAt.difference(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'mood_when_written': moodWhenWritten,
      'created_at': createdAt.toIso8601String(),
      'unlock_at': unlockAt.toIso8601String(),
      'is_opened': isOpened ? 1 : 0,
    };
  }

  factory TimeCapsule.fromMap(Map<String, dynamic> map) {
    return TimeCapsule(
      id: map['id'] as String,
      message: map['message'] as String,
      moodWhenWritten: map['mood_when_written'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      unlockAt: DateTime.parse(map['unlock_at'] as String),
      isOpened: (map['is_opened'] as int?) == 1,
    );
  }

  TimeCapsule copyWith({
    String? id,
    String? message,
    int? moodWhenWritten,
    DateTime? createdAt,
    DateTime? unlockAt,
    bool? isOpened,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      message: message ?? this.message,
      moodWhenWritten: moodWhenWritten ?? this.moodWhenWritten,
      createdAt: createdAt ?? this.createdAt,
      unlockAt: unlockAt ?? this.unlockAt,
      isOpened: isOpened ?? this.isOpened,
    );
  }
}
