import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widgets/responsive_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool rememberPassword = false;
  final double socialRadius = 22;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ResponsivePage(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // TITLE
                Center(
                  child: Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: isDesktop ? 26 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _inputField(
                  "Email",
                  emailController,
                  keyboard: TextInputType.emailAddress,
                ),

                _inputField("Password", passwordController, isPassword: true),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (value) {
                        setState(() {
                          rememberPassword = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember password"),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.forgotPassword);
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
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
                      if (!_formKey.currentState!.validate()) return;

                      // Login successful logic (API later)
                      Get.offNamed(AppRoutes.home);
                    },

                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or With"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialIcon(
                      Icons.g_mobiledata,
                      Colors.red,
                      radius: socialRadius,
                    ),
                    _socialIcon(
                      Icons.facebook,
                      Colors.blue,
                      radius: socialRadius,
                    ),
                    _socialIcon(
                      Icons.apple,
                      Colors.purple,
                      radius: socialRadius,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you do not have account "),
                    GestureDetector(
                      onTap: () {
                        Get.offNamed(AppRoutes.createAccount);
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  INPUT FIELD WITH VALIDATION
  Widget _inputField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$hint is required";
          }
          if (hint == "Email" && !value.contains("@")) {
            return "Enter a valid email";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// social icon widget method
Widget _socialIcon(IconData icon, Color color, {double radius = 22}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: color.withOpacity(0.1),
    child: IconButton(
      icon: Icon(icon, color: color, size: radius),
      onPressed: () {},
    ),
  );
}
