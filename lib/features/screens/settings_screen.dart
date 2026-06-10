import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakeme/core/services/settings_service.dart';
import 'sound_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SettingsService>(
        builder: (context, SettingsService settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildSectionHeader('APPEARANCE'),
              _buildColorThemeSelector(settings),
              
              const SizedBox(height: 32),
              _buildSectionHeader('ALARM DEFAULTS'),
              _buildSettingTile(
                context,
                title: 'Default Sound',
                subtitle: settings.defaultAlarmSound.split('/').last,
                icon: Icons.music_note_rounded,
                onTap: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (context) => SoundSelectionScreen(currentPath: settings.defaultAlarmSound)),
                  );
                  if (result != null) {
                    settings.setDefaultAlarmSound(result);
                  }
                },
              ),
              _buildSettingTile(
                context,
                title: 'Snooze Duration',
                subtitle: '${settings.defaultSnoozeDuration} minutes',
                icon: Icons.snooze_rounded,
                onTap: () => _showDurationPicker(context, settings),
              ),
              _buildSettingTile(
                context,
                title: 'Max Snoozes',
                subtitle: '${settings.defaultMaxSnoozes} times',
                icon: Icons.repeat_one_rounded,
                onTap: () => _showMaxSnoozePicker(context, settings),
              ),
              _buildSettingTile(
                context,
                title: 'Vibration',
                subtitle: settings.isVibrationEnabled ? 'Enabled' : 'Disabled',
                icon: Icons.vibration_rounded,
                trailing: Switch(
                  value: settings.isVibrationEnabled,
                  onChanged: (val) => settings.setVibration(val),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('PERMISSIONS'),
              _buildSettingTile(
                context,
                title: 'Notification Access',
                subtitle: 'Ensure alarms can trigger',
                icon: Icons.notifications_active_rounded,
                onTap: () async {
                  await openAppSettings();
                },
              ),
              _buildSettingTile(
                context,
                title: 'Battery Optimization',
                subtitle: 'Disable to ensure reliable alarms',
                icon: Icons.battery_saver_rounded,
                onTap: () async {
                   // This usually requires custom platform channel or opening settings
                   await openAppSettings();
                },
              ),

              const SizedBox(height: 32),
              _buildSectionHeader('CHALLENGE PREFERENCES'),
              _buildSettingTile(
                context,
                title: 'Adaptive Difficulty',
                subtitle: 'Difficulty adjusts based on performance',
                icon: Icons.trending_up_rounded,
              ),
              _buildSettingTile(
                context,
                title: 'Safety Alarm Delay',
                subtitle: '5 minutes of inactivity triggers alarm',
                icon: Icons.timer_rounded,
              ),


              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Text(
                      'WaKeMe',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.1),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MADE FOR EARLY RISERS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.1),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildColorThemeSelector(SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Primary Accent',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(settings.themeColors.length, (index) {
              final color = settings.themeColors[index];
              final isSelected = settings.themeColorIndex == index;
              return GestureDetector(
                onTap: () => settings.setThemeColor(index),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)
                    ] : [],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, color: Colors.white24) : null),
      ),
    );
  }

  void _showDurationPicker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Snooze Duration', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 5, 10, 15, 20, 30].map((d) => ListTile(
            title: Text('$d minutes', style: const TextStyle(color: Colors.white)),
            onTap: () {
              settings.setSnoozeDuration(d);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showMaxSnoozePicker(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Max Snoozes', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 5, 10].map((m) => ListTile(
            title: Text('$m times', style: const TextStyle(color: Colors.white)),
            onTap: () {
              settings.setMaxSnoozes(m);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
