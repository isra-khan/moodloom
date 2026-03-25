import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/emoji_widget.dart';
import '../utils/date_helpers.dart';
import '../utils/page_transitions.dart';
import '../widgets/mood_entry_tile.dart';
import 'journal_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;
  int? _moodFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final mood = context.read<MoodProvider>();
    final query = _searchController.text.trim();

    if (_dateRange != null) {
      mood.filterByDateRange(_dateRange!.start, _dateRange!.end);
    } else if (query.isNotEmpty) {
      mood.searchEntries(query);
    } else {
      mood.loadAllEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      NeuButton(
                        onPressed: () => Navigator.pop(context),
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.darkTeal),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Search & Filter',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: 16),

                  // Search bar
                  NeuBox(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppTheme.darkTeal.withValues(alpha: 0.4)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _performSearch(),
                            decoration: InputDecoration(
                              hintText: 'Search notes, tags...',
                              hintStyle: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.3)),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppTheme.darkTeal),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: AppTheme.darkTeal),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch();
                            },
                          ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 12),

                  // Filters row
                  Row(
                    children: [
                      // Date range filter
                      Expanded(
                        child: NeuButton(
                          onPressed: () async {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (range != null) {
                              setState(() => _dateRange = range);
                              _performSearch();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.date_range, size: 16, color: AppTheme.primaryTeal),
                              const SizedBox(width: 6),
                              Text(
                                _dateRange != null
                                    ? '${DateHelpers.formatDate(_dateRange!.start).substring(0, 6)} - ${DateHelpers.formatDate(_dateRange!.end).substring(0, 6)}'
                                    : 'Date Range',
                                style: const TextStyle(fontSize: 12, color: AppTheme.darkTeal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mood filter
                      NeuButton(
                        onPressed: () {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.surfaceColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (_) => _buildMoodFilterSheet(),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, size: 16, color: AppTheme.primaryTeal),
                            const SizedBox(width: 4),
                            Text(
                              _moodFilter != null ? ['', '😢', '😔', '😐', '😊', '😄'][_moodFilter!] : 'Mood',
                              style: const TextStyle(fontSize: 12, color: AppTheme.darkTeal),
                            ),
                          ],
                        ),
                      ),
                      if (_dateRange != null || _moodFilter != null) ...[
                        const SizedBox(width: 8),
                        NeuButton(
                          onPressed: () {
                            setState(() {
                              _dateRange = null;
                              _moodFilter = null;
                              _searchController.clear();
                            });
                            context.read<MoodProvider>().loadAllEntries();
                          },
                          padding: const EdgeInsets.all(10),
                          borderRadius: 12,
                          child: const Icon(Icons.clear, size: 16, color: Colors.red),
                        ),
                      ],
                    ],
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                ],
              ),
            ),

            // Results
            Expanded(
              child: Consumer<MoodProvider>(
                builder: (context, mood, _) {
                  final entries = _searchController.text.isNotEmpty || _dateRange != null
                      ? mood.filteredEntries
                      : mood.allEntries;

                  final filtered = _moodFilter != null
                      ? entries.where((e) => e.moodLevel == _moodFilter).toList()
                      : entries;

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No entries found',
                        style: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.4)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MoodEntryTile(
                          entry: filtered[index],
                          onTap: () {
                            Navigator.push(context, smoothPageRoute(
                              page: JournalDetailScreen(entry: filtered[index]),
                            ));
                          },
                        ).animate(delay: Duration(milliseconds: index * 50))
                            .fadeIn()
                            .slideX(begin: 0.05, end: 0),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodFilterSheet() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter by Mood',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkTeal,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4, 5].map((level) {
              return GestureDetector(
                onTap: () {
                  setState(() => _moodFilter = level);
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    EmojiWidget(emoji: ['', '😢', '😔', '😐', '😊', '😄'][level], size: 36),
                    const SizedBox(height: 4),
                    Text(
                      ['', 'Terrible', 'Bad', 'Okay', 'Good', 'Great'][level],
                      style: const TextStyle(fontSize: 11, color: AppTheme.darkTeal),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
