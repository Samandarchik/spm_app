import 'package:flutter/material.dart';
import 'package:spm_app/main/super_admin/categories_screen.dart';
import 'package:spm_app/register.dart';
import 'package:spm_app/main/service/storage_service.dart';
import 'package:spm_app/main/user/ui/categories_screen.dart';

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await StorageService.getToken();
    final user = await StorageService.getUser();

    if (!mounted) return;
    if (token != null && user != null && user['role'] == 'super_admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreenAdmin()),
      );
    } else if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterUi()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book, size: 100, color: Color(0xff130857)),
            SizedBox(height: 20),
            Text(
              'Quiz Mobile App',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xff130857),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
