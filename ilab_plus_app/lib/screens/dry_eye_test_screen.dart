import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'test_result_screen.dart';

class DryEyeTestScreen extends StatefulWidget {
  const DryEyeTestScreen({super.key});

  @override
  State<DryEyeTestScreen> createState() => _DryEyeTestScreenState();
}

class _DryEyeTestScreenState extends State<DryEyeTestScreen> {
  int currentQuestion = 0;
  int totalScore = 0;
  String? selectedAnswer;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'How often do your eyes feel dry?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Do you experience a gritty or sandy feeling in your eyes?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'How often do your eyes feel irritated or burn?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Do your eyes become red during the day?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Do you experience blurred vision that improves with blinking?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Are your eyes sensitive to light?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Do your eyes feel tired or strained?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
    {
      'question': 'Do you experience excessive tearing or watery eyes?',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Rarely', 'score': 1},
        {'text': 'Sometimes', 'score': 2},
        {'text': 'Often', 'score': 3},
        {'text': 'Always', 'score': 4},
      ],
    },
  ];

  void _selectAnswer(String answer, int score) {
    setState(() {
      selectedAnswer = answer;
      totalScore += score;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    final maxScore = questions.length * 4;
    final percentage = (totalScore / maxScore * 100).round();

    String severity;
    String assessment;
    List<String> recommendations;

    if (totalScore <= 8) {
      severity = 'No Dry Eye';
      assessment = 'Your eyes appear healthy with minimal or no dry eye symptoms.';
      recommendations = [
        'Continue good eye care habits',
        'Take regular breaks from screens',
        'Stay hydrated throughout the day',
        'Consider protective eyewear outdoors',
      ];
    } else if (totalScore <= 16) {
      severity = 'Mild Dry Eye';
      assessment = 'You have mild dry eye symptoms that can be managed with simple care.';
      recommendations = [
        'Use artificial tears 2-3 times daily',
        'Follow the 20-20-20 rule for screen time',
        'Use a humidifier in dry environments',
        'Increase omega-3 fatty acid intake',
        'Avoid direct air flow to eyes',
      ];
    } else if (totalScore <= 24) {
      severity = 'Moderate Dry Eye';
      assessment = 'You have moderate dry eye symptoms that require attention.';
      recommendations = [
        'Consult an eye care professional',
        'Use preservative-free artificial tears regularly',
        'Consider warm compress therapy',
        'Reduce screen time and take frequent breaks',
        'Discuss prescription eye drops with your doctor',
      ];
    } else {
      severity = 'Severe Dry Eye';
      assessment = 'You have severe dry eye symptoms that need professional care.';
      recommendations = [
        'Schedule an appointment with an ophthalmologist',
        'Use prescribed medications as directed',
        'Consider punctal plugs or other treatments',
        'Avoid dry or windy environments',
        'Use protective eyewear and humidifiers',
        'Discuss underlying conditions with your doctor',
      ];
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultScreen(
          testName: 'Dry Eye Test',
          score: percentage,
          details: {
            'Severity': severity,
            'Total Score': '$totalScore/$maxScore',
            'Assessment': assessment,
          },
          recommendations: recommendations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

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
          'Dry Eye Test',
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
                '${currentQuestion + 1}/${questions.length}',
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
            value: (currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.peachColor),
            minHeight: 4,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Info banner
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
                            'Answer honestly based on your symptoms in the past week',
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

                  // Question
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 48,
                          color: AppTheme.peachColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question['question'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Answer options
                  ...List.generate(
                    question['options'].length,
                    (index) {
                      final option = question['options'][index];
                      final isSelected = selectedAnswer == option['text'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: selectedAnswer == null
                              ? () => _selectAnswer(option['text'], option['score'])
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.peachColor.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.peachColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.peachColor
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppTheme.peachColor
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option['text'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppTheme.peachColor
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
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
