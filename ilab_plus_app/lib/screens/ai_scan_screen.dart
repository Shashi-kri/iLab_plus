import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AIScanScreen extends StatelessWidget {
  const AIScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Eye Scan',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
      body: Center(
        child: Text('AI Scan Screen - Coming Soon'),
      ),
    );
  }
}
