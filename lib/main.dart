import 'package:flutter/material.dart';
import 'core/theme.dart';
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
      title: 'NeuroScale Pro',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const DashboardScreen(),
        '/icu': (ctx) => const IcuModeScreen(),
        '/analytics': (ctx) => const AnalyticsScreen(),
      },
    );
  }
}
