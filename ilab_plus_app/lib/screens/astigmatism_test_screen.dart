import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'test_result_screen.dart';
import 'dart:math' as math;

class AstigmatismTestScreen extends StatefulWidget {
  const AstigmatismTestScreen({super.key});

  @override
  State<AstigmatismTestScreen> createState() => _AstigmatismTestScreenState();
}

class _AstigmatismTestScreenState extends State<AstigmatismTestScreen> {
  int currentTest = 0;
  final List<String?> answers = [null, null, null];

  final List<Map<String, dynamic>> tests = [
    {
      'title': 'Radial Lines Test',
      'instruction': 'Do all the lines appear equally dark and sharp?',
      'type': 'radial',
    },
    {
      'title': 'Clock Dial Test',
      'instruction': 'Are all numbers equally clear and dark?',
      'type': 'clock',
    },
    {
      'title': 'Cross Target Test',
      'instruction': 'Do all four quadrants look the same?',
      'type': 'cross',
    },
  ];

  void _submitAnswer(String answer) {
    setState(() {
      answers[currentTest] = answer;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentTest < tests.length - 1) {
        setState(() {
          currentTest++;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final yesCount = answers.where((a) => a == 'yes').length;
    final score = (yesCount / tests.length * 100).round();

    String astigmatismLevel;
    List<String> recommendations;

    if (yesCount == 3) {
      astigmatismLevel = 'No Astigmatism Detected';
      recommendations = [
        'Your test results look normal',
        'No signs of astigmatism detected',
        'Continue regular eye checkups',
      ];
    } else if (yesCount == 2) {
      astigmatismLevel = 'Mild Astigmatism Possible';
      recommendations = [
        'You may have mild astigmatism',
        'Consider getting a professional eye exam',
        'Corrective lenses may improve clarity',
      ];
    } else {
      astigmatismLevel = 'Astigmatism Likely';
      recommendations = [
        'Results suggest possible astigmatism',
        'Schedule an appointment with an eye doctor',
        'Professional testing is strongly recommended',
      ];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultScreen(
          testName: 'Astigmatism Test',
          score: score,
          details: {
            'Assessment': astigmatismLevel,
            'Tests Passed': '$yesCount/${tests.length}',
            'Test Type': 'Radial & Clock Dial',
          },
          recommendations: recommendations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = tests[currentTest];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Astigmatism Test',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${currentTest + 1}/${tests.length}',
                style: TextStyle(
                  color: AppTheme.peachColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentTest + 1) / tests.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.peachColor),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    test['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.peachColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.peachColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cover one eye and look at the pattern. Then switch eyes.',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Test pattern
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: CustomPaint(
                      painter: AstigmatismPainter(type: test['type']),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    test['instruction'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: answers[currentTest] == null
                              ? () => _submitAnswer('yes')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: answers[currentTest] == 'yes'
                                ? Colors.green
                                : Colors.white,
                            foregroundColor: answers[currentTest] == 'yes'
                                ? Colors.white
                                : AppTheme.peachColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: answers[currentTest] == 'yes'
                                    ? Colors.green
                                    : AppTheme.peachColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: answers[currentTest] == null
                              ? () => _submitAnswer('no')
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: answers[currentTest] == 'no'
                                ? Colors.red
                                : Colors.white,
                            foregroundColor: answers[currentTest] == 'no'
                                ? Colors.white
                                : AppTheme.peachColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: answers[currentTest] == 'no'
                                    ? Colors.red
                                    : AppTheme.peachColor,
                                width: 2,
                              ),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class AstigmatismPainter extends CustomPainter {
  final String type;

  AstigmatismPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (type == 'radial') {
      // Draw radial lines
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * math.pi / 180;
        final startX = center.dx + 30 * math.cos(angle);
        final startY = center.dy + 30 * math.sin(angle);
        final endX = center.dx + 120 * math.cos(angle);
        final endY = center.dy + 120 * math.sin(angle);
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    } else if (type == 'clock') {
      // Draw clock dial
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      for (int i = 1; i <= 12; i++) {
        final angle = (i * 30 - 90) * math.pi / 180;
        final x = center.dx + 100 * math.cos(angle);
        final y = center.dy + 100 * math.sin(angle);

        textPainter.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }

      // Draw center circle
      canvas.drawCircle(center, 5, Paint()..style = PaintingStyle.fill);
    } else if (type == 'cross') {
      // Draw cross target
      canvas.drawLine(
        Offset(center.dx - 100, center.dy),
        Offset(center.dx + 100, center.dy),
        paint..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - 100),
        Offset(center.dx, center.dy + 100),
        paint,
      );

      // Draw circles
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(center, i * 30.0, paint..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
