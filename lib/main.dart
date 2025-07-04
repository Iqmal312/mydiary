import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaryKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  primaryColor: const Color.fromARGB(255, 27, 71, 117),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 27, 71, 117),
    foregroundColor: Colors.white,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromARGB(255, 27, 71, 117),
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white60,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 27, 71, 117),
    foregroundColor: Colors.white,
  ),
),

      initialRoute: '/auth', // or '/home' if already logged in
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return MainNavigation(userId: args);
        },
      },
    );
  }
}
