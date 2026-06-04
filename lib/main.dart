import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/theme_service.dart';
import 'features/services/storage_service.dart';
import 'features/services/notification_service.dart';
import 'features/providers/alarm_provider.dart';
import 'features/providers/mood_provider.dart';
import 'navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storageService = StorageService();
    await storageService.init();

    final themeService = ThemeService();
    await themeService.init();

    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();

    runApp(
      MultiProvider(
        providers: [
          Provider.value(value: storageService),
          Provider.value(value: notificationService),
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider(create: (_) => AlarmProvider(storageService, notificationService)),
          ChangeNotifierProvider(create: (_) => MoodProvider(storageService)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');

    // In case of error, still try to run the app with a basic error view or handle it
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Failed to initialize app', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Attempt to clear boxes if it's a data corruption issue
                  await Hive.deleteBoxFromDisk('alarms');
                  await Hive.deleteBoxFromDisk('mood_entries');
                  // Use a platform-specific way to restart the app or just ask user to reopen
                },
                child: const Text('Reset App Data'),
              ),
            ],
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
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'WaKeMe',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: const MainNavigation(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
