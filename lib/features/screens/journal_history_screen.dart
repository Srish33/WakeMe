import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../widgets/journal_card.dart';
import 'journal_detail_screen.dart';
import '../models/mood_entry_model.dart';

class JournalHistoryScreen extends StatelessWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        title: const Text('JOURNAL HISTORY'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          final entries = provider.entries;

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_rounded, size: 64, color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 16),
                  const Text('No journals yet', style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          final groupedEntries = _groupEntriesByDate(entries);
          final sortedDates = groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateEntries = groupedEntries[date]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16, top: 8),
                    child: Text(
                      _formatHeaderDate(date),
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...dateEntries.map((entry) => JournalCard(
                    entry: entry,
                    isGridView: false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalDetailScreen(entry: entry)),
                      );
                    },
                    onDelete: () => provider.deleteEntry(entry.id),
                  )),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<DateTime, List<MoodEntryModel>> _groupEntriesByDate(List<MoodEntryModel> entries) {
    final Map<DateTime, List<MoodEntryModel>> grouped = {};
    for (var entry in entries) {
      final date = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }
    return grouped;
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'TODAY';
    if (date == yesterday) return 'YESTERDAY';
    return DateFormat('EEEE, MMM d').format(date).toUpperCase();
  }
}
