import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const FunFitApp());
}

class FunFitApp extends StatelessWidget {
  const FunFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      //  Initial screen (Splash)
      initialRoute: AppRoutes.splash,

      //  Centralized routes
      getPages: AppRoutes.pages,
      unknownRoute: AppRoutes.unknownRoute,

      // App theme
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3EBE),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
