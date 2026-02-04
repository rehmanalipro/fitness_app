import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/success_purpose.dart';
import '../routes/app_routes.dart';
import '../widgets/responsive_page.dart';

class SuccessScreen extends StatelessWidget {
  final SuccessPurpose purpose;

  const SuccessScreen({super.key, required this.purpose});

  // Title based on success type
  String get title {
    switch (purpose) {
      case SuccessPurpose.registration:
        return "Registration Successful!";
      case SuccessPurpose.passwordUpdated:
        return "Successfully";
    }
  }

  // Description based on success type
  String get description {
    switch (purpose) {
      case SuccessPurpose.registration:
        return "Your account is awaiting admin approval.\n"
            "You will receive a notification once your profile is activated.";
      case SuccessPurpose.passwordUpdated:
        return "Your password has been updated, please change your password "
            "regularly to avoid this happening";
    }
  }

  // Next route based on success type
  String get nextRoute {
    switch (purpose) {
      case SuccessPurpose.registration:
        return AppRoutes.onboardingReady;
      case SuccessPurpose.passwordUpdated:
        return AppRoutes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          scroll: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                // Success icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.offNamed(nextRoute);
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Extra option only for password update
                if (purpose == SuccessPurpose.passwordUpdated) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.offNamed(AppRoutes.login);
                    },
                    child: const Text(
                      "Back to Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
