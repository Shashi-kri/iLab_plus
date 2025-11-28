import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dry_eye_test_screen.dart';
import 'color_blindness_test_screen.dart';
import 'astigmatism_test_screen.dart';

class TestSuiteScreen extends StatelessWidget {
  const TestSuiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.science_outlined, color: AppTheme.peachColor, size: 24),
            const SizedBox(width: 12),
            Text(
              'Test Suite',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Available Tests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          _buildTestCard(
            context: context,
            icon: Icons.water_drop_outlined,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: AppTheme.peachColor,
            title: 'Dry Eye Test',
            description: 'Assess symptoms of dry eye syndrome and eye strain',
            duration: '3 min',
            enabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DryEyeTestScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _buildTestCard(
            context: context,
            icon: Icons.palette_outlined,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: AppTheme.peachColor,
            title: 'Color Blindness Test',
            description: 'Screen for color vision deficiencies',
            duration: '3 min',
            enabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ColorBlindnessTestScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _buildTestCard(
            context: context,
            icon: Icons.center_focus_weak,
            iconBgColor: Color(0xFFE3F2FD),
            iconColor: AppTheme.peachColor,
            title: 'Astigmatism Test',
            description: 'Check for irregular curvature of the cornea',
            duration: '4 min',
            enabled: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AstigmatismTestScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _buildTestCard(
            context: context,
            icon: Icons.wb_sunny_outlined,
            iconBgColor: Color(0xFFF5F5F5),
            iconColor: Colors.grey[400]!,
            title: 'Light Sensitivity Test',
            description: 'Evaluate sensitivity to different light levels',
            duration: '2 min',
            enabled: false,
            comingSoon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required String duration,
    bool enabled = true,
    bool comingSoon = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: enabled ? AppTheme.textPrimary : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    if (comingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.peachColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: TextStyle(
                            color: AppTheme.peachColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled ? AppTheme.textSecondary : Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
