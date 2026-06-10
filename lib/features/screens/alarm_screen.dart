import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../widgets/alarm_card.dart';
import '../services/alarm_service.dart';
import 'alarm_form_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

// The primary dashboard screen displaying active and inactive alarms.
class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission(); // Verify native system permissions on load
  }

  // Non-blocking permission check
  Future<void> _checkPermission() async {
    final granted = await AlarmService.checkExactAlarmPermission();
    if (mounted) {
      setState(() => _hasPermission = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('WaKeMe')),
      body: Stack(
        children: [
          // Theme-based background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF12121A), const Color(0xFF1A1A2E)]
                    : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Premium warning banner shown only when technical permissions are missing
                if (!_hasPermission)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 100,
                      borderRadius: 24,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark 
                          ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)]
                          : [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.02)],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                          theme.colorScheme.primary.withValues(alpha: 0.3),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.primary, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Action Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Enable Alarms & Reminders for accuracy.',
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : const Color(0xFF64748B), 
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await AlarmService.requestPermissions();
                                _checkPermission();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('ENABLE', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),

                // Main alarm list synchronized with provider state
                Expanded(
                  child: Consumer<AlarmProvider>(
                    builder: (context, alarmProvider, child) {
                      final alarms = alarmProvider.alarms;
                      if (alarms.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.alarm_off_rounded, size: 64, color: isDark ? Colors.white10 : Colors.black12),
                              const SizedBox(height: 16),
                              const Text('No alarms scheduled', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                MaterialPageRoute(builder: (context) => AlarmFormScreen(alarm: alarm)),
                              );
                            },
                          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Technical + button with non-standard Material styling
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlarmFormScreen()),
          );
        },
        child: const Icon(Icons.add_rounded, size: 32),
      ).animate().scale(delay: 400.ms),
    );
  }
}
