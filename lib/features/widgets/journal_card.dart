import 'package:flutter/material.dart';
import '../models/mood_entry_model.dart';
import '../../core/theme/app_colors.dart';
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
    final primaryTextColor = theme.colorScheme.onSurface;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptions(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  if (entry.audioPaths.isNotEmpty)
                    Icon(Icons.mic_rounded, size: 16, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.title ?? 'No Title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  entry.note,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryTextColor.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM d').format(entry.createdAt),
                style: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
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
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white10),
      ),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
        ),
        onDismissed: (_) => onDelete(),
        child: ListTile(
          onTap: onTap,
          onLongPress: () => _showOptions(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            entry.title ?? 'No Title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                if (entry.audioPaths.isNotEmpty) ...[
                  Icon(Icons.mic_none_rounded, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    entry.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.mood,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d').format(entry.createdAt),
                style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.3), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                  title: const Text('Edit Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    onTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Delete Note', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
