import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(FunFitApp(savedThemeMode: savedThemeMode));
}

class FunFitApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const FunFitApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1E3EBE),
        scaffoldBackgroundColor: Colors.white,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E3EBE),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => GetMaterialApp(
        debugShowCheckedModeBanner: false,

        //  Initial screen (Splash)
        initialRoute: AppRoutes.splash,

        //  Centralized routes
        getPages: AppRoutes.pages,
        unknownRoute: AppRoutes.unknownRoute,
        theme: theme,
        darkTheme: darkTheme,
      ),
    );
  }
}
