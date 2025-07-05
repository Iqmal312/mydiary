import 'package:flutter/material.dart';
import 'main_navigation.dart'; // or wherever your main screen is

class IntroScreen extends StatelessWidget {
  final int userId;

  const IntroScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainNavigation(userId: userId)),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1B4775),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120),
            const SizedBox(height: 20),
            const Text(
              "Welcome to DiaryKu",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
