import 'package:flutter/material.dart';
import '../screens/create_account_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/registration_success_screen.dart';

// Names
class AppRoutes {
  static const splash = '/';
  static const createAccount = '/create-account';
  static const String success = '/registration-success';

  // routes map
  static final routes = {
    splash: (_) => const SplashScreen(),
    createAccount: (_) => const CreateAccountScreen(),
    success: (context) => const RegistrationSuccessScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return null; // future screens
  }
}
