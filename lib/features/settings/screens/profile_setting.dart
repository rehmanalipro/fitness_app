import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/core/widgets/app_back_appbar.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  late final HomeProfileController _profileController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<HomeProfileController>()
        ? Get.find<HomeProfileController>()
        : Get.put(HomeProfileController(), permanent: true);
    _nameController = TextEditingController(
      text: _profileController.displayName.value,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    _profileController.setDisplayName(_nameController.text);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackAppBar(title: 'Profile Settings'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Obx(
                () => CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileController.avatarProvider,
                  backgroundColor: const Color(0xFFEAEAEA),
                  child: _profileController.avatarProvider == null
                      ? const Icon(
                          Icons.person,
                          size: 32,
                          color: Colors.black54,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Display Name',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: _saveProfile,
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
}
//