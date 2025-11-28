import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/vision_data.dart';
import 'test_result_screen.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ColorBlindnessTestScreen extends StatefulWidget {
  const ColorBlindnessTestScreen({super.key});

  @override
  State<ColorBlindnessTestScreen> createState() => _ColorBlindnessTestScreenState();
}

class _ColorBlindnessTestScreenState extends State<ColorBlindnessTestScreen> {
  int currentPlate = 0;
  int correctAnswers = 0;
  String? selectedAnswer;

  final List<Map<String, dynamic>> ishiharaPlates = [
    {
      "image": "assets/images/color_blindness/plate_12.jpg",
      "number": "12",
      "correctAnswer": "12",
      "altAnswer": "12", // Everyone sees 12
      "type": "demonstration",
      'options': ['12', '13', '15', 'Nothing'],
      'description': 'Demonstration plate - Everyone should see 12.',
      'plateType': 'demonstration',
    },
    {
      "image": "assets/images/color_blindness/plate_45.jpg",
      "number": "45",
      "correctAnswer": "45",
      "altAnswer": "", // Vanishing plate: Colorblind see nothing
      "type": "vanishing",
      'options': ['45', '46', '48', 'Nothing'],
      'description': 'Normal vision sees 45. Color blind may see nothing.',
      'plateType': 'vanishing',
    },
    {
      "image": "assets/images/color_blindness/plate_5.jpg",
      "number": "5",
      "correctAnswer": "5",
      "altAnswer": "2", // Red-Green deficiency sees 2
      "type": "transformation",
      'options': ['5', '2', '8', 'Nothing'],
      'description': 'Normal vision sees 5. Red-Green deficiency may see 2.',
      'plateType': 'transformation',
    },
    {
      "image": "assets/images/color_blindness/plate_15.jpg",
      "number": "15",
      "correctAnswer": "15",
      "altAnswer": "17", // Red-Green deficiency sees 17
      "type": "transformation",
      'options': ['15', '17', '13', 'Nothing'],
      'description': 'Normal vision sees 15. Red-Green deficiency may see 17.',
      'plateType': 'transformation',
    },
    {
      "image": "assets/images/color_blindness/plate_29.jpg",
      "number": "29",
      "correctAnswer": "29",
      "altAnswer": "70", // Red-Green deficiency sees 70
      "type": "transformation",
      'options': ['29', '70', '79', 'Nothing'],
      'description': 'Normal vision sees 29. Red-Green deficiency may see 70.',
      'plateType': 'transformation',
    },
  ];

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (answer == ishiharaPlates[currentPlate]['number']) {
        correctAnswers++;
      }

