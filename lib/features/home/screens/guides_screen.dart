import 'package:flutter/material.dart';
import 'package:fitness_app/layout/main_layout.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Guides',
      showAppBar: true,
      currentIndex: 4,
      body: Center(
        child: Text(
          'Guides',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
