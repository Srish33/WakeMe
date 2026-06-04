import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../widgets/journal_card.dart';
import 'journal_detail_screen.dart';
import '../../core/theme/app_theme.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JOURNALS'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          final entries = moodProvider.entries;

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No journals yet',
                style: TextStyle(
                  color: isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor,
                ),
              ),
            );
          }

          if (isGridView) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return JournalCard(
                  entry: entry,
                  isGridView: true,
                  onTap: () => _navigateToDetail(entry),
                  onDelete: () => moodProvider.deleteEntry(entry.id),
                );
              },
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return JournalCard(
                  entry: entry,
                  isGridView: false,
                  onTap: () => _navigateToDetail(entry),
                  onDelete: () => moodProvider.deleteEntry(entry.id),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _navigateToDetail(dynamic entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalDetailScreen(entry: entry),
      ),
    );
  }
}
