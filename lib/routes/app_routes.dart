import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/splash_screen.dart';
import '../screens/create_account_screen.dart';
import '../screens/login_screen.dart';
import '../screens/forgot_password_screen.dart';

import '../screens/verification_screen.dart';
import '../screens/success_screen.dart';

import '../screens/onboarding/onboarding_start_screen.dart';
import '../screens/onboarding/gender_screen.dart';
import '../screens/onboarding/goal_screen.dart';
import '../screens/onboarding/fitness_level_screen.dart';
import '../screens/onboarding/age_screen.dart';
import '../screens/onboarding/height_screen.dart';
import '../screens/onboarding/weight_screen.dart';
import '../models/home/home_screen.dart';
import '../screens/placeholder_screen.dart';

import '../models/otp_purpose.dart';
import '../models/success_purpose.dart';

class AppRoutes {
  // base routes
  static const String splash = '/';
  static const String createAccount = '/create-account';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // flow based routes
  static const String verification = '/verification';
  static const String success = '/success';

  // onboarding routes
  static const String onboardingReady = '/onboarding-ready';
  static const String gender = '/gender';
  static const String goal = '/goal';
  static const String fitnessLevel = '/fitness-level';
  static const String age = '/age';
  static const String height = '/height';
  static const String weight = '/weight';
  static const String home = '/home';
  static const String foodLog = '/food-log';
  static const String challenges = '/challenges';
  static const String leaderboard = '/leaderboard';
  static const String guides = '/guides';
  static const String settings = '/settings';
  static const String addAction = '/add';

  // GetX pages
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: createAccount, page: () => const CreateAccountScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: onboardingReady, page: () => const AreYouReadyScreen()),
    GetPage(name: gender, page: () => const GenderScreen()),
    GetPage(name: goal, page: () => const GoalScreen()),
    GetPage(name: fitnessLevel, page: () => const FitnessLevelScreen()),
    GetPage(name: age, page: () => const AgeScreen()),
    GetPage(name: height, page: () => const HeightScreen()),
    GetPage(name: weight, page: () => const WeightScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(
      name: foodLog,
      page: () => const PlaceholderScreen(title: "Food Log"),
    ),
    GetPage(
      name: challenges,
      page: () => const PlaceholderScreen(title: "Challenges"),
    ),
    GetPage(
      name: leaderboard,
      page: () => const PlaceholderScreen(title: "Leaderboard"),
    ),
    GetPage(
      name: guides,
      page: () => const PlaceholderScreen(title: "Guides"),
    ),
    GetPage(
      name: settings,
      page: () => const PlaceholderScreen(title: "Settings"),
    ),
    GetPage(
      name: addAction,
      page: () => const PlaceholderScreen(title: "Add"),
    ),
    GetPage(
      name: verification,
      page: () {
        final purpose = Get.arguments as OtpPurpose;
        return VerificationScreen(purpose: purpose);
      },
    ),
    GetPage(
      name: success,
      page: () {
        final purpose = Get.arguments as SuccessPurpose;
        return SuccessScreen(purpose: purpose);
      },
    ),
  ];

  static final GetPage<dynamic> unknownRoute = GetPage(
    name: '/not-found',
    page: () => const Scaffold(body: Center(child: Text('Route not found'))),
  );
}
