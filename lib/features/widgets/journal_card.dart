import 'package:flutter/material.dart';
import '../models/mood_entry_model.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class JournalCard extends StatelessWidget {
  final MoodEntryModel entry;
  final bool isGridView;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const JournalCard({
    super.key,
    required this.entry,
    required this.isGridView,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard(context);
    } else {
      return _buildListTile(context);
    }
  }

  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppTheme.primaryTextColor : AppTheme.lightPrimaryTextColor;
    final secondaryTextColor = isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor;

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptions(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.mood,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    DateFormat('MMM d').format(entry.createdAt),
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.title ?? 'No Title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  entry.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDelete(),
        child: ListTile(
          onTap: onTap,
          onLongPress: () => _showOptions(context),
          title: Text(
            entry.title ?? 'No Title',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            entry.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: secondaryTextColor),
          ),
          trailing: Text(
            entry.mood,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primaryPurple),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
