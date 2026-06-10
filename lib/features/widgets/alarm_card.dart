import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import 'package:google_fonts/google_fonts.dart';

// Represents an individual alarm entry with dynamic styling based on its active state.
class AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final Function(bool) onToggle; // Callback for state changes
  final VoidCallback onDelete; // Callback for removal
  final VoidCallback onTap; // Callback to enter editing flow

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  void _showAlarmOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: Colors.white70),
              title: const Text('Edit Alarm', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              title: const Text('Delete Alarm', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    
    // Dynamic background colors to provide immediate visual feedback upon activation
    final Color enabledColor = isDark 
        ? const Color(0xFF2D2D3D) // Elevated technical surface
        : const Color(0xFFF5F3FF); // Light ceramic wash
    
    final Color disabledColor = isDark 
        ? const Color(0xFF1E1E2A) // Subdued technical surface
        : Colors.white; // Pure minimalist white
    
    final Color cardColor = alarm.isEnabled ? enabledColor : disabledColor;

    // Split time string into digits and period (AM/PM) for tiered typography
    final timeStr = alarm.timeFormatted;
    final timeParts = timeStr.split(' ');
    final digits = timeParts[0];
    final period = timeParts[1];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: alarm.isEnabled 
              ? colorScheme.primary.withValues(alpha: isDark ? 0.5 : 0.3) 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE2E8F0)),
          width: alarm.isEnabled ? 2 : 1,
        ),
        boxShadow: alarm.isEnabled ? [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showAlarmOptions(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Repeat Days and Primary Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.repeat_rounded, 
                              size: 14, 
                              color: alarm.isEnabled ? colorScheme.primary : (isDark ? Colors.blueGrey : const Color(0xFF64748B))
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                alarm.repeatDays.isEmpty 
                                    ? 'ONCE' 
                                    : alarm.repeatDays.map((d) => d.substring(0, 3)).join(', ').toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: alarm.isEnabled ? colorScheme.primary : (isDark ? Colors.white38 : Colors.black38),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: alarm.isEnabled,
                        onChanged: onToggle,
                        activeColor: colorScheme.primary,
                        applyCupertinoTheme: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  // Middle Section: Large formatted time display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        digits,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          color: alarm.isEnabled 
                              ? (isDark ? Colors.white : const Color(0xFF0F172A)) 
                              : (isDark ? Colors.white24 : Colors.black26),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        period,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: alarm.isEnabled 
                              ? (isDark ? Colors.white70 : const Color(0xFF64748B)) 
                              : (isDark ? Colors.white10 : Colors.black12),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Section: Custom alarm label tag
                  if (alarm.label != null && alarm.label!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: alarm.isEnabled 
                            ? colorScheme.primary.withValues(alpha: 0.1) 
                            : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        alarm.label!.toUpperCase(),
                        style: TextStyle(
                          color: alarm.isEnabled 
                              ? (isDark ? Colors.white : colorScheme.primary) 
                              : (isDark ? Colors.white24 : Colors.black26),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
