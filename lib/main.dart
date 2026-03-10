import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fitness_app/core/localization/app_language.dart';
import 'package:fitness_app/core/localization/app_translations.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final savedLocale = await AppLanguage.loadSavedLocale();
  runApp(FunFitApp(savedThemeMode: savedThemeMode, savedLocale: savedLocale));
}

class FunFitApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  final Locale savedLocale;

  const FunFitApp({super.key, this.savedThemeMode, required this.savedLocale});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3EBE),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      dark: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3EBE),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ).copyWith(scaffoldBackgroundColor: const Color(0xFF121212)),
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
        locale: savedLocale,
        fallbackLocale: const Locale(AppLanguage.englishCode),
        supportedLocales: AppLanguage.supportedLocales,
        translations: AppTranslations(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
