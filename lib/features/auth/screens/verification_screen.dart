import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fitness_app/core/constants/otp_purpose.dart';
import 'package:fitness_app/core/constants/success_purpose.dart';
import 'package:fitness_app/routes/app_routes.dart';
import 'package:fitness_app/core/widgets/responsive_page.dart';

class VerificationScreen extends StatefulWidget {
  final OtpPurpose purpose;

  const VerificationScreen({super.key, required this.purpose});

  // 🔹 Dynamic title
  String get title {
    switch (purpose) {
      case OtpPurpose.signup:
        return "Verify Your Account";
      case OtpPurpose.login:
        return "Login Verification";
      case OtpPurpose.forgotPassword:
        return "Reset Password";
      case OtpPurpose.changePassword:
        return "Verification Code";
    }
  }

  // 🔹 Dynamic description
  String get description {
    switch (purpose) {
      case OtpPurpose.signup:
        return "Enter the code sent to your email to complete signup";
      case OtpPurpose.login:
        return "Enter the code sent to login securely";
      case OtpPurpose.forgotPassword:
        return "Enter the code to reset your password";
      case OtpPurpose.changePassword:
        return "We have sent the verification code to your email address";
    }
  }

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // 🔹 Centralized navigation logic
  void _handleContinue() {
    switch (widget.purpose) {
      case OtpPurpose.signup:
        Get.offNamed(AppRoutes.success, arguments: SuccessPurpose.registration);
        break;

      case OtpPurpose.forgotPassword:
      case OtpPurpose.changePassword:
        Get.offNamed(
          AppRoutes.success,
          arguments: SuccessPurpose.passwordUpdated,
        );
        break;

      case OtpPurpose.login:
        Get.offNamed(AppRoutes.login);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ResponsivePage(
          scroll: true,
          child: Column(
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Get.back(),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 🔹 Description
              Text(
                widget.description,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 🔹 OTP boxes
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index - 1]);
                        }
                      },
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // 🔹Continue button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _handleContinue,
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
