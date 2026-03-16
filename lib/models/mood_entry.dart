class MoodEntry {
  final String id;
  final int moodLevel; // 1-5: 1=😢, 2=😔, 3=😐, 4=😊, 5=😄
  final String? note;
  final String? journalEntry;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  MoodEntry({
    required this.id,
    required this.moodLevel,
    this.note,
    this.journalEntry,
    required this.tags,
    required this.createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  }) : updatedAt = updatedAt ?? createdAt;

  static const Map<int, String> moodEmojis = {
    1: '😢',
    2: '😔',
    3: '😐',
    4: '😊',
    5: '😄',
  };

  static const Map<int, String> moodLabels = {
    1: 'Terrible',
    2: 'Bad',
    3: 'Okay',
    4: 'Good',
    5: 'Great',
  };

  String get emoji => moodEmojis[moodLevel] ?? '😐';
  String get label => moodLabels[moodLevel] ?? 'Okay';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood_level': moodLevel,
      'note': note,
      'journal_entry': journalEntry,
      'tags': tags.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.parse(map['created_at'] as String);
    return MoodEntry(
      id: map['id'] as String,
      moodLevel: map['mood_level'] as int,
      note: map['note'] as String?,
      journalEntry: map['journal_entry'] as String?,
      tags: (map['tags'] as String?)?.isNotEmpty == true
          ? (map['tags'] as String).split(',')
          : [],
      createdAt: createdAt,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : createdAt,
      isSynced: (map['is_synced'] as int?) == 1,
    );
  }

  factory MoodEntry.fromSupabase(Map<String, dynamic> map) {
    final tagsData = map['tags'];
    List<String> parsedTags = [];
    if (tagsData is List) {
      parsedTags = tagsData.cast<String>();
    } else if (tagsData is String && tagsData.isNotEmpty) {
      parsedTags = tagsData.split(',');
    }
    final createdAt = DateTime.parse(map['created_at'] as String);
    return MoodEntry(
      id: map['id'] as String,
      moodLevel: map['mood_level'] as int,
      note: map['note'] as String?,
      journalEntry: map['journal_entry'] as String?,
      tags: parsedTags,
      createdAt: createdAt,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : createdAt,
      isSynced: true,
    );
  }

  Map<String, dynamic> toSupabase(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'mood_level': moodLevel,
      'note': note,
      'journal_entry': journalEntry,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MoodEntry copyWith({
    String? id,
    int? moodLevel,
    String? note,
    String? journalEntry,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
      journalEntry: journalEntry ?? this.journalEntry,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
