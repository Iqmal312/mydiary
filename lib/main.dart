import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'main_navigation.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const MyDiaryApp());
}

Future<void> initializeDatabase() async {
  // For mobile platforms (Android/iOS)
  try {
    await Sqflite.devSetDebugModeOn(true); // Optional debug mode
  } catch (e) {
    // If on desktop/web, initialize FFI version
    
  }
}


Future<void> _initializeFFI() async {
  // Only needed for desktop platforms
  // import 'package:sqflite_common_ffi/sqflite_ffi.dart';
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My Diary',
      home: MainNavigation(),
    );
  }
}