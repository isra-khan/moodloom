class DreamEntry {
  final String id;
  final String description;
  final int sleepQuality; // 1-5
  final bool remembered;
  final List<String> tags;
  final DateTime createdAt;

  DreamEntry({
    required this.id,
    required this.description,
    required this.sleepQuality,
    required this.remembered,
    required this.tags,
    required this.createdAt,
  });

  static const Map<int, String> sleepEmojis = {
    1: '😫',
    2: '😴',
    3: '😐',
    4: '😌',
    5: '🌙',
  };

  static const Map<int, String> sleepLabels = {
    1: 'Terrible',
    2: 'Poor',
    3: 'Fair',
    4: 'Good',
    5: 'Excellent',
  };

  String get sleepEmoji => sleepEmojis[sleepQuality] ?? '😐';
  String get sleepLabel => sleepLabels[sleepQuality] ?? 'Fair';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'sleep_quality': sleepQuality,
      'remembered': remembered ? 1 : 0,
      'tags': tags.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DreamEntry.fromMap(Map<String, dynamic> map) {
    return DreamEntry(
      id: map['id'] as String,
      description: map['description'] as String? ?? '',
      sleepQuality: map['sleep_quality'] as int,
      remembered: (map['remembered'] as int?) == 1,
      tags: (map['tags'] as String?)?.isNotEmpty == true
          ? (map['tags'] as String).split(',')
          : [],
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  DreamEntry copyWith({
    String? id,
    String? description,
    int? sleepQuality,
    bool? remembered,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return DreamEntry(
      id: id ?? this.id,
      description: description ?? this.description,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      remembered: remembered ?? this.remembered,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
