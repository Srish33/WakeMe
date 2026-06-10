import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'core/services/settings_service.dart';
import 'core/theme/app_colors.dart';
import 'features/services/storage_service.dart';
import 'features/services/alarm_service.dart';
import 'features/providers/alarm_provider.dart';
import 'features/providers/mood_provider.dart';
import 'features/providers/analytics_provider.dart';
import 'features/screens/splash_screen.dart';
import 'navigation/main_navigation.dart';

void main() async {
  // Ensure the Flutter framework is ready for binary communication
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storageService = StorageService();
    await storageService.init();

    final settingsService = SettingsService();
    await settingsService.init();

    try {
      await AlarmService.init();
    } catch (e) {
      debugPrint('Alarm Service error: $e');
    }
    
    runApp(
      MultiProvider(
        providers: [
          Provider.value(value: storageService),
          ChangeNotifierProvider.value(value: settingsService),
          ChangeNotifierProvider(create: (_) => AlarmProvider(storageService)),
          ChangeNotifierProvider(create: (_) => MoodProvider(storageService)),
          ChangeNotifierProvider(create: (_) => AnalyticsProvider(storageService)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {


    runApp(MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
                const SizedBox(height: 24),
                const Text('Application Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'The application failed to start correctly. This is usually due to database conflicts or missing permissions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    'Error: $e',
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final appDir = await getApplicationDocumentsDirectory();
                      // Wipe Hive data
                      final dir = Directory(appDir.path);
                      if (await dir.exists()) {
                        final files = dir.listSync();
                        for (var file in files) {
                          try {
                            if (file.path.endsWith('.hive') || file.path.endsWith('.lock')) {
                              await file.delete();
                            }
                          } catch (_) {
                            // Ignore errors if file is already deleted or busy
                          }
                        }
                      }
                      
                      // Wipe alarm package data
                      try {
                        final alarmsJson = File('${appDir.path}/alarms.json');
                        final alarmsLock = File('${appDir.path}/alarms.lock');
                        if (await alarmsJson.exists()) await alarmsJson.delete();
                        if (await alarmsLock.exists()) await alarmsLock.delete();
                      } catch (_) {}
                    } catch (err) {
                      debugPrint('Resilience: Reset logic failed: $err');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('WIPE LOCAL DATA & RESTART'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, SettingsService settingsService, child) {
        final primaryColor = settingsService.primaryColor;
        
        return MaterialApp(
          title: 'WaKeMe',
          theme: AppColors.getTheme(primaryColor),
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
