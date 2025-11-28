import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/new_dashboard_screen.dart';

void main() {
  runApp(const ILabPlusApp());
}

class ILabPlusApp extends StatelessWidget {
  const ILabPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iLab+ Eye Health',
      debugShowCheckedModeBanner: false,

      // Apply Custom Theme
      theme: AppTheme.lightTheme,

      // Home Screen - Start with Auth Screen
      home: const AuthScreen(),

      // Accessibility Settings
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Ensure text scaling doesn't break layout
            textScaleFactor:
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}
