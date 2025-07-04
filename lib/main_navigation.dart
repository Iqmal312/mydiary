import 'package:flutter/material.dart';
import 'calendar_view.dart';
import 'diary_list.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final int userId;

  const MainNavigation({Key? key, required this.userId}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DiaryListScreen(userId: widget.userId),
      CalendarView(userId: widget.userId),
      SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
  backgroundColor: const Color.fromARGB(255, 27, 71, 117), // Dark blue
  selectedItemColor: Colors.white, // Active icon color
  unselectedItemColor: Colors.white60, // Inactive icon color
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
),
    );
  }
}
