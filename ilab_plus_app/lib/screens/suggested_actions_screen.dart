import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SuggestedActionsScreen extends StatelessWidget {
  const SuggestedActionsScreen({super.key});

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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.iconBgGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lightbulb, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Suggested Actions',
              style: TextStyle(
                color: AppTheme.iconBgGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.pastelGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.iconBgGreen.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.iconBgGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.lightbulb, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Personalized Care Plan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.iconBgGreen,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your eye health assessment, we\'ve compiled a list of recommended actions to maintain and improve your vision health.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Cards
          _buildActionCard(
            context: context,
            backgroundColor: AppTheme.pastelPink,
            icon: Icons.remove_red_eye,
            iconColor: AppTheme.errorRed,
            title: 'Schedule Regular Eye Exams',
            description: 'Book a comprehensive eye exam with a professional optometrist',
            priority: 'High Priority',
            priorityColor: AppTheme.errorRed,
            timeframe: 'Within 1 month',
            timeframeColor: AppTheme.iconBgGreen,
            infoIcon: Icons.info_outline,
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            context: context,
            backgroundColor: AppTheme.pastelYellow,
            icon: Icons.wb_sunny_outlined,
            iconColor: AppTheme.warningOrange,
            title: 'Wear UV Protection',
            description: 'Use sunglasses with 100% UV protection when outdoors',
            priority: 'Medium Priority',
            priorityColor: AppTheme.peachColor,
            timeframe: 'Daily',
            timeframeColor: AppTheme.iconBgGreen,
            infoIcon: Icons.info_outline,
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            context: context,
            backgroundColor: AppTheme.pastelYellow,
            icon: Icons.self_improvement,
            iconColor: AppTheme.textSecondary,
            title: 'Practice Eye Exercises',
            description: 'Follow the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds',
            priority: 'Medium Priority',
            priorityColor: AppTheme.peachColor,
            timeframe: 'Daily',
            timeframeColor: AppTheme.iconBgGreen,
            checkmark: true,
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            context: context,
            backgroundColor: AppTheme.pastelGreen,
            icon: Icons.water_drop_outlined,
            iconColor: AppTheme.iconBgGreen,
            title: 'Stay Hydrated',
            description: 'Drink plenty of water to maintain eye moisture and prevent dryness',
            priority: 'Low Priority',
            priorityColor: AppTheme.peachColor,
            timeframe: 'Daily',
            timeframeColor: AppTheme.iconBgGreen,
            infoIcon: Icons.info_outline,
          ),
          const SizedBox(height: 16),

          _buildActionCard(
            context: context,
            backgroundColor: AppTheme.pastelPink,
            icon: Icons.computer,
            iconColor: AppTheme.errorRed,
            title: 'Reduce Screen Time',
            description: 'Limit prolonged screen exposure and take regular breaks',
            priority: 'High Priority',
            priorityColor: AppTheme.errorRed,
            timeframe: 'Daily',
            timeframeColor: AppTheme.iconBgGreen,
            warningIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String priority,
    required Color priorityColor,
    required String timeframe,
    required Color timeframeColor,
    IconData? infoIcon,
    bool checkmark = false,
    bool warningIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        if (infoIcon != null)
                          Icon(infoIcon, color: AppTheme.textSecondary, size: 20),
                        if (checkmark)
                          Icon(Icons.check_circle, color: AppTheme.successGreen, size: 24),
                        if (warningIcon)
                          Icon(Icons.access_time, color: AppTheme.warningOrange, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority and Timeframe Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info, color: priorityColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: timeframeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: timeframeColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      timeframe,
                      style: TextStyle(
                        color: timeframeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
