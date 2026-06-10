import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/mood_provider.dart';
import '../models/mood_entry_model.dart';
import 'journal_history_screen.dart';
import 'mood_entry_screen.dart';
import 'journal_detail_screen.dart';
import '../../core/theme/app_colors.dart';

class MoodBoardScreen extends StatefulWidget {
  const MoodBoardScreen({super.key});

  @override
  State<MoodBoardScreen> createState() => _MoodBoardScreenState();
}

class _MoodBoardScreenState extends State<MoodBoardScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MOOD BOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JournalHistoryScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          final entries = provider.entries;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isAfter(DateTime.now())) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(color: Colors.white70),
                    weekendTextStyle: const TextStyle(color: Colors.white38),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final dayEntries = entries.where((e) => isSameDay(e.createdAt, day)).toList();
                      if (dayEntries.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: Text(
                            dayEntries.first.mood,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DAILY ENTRIES',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (!(_selectedDay?.isAfter(DateTime.now()) ?? false))
                            TextButton.icon(
                              onPressed: () => _navigateToCreate(_selectedDay ?? DateTime.now()),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                              label: const Text('ADD ENTRY'),
                              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDayEntriesList(entries),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayEntriesList(List<MoodEntryModel> allEntries) {
    final dayEntries = allEntries.where((e) => isSameDay(e.createdAt, _selectedDay)).toList();

    if (dayEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_note_rounded, size: 48, color: Colors.white.withValues(alpha: 0.05)),
              const SizedBox(height: 12),
              const Text(
                'No entries for this day',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayEntries.length,
      itemBuilder: (context, index) {
        final entry = dayEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalDetailScreen(entry: entry)),
              );
            },
            leading: Text(entry.mood, style: const TextStyle(fontSize: 24)),
            title: Text(
              entry.title ?? 'Untitled Entry',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              entry.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
          ),
        );
      },
    );
  }

  void _navigateToCreate(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodEntryScreen(initialDate: date),
      ),
    );
  }
}
