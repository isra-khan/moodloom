import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

class TagProvider extends ChangeNotifier {
  final DatabaseService _db;
  List<String> _tags = [];

  static const List<String> defaultTags = [
    'Work',
    'Exercise',
    'Family',
    'Friends',
    'Stress',
    'Sleep',
    'Health',
    'Travel',
    'Food',
    'Music',
    'Study',
    'Nature',
  ];

  TagProvider(this._db);

  List<String> get tags => _tags;

  Future<void> loadTags() async {
    _tags = await _db.getCustomTags();
    if (_tags.isEmpty) {
      for (final tag in defaultTags) {
        await _db.addCustomTag(tag);
      }
      _tags = await _db.getCustomTags();
    }
    notifyListeners();
  }

  Future<void> addTag(String tag) async {
    await _db.addCustomTag(tag);
    await loadTags();
  }

  Future<void> deleteTag(String tag) async {
    await _db.deleteCustomTag(tag);
    await loadTags();
  }
}
