import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../theme/app_theme.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  // 1. METHODS MOVED HERE (Class Level) -----------------------
  
  Future<void> _downloadReport(BuildContext context) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(
                'My Health Report\n\nCompleted Tests: 12\nAvg Health Score: 85%\nHealth Rating: 4.5'),
          ),
        ),
      );
      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_health_report.pdf');
      await file.writeAsBytes(bytes);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded to ${file.path}')),
        );
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
    }
  }

  Future<void> _shareReport(BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_health_report.pdf');
    if (await file.exists()) {
      await Share.shareXFiles([XFile(file.path)], text: 'My Health Report');
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please download the report first.')),
        );
      }
    }
  }

  // 2. BUILD METHOD -------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Reports', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        // Added actions so you can actually use the methods
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      // 3. BODY CORRECTLY CONNECTED ----------------------------
      body: Column(
        children: [
          // Stats Cards
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.assignment_turned_in,
                    value: '12',
                    label: 'Completed Tests',
                    color: AppTheme.successGreen,
                    bgColor: AppTheme.pastelGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.trending_up,
                    value: '85%',
                    label: 'Avg Health Score',
                    color: AppTheme.peachColor,
                    bgColor: AppTheme.pastelBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.star,
                    value: '4.5',
                    label: 'Health Rating',
                    color: AppTheme.warningOrange,
                    bgColor: AppTheme.pastelYellow,
                  ),
                ),
              ],
            ),
          ),

          // Timeline Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Health Timeline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),

                // Timeline Items
                _buildTimelineItem(
                  context,
                  date: 'Today',
                  time: '10:30 AM',
                  title: 'AI Eye Scan Completed',
                  description: 'No abnormalities detected. Vision health is excellent.',
                  score: 92,
                  color: AppTheme.successGreen,
                  icon: Icons.check_circle,
                  isFirst: true,
                ),
                _buildTimelineItem(
                  context,
                  date: 'Nov 18, 2025',
                  time: '3:45 PM',
                  title: 'Voice Vision Test',
                  description: 'Visual acuity remains stable. Continue eye exercises.',
                  score: 88,
                  color: AppTheme.peachColor,
                  icon: Icons.mic,
                ),
                _buildTimelineItem(
                  context,
                  date: 'Nov 15, 2025',
                  time: '11:20 AM',
                  title: 'Comprehensive Eye Check',
                  description: 'Minor eye strain detected. Recommended screen breaks.',
                  score: 82,
                  color: AppTheme.warningOrange,
                  icon: Icons.warning_amber_rounded,
                ),
                _buildTimelineItem(
                  context,
                  date: 'Nov 10, 2025',
                  time: '9:15 AM',
                  title: 'Color Blindness Test',
                  description: 'Normal color vision detected in all quadrants.',
                  score: 95,
                  color: AppTheme.successGreen,
                  icon: Icons.palette,
                ),
                _buildTimelineItem(
                  context,
                  date: 'Nov 5, 2025',
                  time: '2:00 PM',
                  title: 'Astigmatism Screening',
                  description: 'No signs of irregular cornea curvature detected.',
                  score: 90,
                  color: AppTheme.successGreen,
                  icon: Icons.blur_circular,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: AppTheme.peachColor,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Test', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 4. HELPER WIDGETS -------------------------------------------
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String date,
    required String time,
    required String title,
    required String description,
    required int score,
    required Color color,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: color, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$score',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      // View details
                    },
                    child: Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: AppTheme.peachColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.peachColor,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}