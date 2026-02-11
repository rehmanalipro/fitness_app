import 'package:flutter/material.dart';
import 'package:fitness_app/layout/main_layout.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Leaderboard',
      showAppBar: true,
      currentIndex: 3,
      body: Center(
        child: Text(
          'Leaderboard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
