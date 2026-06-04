import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';
import '../../core/theme/app_theme.dart';
import 'alarm_form_screen.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALARM'),
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          final alarms = alarmProvider.alarms;
          if (alarms.isEmpty) {
            return Center(
              child: Text(
                'No alarms set',
                style: TextStyle(
                  color: isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return AlarmCard(
                alarm: alarm,
                onToggle: (value) => alarmProvider.toggleAlarm(alarm.id),
                onDelete: () => alarmProvider.deleteAlarm(alarm.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlarmFormScreen(alarm: alarm),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AlarmFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
