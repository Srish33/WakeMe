import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../features/screens/alarm_screen.dart';
import '../features/screens/mood_board_screen.dart';
import '../features/screens/reports_screen.dart';
import '../features/screens/settings_screen.dart';
import '../features/screens/alarm_ringing_screen.dart';
import 'dart:async';

// Root navigation controller that manages tab switching and global alarm events.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  StreamSubscription<AlarmSet>? ringSubscription;

  // List of primary app surfaces (Dashboard, Calendar, Analytics, Settings).
  final List<Widget> _screens = [
    const AlarmScreen(),
    const MoodBoardScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Globally monitor for alarm ringing events to ensure the interruption UI appears
    // regardless of the user's current app state.
    ringSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        _navigateToRingingScreen(alarmSet.alarms.first);
      }
    });
  }

  // Force navigate the user to the native-style ringing screen.
  void _navigateToRingingScreen(AlarmSettings settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmRingingScreen(alarmSettings: settings),
      ),
    );
  }

  // Switch between tabs.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    // Prevent memory leaks by closing the stream subscription.
    ringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps the state of each tab alive while it's hidden.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm_rounded),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood_rounded),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
