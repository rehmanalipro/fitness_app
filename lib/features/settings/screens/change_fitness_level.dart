import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/layout/main_layout.dart';

class ChangeFitnessLevelScreen extends StatefulWidget {
  const ChangeFitnessLevelScreen({super.key});

  @override
  State<ChangeFitnessLevelScreen> createState() =>
      _ChangeFitnessLevelScreenState();
}

class _ChangeFitnessLevelScreenState extends State<ChangeFitnessLevelScreen> {
  String selectedLevel = 'Beginner';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Change Fitness Level',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 5,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your current level',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _levelTile('Beginner'),
            const SizedBox(height: 10),
            _levelTile('Intermediate'),
            const SizedBox(height: 10),
            _levelTile('Advanced'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () => Get.back(),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelTile(String level) {
    final isSelected = selectedLevel == level;

    return InkWell(
      onTap: () => setState(() => selectedLevel = level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE0E0E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(level)),
            if (isSelected) const Icon(Icons.check, size: 18),
          ],
        ),
      ),
    );
  }
}
