import 'package:fitness_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import '../routes/app_routes.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedCountry = "Select Country";
  String countryCode = "  ";
  bool agreeTerms = false;
  final double socialRadius = 22;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bool isDesktop = size.width > 600;
    final double contentWidth = isDesktop ? 420 : size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: contentWidth,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isDesktop ? 32 : size.height * 0.04,
              ),
              child: Form(
                key: _formKey, //  FORM ADDED
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Create Your Account",
                        style: TextStyle(
                          fontSize: isDesktop ? 26 : size.width * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _inputField("Full Name", nameController),

                    _inputField(
                      "Phone Number",
                      phoneController,
                      keyboard: TextInputType.phone,
                    ),

                    //  COUNTRY PICKER
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              selectedCountry = country.name;
                              countryCode = country.countryCode;
                            });
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CountryFlag.fromCountryCode(countryCode),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedCountry,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),

                    _inputField(
                      "Email",
                      emailController,
                      keyboard: TextInputType.emailAddress,
                    ),

                    _inputField(
                      "Password",
                      passwordController,
                      isPassword: true,
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: agreeTerms,
                          onChanged: (value) {
                            setState(() {
                              agreeTerms = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to the Terms & Conditions",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 16, 5, 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // VALIDATION LOGIC
                          if (!_formKey.currentState!.validate()) return;

                          if (selectedCountry == "Select Country") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a country"),
                              ),
                            );
                            return;
                          }

                          if (!agreeTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please accept Terms & Conditions",
                                ),
                              ),
                            );
                            return;
                          }

                          //  ALL GOOD → NEXT SCREEN
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.success,
                          );
                        },
                        child: const Text(
                          "Button",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        "Or With",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
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

                    const SizedBox(height: 28),
                    // LOGIN TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 16, 5, 5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //  INPUT WITH VALIDATION
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
        obscureText: isPassword,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$hint is required";
          }

          if (hint == "Email" && !value.contains("@")) {
            return "Enter a valid email";
          }

          if (hint == "Password" && value.length < 6) {
            return "Password must be at least 6 characters";
          }

          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

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
}
