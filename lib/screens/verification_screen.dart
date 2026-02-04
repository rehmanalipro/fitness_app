import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/otp_purpose.dart';
import '../models/success_purpose.dart';
import '../routes/app_routes.dart';
import '../widgets/responsive_page.dart';

// Verification screen for OTP (used for signup and forgot password)

class VerificationScreen extends StatefulWidget {
  final OtpPurpose purpose;

  const VerificationScreen({super.key, required this.purpose});

  // Title based on OTP purpose
  String get title {
    switch (purpose) {
      case OtpPurpose.signup:
        return "Verify Your Account";
      case OtpPurpose.login:
        return "Login Verification";
      case OtpPurpose.forgotPassword:
        return "Reset Password";
    }
  }

  // Description based on OTP purpose
  String get description {
    switch (purpose) {
      case OtpPurpose.signup:
        return "Enter the code sent to your email to complete signup";
      case OtpPurpose.login:
        return "Enter the code sent to login securely";
      case OtpPurpose.forgotPassword:
        return "Enter the code to reset your password";
    }
  }

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // Controllers for OTP fields
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  // Focus nodes for auto cursor movement
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

  // Handle navigation after OTP verification
  void _handleContinue() {
    if (widget.purpose == OtpPurpose.signup) {
      Get.offNamed(AppRoutes.success, arguments: SuccessPurpose.registration);
    } else if (widget.purpose == OtpPurpose.forgotPassword) {
      Get.offNamed(
        AppRoutes.success,
        arguments: SuccessPurpose.passwordUpdated,
      );
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              // OTP input boxes and keyboard is integer
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center, // ⭐ IMPORTANT
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
              ),

              const SizedBox(height: 24),

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
