import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/routes/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      showAppBar: true,
      currentIndex: 5,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingsActionTile(
                label: 'Change Password',
                onTap: () => Get.toNamed(AppRoutes.changePassword),
              ),
              const SizedBox(height: 12),
              _SettingsActionTile(
                label: 'Logout',
                onTap: () => Get.offAllNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

