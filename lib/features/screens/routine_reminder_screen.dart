import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import 'routine_timer_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

// First screen shown after an alarm is dismissed. 
// Prompts the user to start their routine or request a delay.
class RoutineReminderScreen extends StatefulWidget {
  final AlarmModel alarm;

  const RoutineReminderScreen({super.key, required this.alarm});

  @override
  State<RoutineReminderScreen> createState() => _RoutineReminderScreenState();
}

class _RoutineReminderScreenState extends State<RoutineReminderScreen> {
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _startSafetyTimer();
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  void _startSafetyTimer() {
    // If no response within 5 minutes, re-trigger the alarm
    _safetyTimer = Timer(const Duration(minutes: 5), () {
      AlarmService.triggerSafetyAlarm(widget.alarm);
    });
  }

  void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF12121A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Visual sun icon with a "pop-out" entry animation
                const Icon(Icons.wb_sunny_rounded, size: 80, color: Color(0xFFFACC15))
                    .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),
                Text(
                  'Ready to start your morning routine?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 48),
                
                // Triggers the countdown timer based on alarm routine tasks
                _buildActionButton(
                  context: context,
                  label: 'START ROUTINE',
                  icon: Icons.play_arrow_rounded,
                  color: const Color(0xFF8B5CF6),
                  onPressed: () {
                    _cancelSafetyTimer();
                    AlarmService.stopSessionAlarms(widget.alarm.id.hashCode);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RoutineTimerScreen(alarm: widget.alarm)),
                    );
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 16),
                
                // Allows user to postpone their routine (Snooze equivalent for routine)
                _buildActionButton(
                  context: context,
                  label: 'NEED MORE TIME',
                  icon: Icons.more_time_rounded,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  textColor: isDark ? Colors.white : Colors.black,
                  onPressed: () => _showMoreTimeOptions(context),
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable component for the large action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // Displays postpone options (5m, 10m, etc.) in a bottom sheet
  void _showMoreTimeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How much more time?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [5, 10, 15, 20, 30].map((mins) => _TimeOptionChip(
                label: '+$mins min',
                onTap: () {
                  _cancelSafetyTimer();
                  // Currently dismisses UI; would eventually schedule a reminder notification.
                  Navigator.pop(context);
                  Navigator.pop(context); 
                },
              )).toList(),
            ),
            const SizedBox(height: 16),
            _TimeOptionChip(
              label: 'Custom',
              onTap: () {
                 _cancelSafetyTimer();
                 Navigator.pop(context);
                 Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Minimalist chip for time selection
class _TimeOptionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeOptionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
