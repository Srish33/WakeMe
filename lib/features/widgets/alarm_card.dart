import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../../core/theme/app_theme.dart';

class AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor = isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor;
    final primaryTextColor = isDark ? AppTheme.primaryTextColor : AppTheme.lightPrimaryTextColor;

    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(7, (index) {
                      final isSelected = alarm.repeatDays.contains(dayNames[index]);
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Text(
                          days[index],
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryPurple : secondaryColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                      if (value == 'edit') onTap();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    icon: Icon(Icons.more_vert, color: secondaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.timeFormatted.toLowerCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      if (alarm.label != null && alarm.label!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.label_outline, size: 14, color: secondaryColor),
                            const SizedBox(width: 4),
                            Text(
                              alarm.label!,
                              style: TextStyle(color: secondaryColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: onToggle,
                    activeTrackColor: AppTheme.primaryPurple.withValues(alpha: 0.5),
                    activeThumbColor: AppTheme.primaryPurple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
