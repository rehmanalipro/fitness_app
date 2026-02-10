import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/core/constants/otp_purpose.dart';
import 'package:fitness_app/routes/app_routes.dart';
import 'package:fitness_app/core/widgets/app_back_appbar.dart';

class ChangePasswordFlowScreen extends StatefulWidget {
  const ChangePasswordFlowScreen({super.key});

  @override
  State<ChangePasswordFlowScreen> createState() =>
      _ChangePasswordFlowScreenState();
}

class _ChangePasswordFlowScreenState extends State<ChangePasswordFlowScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackAppBar(title: 'Change Password'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Enter your email address to receive\n'
              'a password reset link.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () => Get.toNamed(
                  AppRoutes.verification,
                  arguments: OtpPurpose.changePassword,
                ),
                child: const Text(
                  'Send Code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remember password? ',
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.login),
                  child: const Text('Back to Log In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



