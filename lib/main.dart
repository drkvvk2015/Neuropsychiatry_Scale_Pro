import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard.dart';
import 'screens/icu_mode.dart';
import 'screens/analytics_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeuroScaleApp());
}

class NeuroScaleApp extends StatelessWidget {
  const NeuroScaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
      ],
      initialRoute: '/',
      routes: {
        '/': (ctx) => const DashboardScreen(),
        '/icu': (ctx) => const IcuModeScreen(),
        '/analytics': (ctx) => const AnalyticsScreen(),
      },
    );
  }
}
