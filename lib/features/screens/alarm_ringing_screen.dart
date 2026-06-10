import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'routine_reminder_screen.dart';
import 'routine_completion_screen.dart';
import 'challenge_screen.dart';
import '../providers/alarm_provider.dart';
import '../providers/analytics_provider.dart';

// The high-fidelity, full-screen UI shown when an alarm triggers.
// Optimized for heavy blur background and large touch targets.
class AlarmRingingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingingScreen({super.key, required this.alarmSettings});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep Tech background layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF12121A), Color(0xFF1E1E2A)],
              ),
            ),
          ),
          
          // 2. Interactive Pulse animation behind the time
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 2.seconds, curve: Curves.easeOut)
             .fadeOut(duration: 2.seconds),
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 60),
                
                // Header: Notification Info
                Column(
                  children: [
                    Text(
                      'ALARM IS RINGING',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 4,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    Text(
                      _formatTime(DateTime.now()),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 8),
                    Text(
                      alarmSettings.notificationSettings.body,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                // Footer: Snooze and Dismiss actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Column(
                    children: [
                      // Snooze action with custom duration logic
                      GestureDetector(
                        onTap: () {
                          final alarmProvider = context.read<AlarmProvider>();
                          alarmProvider.incrementSnoozeCount(alarmSettings.id);
                          
                          final alarm = alarmProvider.getAlarmByHashCode(alarmSettings.id);
                          final snoozeDuration = alarm?.snoozeDuration ?? 9;
                          
                          final now = DateTime.now();
                          Alarm.set(
                            alarmSettings: alarmSettings.copyWith(
                              dateTime: now.add(Duration(minutes: snoozeDuration)),
                            ),
                          ).then((_) {
                            if (context.mounted) Navigator.pop(context);
                          });
                        },
                        child: Consumer<AlarmProvider>(
                          builder: (context, provider, child) {
                            final alarm = provider.getAlarmByHashCode(alarmSettings.id);
                            final snoozeDuration = alarm?.snoozeDuration ?? 9;
                            return GlassmorphicContainer(
                              width: double.infinity,
                              height: 60,
                              borderRadius: 30,
                              blur: 20,
                              alignment: Alignment.center,
                              border: 1,
                              linearGradient: LinearGradient(
                                colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
                              ),
                              borderGradient: LinearGradient(
                                colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)],
                              ),
                              child: Text(
                                'SNOOZE (${snoozeDuration}M)',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                            );
                          },
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .shimmer(duration: 3.seconds, color: Colors.white10),

                      const SizedBox(height: 24),

                      // Custom slider to dismiss the alarm and begin the challenge phase
                      _DismissSlider(
                        onDismissed: () {
                          // Stop the alarm sound to enter the challenge phase
                          Alarm.stop(alarmSettings.id).then((_) {
                            if (context.mounted) {
                              final alarmProvider = context.read<AlarmProvider>();
                              final analyticsProvider = context.read<AnalyticsProvider>();
                              final alarm = alarmProvider.getAlarmByHashCode(alarmSettings.id);
                              
                              if (alarm != null) {
                                // Calculate scheduled time to measure wake-up delay
                                DateTime scheduledTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  alarm.hour,
                                  alarm.minute,
                                );
                                
                                if (scheduledTime.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
                                  scheduledTime = scheduledTime.subtract(const Duration(days: 1));
                                }
                                
                                // Save session metrics for reports
                                analyticsProvider.recordAlarmSession(
                                  alarmTime: scheduledTime,
                                  actualWakeUpTime: DateTime.now(),
                                  snoozeCount: alarmProvider.getSnoozeCount(alarmSettings.id),
                                );

                                alarmProvider.resetSnoozeCount(alarmSettings.id);

                                // Transition to Challenge Screen with timing data
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChallengeScreen(
                                      alarm: alarm,
                                      scheduledTime: scheduledTime,
                                      snoozeCount: alarmProvider.getSnoozeCount(alarmSettings.id),
                                      onFail: () {
                                        // If challenge fails, re-trigger the alarm and return to this screen
                                        Alarm.set(alarmSettings: alarmSettings);
                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => AlarmRingingScreen(alarmSettings: alarmSettings)),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final m = time.minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$m';
  }
}

// Interactive slider component to prevent accidental alarm dismissal
class _DismissSlider extends StatefulWidget {
  final VoidCallback onDismissed;

  const _DismissSlider({super.key, required this.onDismissed});

  @override
  State<_DismissSlider> createState() => _DismissSliderState();
}

class _DismissSliderState extends State<_DismissSlider> {
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final handleSize = 60.0;
        final travelDistance = maxWidth - handleSize;

        return Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'SLIDE TO DISMISS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Positioned(
                left: _offset,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _offset += details.delta.dx;
                      if (_offset < 0) _offset = 0;
                      if (_offset > travelDistance) _offset = travelDistance;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    // Trigger dismissal if dragged past 80%
                    if (_offset > travelDistance * 0.8) {
                      setState(() => _offset = travelDistance);
                      widget.onDismissed();
                    } else {
                      setState(() => _offset = 0);
                    }
                  },
                  child: Container(
                    width: handleSize,
                    height: handleSize,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).colorScheme.primary, blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
