import 'package:flutter/material.dart';
import 'diary_list.dart';
import 'calendar_view.dart';
import 'settings_screen.dart';
import 'notification_service.dart'; 


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiaryListScreen(),
    const CalendarView(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _scheduleDailyNotification(); // Schedule notification
  }

  void _scheduleDailyNotification() async {
    await NotificationService().scheduleDailyNotification(
      id: 1,
      title: 'How are you feeling today?',
      body: 'Don’t forget to log your mood in your diary! 😊',
      hour: 20, // 8 PM
      minute: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Diary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

