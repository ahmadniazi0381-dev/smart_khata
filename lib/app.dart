import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_khata/core/router/app_router.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/l10n/app_localizations.dart';

/// Root application widget.
///
/// Wires together routing, theming, and localisation.
/// Dark / light mode follows the system setting by default.
class SmartKhataApp extends StatelessWidget {
  const SmartKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── Identity ─────────────────────────────────────────────────────────
      title: 'Smart Khata',

      // ── Routing ──────────────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Theming ──────────────────────────────────────────────────────────
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      // ── Localisation ─────────────────────────────────────────────────────
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // ── Misc ─────────────────────────────────────────────────────────────
      debugShowCheckedModeBanner: false,
    );
  }
}
