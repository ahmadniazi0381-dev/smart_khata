import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_khata/core/router/app_router.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/features/setup/presentation/providers/setup_providers.dart';
import 'package:smart_khata/l10n/app_localizations.dart';

/// Root application widget.
///
/// Wires together routing, theming, and localisation.
/// Theme and locale are synced with [shopSettingsStreamProvider].
class SmartKhataApp extends ConsumerWidget {
  const SmartKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(shopSettingsStreamProvider);
    final settings = settingsAsync.valueOrNull;

    ThemeMode themeMode;
    switch (settings?.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    Locale? locale;
    if (settings?.language == 'ur') {
      locale = const Locale('ur');
    } else if (settings?.language == 'en') {
      locale = const Locale('en');
    }

    return MaterialApp.router(
      // ── Identity ─────────────────────────────────────────────────────────
      title: 'Smart Khata',

      // ── Routing ──────────────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Theming ──────────────────────────────────────────────────────────
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // ── Localisation ─────────────────────────────────────────────────────
      locale: locale,
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
