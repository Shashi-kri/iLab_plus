import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'test_result_screen.dart';

class VisualAcuityTestScreen extends StatefulWidget {
  const VisualAcuityTestScreen({super.key});

  @override
  State<VisualAcuityTestScreen> createState() => _VisualAcuityTestScreenState();
}

class _VisualAcuityTestScreenState extends State<VisualAcuityTestScreen> {
  int currentLevel = 0;
  int correctAnswers = 0;
  bool showingLetter = false;
  String? selectedAnswer;

  final List<Map<String, dynamic>> testLevels = [
    {
      'letter': 'E',
      'size': 120.0,
      'options': ['E', 'F', 'L', 'P'],
      'distance': '20/200',
    },
    {
      'letter': 'F',
      'size': 100.0,
      'options': ['F', 'E', 'P', 'T'],
      'distance': '20/100',
    },
    {
      'letter': 'P',
      'size': 80.0,
      'options': ['P', 'R', 'F', 'B'],
      'distance': '20/70',
    },
    {
      'letter': 'T',
      'size': 60.0,
      'options': ['T', 'L', 'F', 'E'],
      'distance': '20/50',
    },
    {
      'letter': 'O',
      'size': 50.0,
      'options': ['O', 'C', 'Q', 'D'],
      'distance': '20/40',
    },
    {
      'letter': 'Z',
      'size': 40.0,
      'options': ['Z', 'N', 'M', 'W'],
      'distance': '20/30',
    },
    {
      'letter': 'L',
      'size': 30.0,
      'options': ['L', 'I', 'T', 'F'],
      'distance': '20/20',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTest();
  }

  void _startTest() {
    setState(() {
      showingLetter = true;
      selectedAnswer = null;
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (answer == testLevels[currentLevel]['letter']) {
        correctAnswers++;
      }

      if (currentLevel < testLevels.length - 1) {
        setState(() {
          currentLevel++;
          selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final score = (correctAnswers / testLevels.length * 100).round();
    String vision = '20/200';

    if (correctAnswers >= 6) vision = '20/20';
    else if (correctAnswers >= 5) vision = '20/30';
    else if (correctAnswers >= 4) vision = '20/40';
    else if (correctAnswers >= 3) vision = '20/50';
    else if (correctAnswers >= 2) vision = '20/70';
    else if (correctAnswers >= 1) vision = '20/100';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultScreen(
          testName: 'Visual Acuity Test',
          score: score,
          details: {
            'Vision Level': vision,
            'Correct Answers': '$correctAnswers/${testLevels.length}',
            'Distance Tested': testLevels[currentLevel]['distance'],
          },
          recommendations: score >= 70
              ? [
                  'Your visual acuity is good',
                  'Continue regular eye checkups',
                  'Maintain healthy eye habits',
                ]
              : [
                  'Consider consulting an eye specialist',
                  'You may need corrective lenses',
                  'Schedule a comprehensive eye exam',
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTest = testLevels[currentLevel];

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
          'Visual Acuity Test',
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
                '${currentLevel + 1}/${testLevels.length}',
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
          // Progress bar
          LinearProgressIndicator(
            value: (currentLevel + 1) / testLevels.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.peachColor),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                // Instructions
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
                          'Distance: ${currentTest['distance']} - Stand 6 feet away and identify the letter',
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

                // Letter display
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    currentTest['letter'],
                    style: TextStyle(
                      fontSize: currentTest['size'],
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Which letter do you see?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                // Answer options
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
                    final isCorrect = option == currentTest['letter'];

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
                              fontSize: 32,
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
