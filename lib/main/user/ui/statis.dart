import 'package:flutter/material.dart';
import 'package:spm_app/main/super_admin/statistics_screen.dart';

class StatisUser extends StatelessWidget {
  const StatisUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistika")),
      body: StatisticsScreen(),
    );
  }
}
