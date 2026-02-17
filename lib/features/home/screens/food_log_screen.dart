import 'package:flutter/material.dart';
import 'package:fitness_app/layout/main_layout.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Food Log',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 1,
      body: Center(
        child: Text(
          'Food Log',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
