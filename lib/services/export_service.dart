import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mood_entry.dart';
import '../utils/date_helpers.dart';

class ExportService {
  static Future<void> exportAsCsv(List<MoodEntry> entries) async {
    final rows = <List<dynamic>>[
      ['Date', 'Time', 'Mood', 'Emoji', 'Note', 'Journal', 'Tags'],
      ...entries.map((e) => [
            DateHelpers.formatDate(e.createdAt),
            DateHelpers.formatTime(e.createdAt),
            e.label,
            e.emoji,
            e.note ?? '',
            e.journalEntry ?? '',
            e.tags.join('; '),
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/moodloom_export.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'MoodLoom Mood Data');
  }

  static Future<void> exportAsJson(List<MoodEntry> entries) async {
    final data = entries
        .map((e) => {
              'date': DateHelpers.formatDate(e.createdAt),
              'time': DateHelpers.formatTime(e.createdAt),
              'mood_level': e.moodLevel,
              'mood_label': e.label,
              'emoji': e.emoji,
              'note': e.note,
              'journal_entry': e.journalEntry,
              'tags': e.tags,
            })
        .toList();

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/moodloom_export.json');
    await file.writeAsString(json);

    await Share.shareXFiles([XFile(file.path)], text: 'MoodLoom Mood Data');
  }
}
