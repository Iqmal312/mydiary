import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'main_navigation.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSplashDone = false;

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSplashDone = true;
    });
  }

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
      home: _isSplashDone ? const AuthScreen() : const SplashScreen(),
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
