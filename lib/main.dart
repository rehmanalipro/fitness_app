import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const FunFitApp());
}

class FunFitApp extends StatelessWidget {
  const FunFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      //  Initial screen (Splash)
      initialRoute: AppRoutes.splash,

      //  Centralized static routes
      routes: AppRoutes.routes,

      //  For dynamic / future routes
      onGenerateRoute: AppRoutes.onGenerateRoute,

      // App theme
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3EBE),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
