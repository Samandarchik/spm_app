import 'package:flutter/material.dart';
import 'package:spm_app/ui/splash_screen.dart';

void main() {
  runApp(const QuizApp());
}

// Main App
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.yellow, fontFamily: 'Arial'),
      home: const SplashScreen(),
    );
  }
}
