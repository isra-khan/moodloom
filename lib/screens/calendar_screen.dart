import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/mood_colors.dart';
import '../widgets/mood_entry_tile.dart';
import 'journal_detail_screen.dart';
import 'mood_share_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MoodProvider>(
          builder: (context, mood, _) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeuButton(
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                            );
                          });
                        },
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.chevron_left, color: AppTheme.darkTeal),
                      ),
                      Text(
                        DateHelpers.formatMonthYear(_currentMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      NeuButton(
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime(
                              _currentMonth.year,
                              _currentMonth.month + 1,
                            );
                          });
                        },
                        borderRadius: 12,
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.chevron_right, color: AppTheme.darkTeal),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                // Day labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkTeal.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Calendar grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: NeuBox(
                    padding: const EdgeInsets.all(12),
                    child: _buildCalendarGrid(mood),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 16),

                // Selected day entries
                if (_selectedDate != null)
                  Expanded(
                    child: _buildDayEntries(mood),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(MoodProvider mood) {
    final daysInMonth = DateHelpers.daysInMonth(_currentMonth);
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 1; i < startingWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final entries = mood.getEntriesForDate(date);
      final isToday = DateHelpers.isSameDay(date, DateTime.now());
      final isSelected = _selectedDate != null && DateHelpers.isSameDay(date, _selectedDate!);

      double avgMood = 0;
      if (entries.isNotEmpty) {
        avgMood = entries.map((e) => e.moodLevel).reduce((a, b) => a + b) / entries.length;
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                  : isToday
                      ? AppTheme.accentTeal.withValues(alpha: 0.1)
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: isToday
                  ? Border.all(color: AppTheme.primaryTeal, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryTeal : AppTheme.darkTeal,
                  ),
                ),
                if (entries.isNotEmpty)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MoodColors.getColor(avgMood.round()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildDayEntries(MoodProvider mood) {
    final entries = mood.getEntriesForDate(_selectedDate!);
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: NeuBox(
          child: Center(
            child: Text(
              'No mood entries for ${DateHelpers.formatDate(_selectedDate!)}',
              style: TextStyle(color: AppTheme.darkTeal.withValues(alpha: 0.5)),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Share button for selected day
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelpers.formatDate(_selectedDate!),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              NeuButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MoodShareScreen(entries: entries, date: _selectedDate!),
                  ));
                },
                borderRadius: 12,
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.share, size: 18, color: AppTheme.primaryTeal),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MoodEntryTile(
                  entry: entries[index],
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => JournalDetailScreen(entry: entries[index]),
                    ));
                  },
                ).animate(delay: Duration(milliseconds: index * 60))
                    .fadeIn()
                    .slideX(begin: 0.05, end: 0),
              );
            },
          ),
        ),
      ],
    );
  }
}
