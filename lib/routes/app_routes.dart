import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/create_account_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';

import '../features/auth/screens/verification_screen.dart';
import '../features/auth/screens/success_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/change_password_flow_screen.dart';
import '../features/settings/screens/profile_setting.dart';
import '../features/settings/screens/subscription.dart';
import '../features/settings/screens/change_fitness_level.dart';
import '../features/settings/help.dart';
import '../features/settings/screens/language_prefrences.dart';
import '../features/settings/screens/change_theme.dart';

import '../features/auth/screens/onboarding/onboarding_start_screen.dart';
import '../features/auth/screens/onboarding/gender_screen.dart';
import '../features/auth/screens/onboarding/goal_screen.dart';
import '../features/auth/screens/onboarding/fitness_level_screen.dart';
import '../features/auth/screens/onboarding/age_screen.dart';
import '../features/auth/screens/onboarding/height_screen.dart';
import '../features/auth/screens/onboarding/weight_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/food_log_screen.dart';
import '../features/home/screens/challenges_screen.dart';
import '../features/home/screens/leaderboard_screen.dart';
import '../features/home/screens/guides_screen.dart';
import 'package:fitness_app/core/widgets/placeholder_screen.dart';

import 'package:fitness_app/core/constants/otp_purpose.dart';
import 'package:fitness_app/core/constants/success_purpose.dart';

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
  static const String profileSettings = '/profile-settings';
  static const String subscription = '/subscription';
  static const String changeFitnessLevel = '/change-fitness-level';
  static const String help = '/help';
  static const String languagePreferences = '/language-preferences';
  static const String changeTheme = '/change-theme';
  static const String changePassword = '/change-password';
  static const String addAction = '/add';
  static const String notifications = '/notifications';

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
    GetPage(name: foodLog, page: () => const FoodLogScreen()),
    GetPage(name: challenges, page: () => const ChallengesScreen()),
    GetPage(name: leaderboard, page: () => const LeaderboardScreen()),
    GetPage(name: guides, page: () => const GuidesScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: profileSettings, page: () => const ProfileSettingScreen()),
    GetPage(name: subscription, page: () => const SubscriptionScreen()),
    GetPage(
      name: changeFitnessLevel,
      page: () => const ChangeFitnessLevelScreen(),
    ),
    GetPage(name: help, page: () => const HelpScreen()),
    GetPage(
      name: languagePreferences,
      page: () => const LanguagePreferencesScreen(),
    ),
    GetPage(name: changeTheme, page: () => const ChangeThemeScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordFlowScreen()),
    GetPage(
      name: addAction,
      page: () => const PlaceholderScreen(title: "Add"),
    ),
    GetPage(
      name: notifications,
      page: () => const PlaceholderScreen(title: "Notifications"),
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
