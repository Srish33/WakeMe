import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Theme Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(themeService.isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
                value: themeService.isDarkMode,
                onChanged: (value) {
                  themeService.setThemeMode(value);
                },
                secondary: Icon(
                  themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            title: Text('WaKeMe'),
            subtitle: Text('Version 2.0.0'),
            trailing: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}