      if (currentPlate < ishiharaPlates.length - 1) {
        setState(() {
          currentPlate++;
          selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final score = (correctAnswers / ishiharaPlates.length * 100).round();
    String colorVision = 'Normal';
    List<String> recommendations = [];

    if (correctAnswers >= 4) {
      colorVision = 'Normal Color Vision';
      recommendations = [
        'Your color vision appears normal',
        'Continue regular eye checkups',
        'No color vision deficiency detected',
      ];
    } else if (correctAnswers >= 2) {
      colorVision = 'Mild Color Deficiency';
      recommendations = [
        'You may have mild color vision deficiency',
        'Consult an eye specialist for detailed testing',
        'This is common and manageable',
      ];
    } else {
      colorVision = 'Possible Color Deficiency';
      recommendations = [
        'Significant color vision deficiency detected',
        'Schedule an appointment with an ophthalmologist',
        'Professional testing is recommended',
      ];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultScreen(
          testName: 'Color Blindness Test',
          score: score,
          details: {
            'Color Vision': colorVision,
            'Correct Answers': '$correctAnswers/${ishiharaPlates.length}',
            'Test Type': 'Ishihara Plates',
          },
          recommendations: recommendations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTest = ishiharaPlates[currentPlate];

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
          'Color Blindness Test',
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
                '${currentPlate + 1}/${ishiharaPlates.length}',
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
            value: (currentPlate + 1) / ishiharaPlates.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.peachColor),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
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
                            'Look at the circle and identify the number you see',
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

                  // Ishihara plate - using generated visual
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: currentTest['image'] != null
                          ? Image.asset(
                              currentTest['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to generated pattern if image not found
                                return CustomPaint(
                                  size: const Size(300, 300),
                                  painter: IshiharaPlatePatternPainter(
                                    number: currentTest['number'],
                                    numberColor: currentTest['fgColor'] ?? Color(0xFF8B5A3C),
                                    backgroundColor: currentTest['bgColor'] ?? Color(0xFFE8C5C0),
                                  ),
                                );
                              },
                            )
                          : CustomPaint(
                              size: const Size(300, 300),
                              painter: IshiharaPlatePatternPainter(
                                number: currentTest['number'],
                                numberColor: currentTest['fgColor'] ?? Color(0xFF8B5A3C),
                                backgroundColor: currentTest['bgColor'] ?? Color(0xFFE8C5C0),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    'What number do you see?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2,
                    ),
                    itemCount: currentTest['options'].length,
                    itemBuilder: (context, index) {
                      final option = currentTest['options'][index];
                      final isSelected = selectedAnswer == option;
                      final isCorrect = option == currentTest['number'];

                      Color borderColor = Colors.grey[300]!;
                      Color bgColor = Colors.white;

                      if (isSelected) {
                        borderColor = isCorrect ? Colors.green : Colors.red;
                        bgColor = isCorrect
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1);
                      }

                      return InkWell(
                        onTap: selectedAnswer == null ? () => _selectAnswer(option) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class IshiharaPlatePatternPainter extends CustomPainter {
  final String number;
  final Color numberColor;
  final Color backgroundColor;

  IshiharaPlatePatternPainter({
    required this.number,
    required this.numberColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final random = math.Random(number.hashCode);

    // Generate varied color shades
    final numberShades = _generateColorVariations(numberColor, 8);
    final bgShades = _generateColorVariations(backgroundColor, 8);

    // Draw background dots first (entire circle)
    for (int i = 0; i < 800; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final r = math.sqrt(random.nextDouble()) * (radius - 10);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      final dotSize = 3.0 + random.nextDouble() * 5.0;

      final paint = Paint()
        ..color = bgShades[random.nextInt(bgShades.length)]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }

    // Draw number dots using a simpler shape-based approach
    final numberPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 600; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final r = math.sqrt(random.nextDouble()) * (radius - 10);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      // Normalize coordinates to -1 to 1 range
      final normX = (x - center.dx) / (radius * 0.6);
      final normY = (y - center.dy) / (radius * 0.6);

      // Check if point is in number shape
      if (_isInNumberShape(normX, normY, number)) {
        final dotSize = 3.0 + random.nextDouble() * 5.0;
        numberPaint.color = numberShades[random.nextInt(numberShades.length)];
        canvas.drawCircle(Offset(x, y), dotSize, numberPaint);
      }
    }
  }

  bool _isInNumberShape(double x, double y, String num) {
    // For two-digit numbers, split the space
    if (num.length == 2) {
      final digit1 = num[0];
      final digit2 = num[1];

      if (x < -0.25) {
        // Left digit
        return _checkDigitShape(x + 0.5, y, digit1);
      } else if (x > 0.25) {
        // Right digit
        return _checkDigitShape(x - 0.5, y, digit2);
      }
      return false;
    } else {
      return _checkDigitShape(x, y, num[0]);
    }
  }

  bool _checkDigitShape(double x, double y, String digit) {
    // Simple geometric shapes for each digit
    switch (digit) {
      case '1':
        return x > -0.2 && x < 0.2 && y.abs() < 0.8;

      case '2':
        return (y < -0.4 && x > -0.3) ||
               (y > -0.4 && y < 0.0 && x > -0.1) ||
               (y > 0.0 && y < 0.4 && x < 0.1) ||
               (y > 0.4 && x.abs() < 0.3);

      case '3':
        return (y.abs() < 0.8 && x > -0.1) ||
               (y.abs() < 0.15 && x.abs() < 0.3) ||
               (y.abs() > 0.6 && x.abs() < 0.3);

      case '4':
        return (x < 0.0 && x > -0.3 && y < 0.2) ||
               (y > -0.2 && y < 0.2 && x.abs() < 0.3) ||
               (x > 0.1 && x < 0.3 && y.abs() < 0.8);

      case '5':
        return (y < -0.4 && x.abs() < 0.3) ||
               (y > -0.4 && y < 0.0 && x < 0.0) ||
               (y > 0.0 && y < 0.4 && x > -0.1) ||
               (y > 0.4 && x.abs() < 0.3);

      case '6':
        final dist = math.sqrt(x * x + (y - 0.3) * (y - 0.3));
        return (x < -0.1 && y < 0.1) ||
               (dist < 0.4 && dist > 0.15);

      case '7':
        return (y < -0.5 && x.abs() < 0.3) ||
               (x > -0.1 && y < 0.8 && y > -0.6 && (y - x).abs() < 0.4);

      case '8':
        final dist1 = math.sqrt(x * x + (y + 0.35) * (y + 0.35));
        final dist2 = math.sqrt(x * x + (y - 0.35) * (y - 0.35));
        return (dist1 < 0.35 && dist1 > 0.15) ||
               (dist2 < 0.35 && dist2 > 0.15);

      case '9':
        final dist = math.sqrt(x * x + (y + 0.3) * (y + 0.3));
        return (x > 0.1 && y > -0.1) ||
               (dist < 0.4 && dist > 0.15);

      case '0':
        final dist = math.sqrt(x * x + y * y);
        return dist < 0.45 && dist > 0.2;

      default:
        return false;
    }
  }

  List<Color> _generateColorVariations(Color baseColor, int count) {
    final variations = <Color>[];
    final hsl = HSLColor.fromColor(baseColor);

    for (int i = 0; i < count; i++) {
      final lightnessDelta = (i - count / 2) * 0.05;
      final saturationDelta = (i.isEven ? 0.05 : -0.05);

      variations.add(
        hsl.withLightness(
          (hsl.lightness + lightnessDelta).clamp(0.0, 1.0)
        ).withSaturation(
          (hsl.saturation + saturationDelta).clamp(0.0, 1.0)
        ).toColor(),
      );
    }

    return variations;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


