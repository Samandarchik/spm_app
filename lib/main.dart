import 'package:flutter/material.dart';
import 'package:spm_app/main/user/ui/splash_screen.dart';

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
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Color(0xfffdc109),
        appBarTheme: AppBarThemeData(backgroundColor: Color(0xfffdc109)),
      ),
      home: const SplashScreen(),
    );
  }
}
