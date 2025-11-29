import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_theme.dart';
import '../data/vision_data.dart';
import '../services/api_service.dart';
import 'result_summary_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VisionTestScreen extends StatefulWidget {
  const VisionTestScreen({super.key});

  @override
  State<VisionTestScreen> createState() => _VisionTestScreenState();
}

class _VisionTestScreenState extends State<VisionTestScreen>
    with TickerProviderStateMixin {
  bool _isListening = false;
  String _currentLetter = 'E';
  int _testProgress = 0;
  final int _totalTests = 5;

  // Speech recognition
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  String _lastRecognizedWords = '';

  // Test results tracking
  List<Map<String, dynamic>> _testResponses = [];
  int _correctAnswers = 0;
  bool _answerValidated = false;
  late AnimationController _waveAnimationController;
  late AnimationController _pulseAnimationController;

  // Use optotypes from VisionData
  late List<String> _testLetters;

  // Calibration for accurate sizing
  double _pixelsPerMm = 3.5; // Default calibration
  double _currentScale = 1.0; // Current Snellen scale (1.0 = 20/20)

  // Auto-advance timer
  Timer? _autoAdvanceTimer;
  final int _autoAdvanceSeconds = 8; // Time to show each letter

  // Fuzzy matching map for speech variations
  final Map<String, List<String>> _letterVariations = {
    'C': ['c', 'see', 'sea', 'si'],
    'D': ['d', 'dee', 'di'],
    'E': ['e', 'ee', 'i'],
    'F': ['f', 'ef', 'eff'],
    'L': ['l', 'el', 'ell'],
    'O': ['o', 'oh', 'owe', 'zero'],
    'P': ['p', 'pee', 'pi'],
    'T': ['t', 'tee', 'tea', 'ti'],
    'Z': ['z', 'zee', 'zed', 'zi'],
  };

  // Snellen chart data
  final List<Map<String, dynamic>> _chartRows = [
    {"letters": "E", "acuity": "20/200", "size": 80.0},
    {"letters": "F P", "acuity": "20/100", "size": 50.0},
    {"letters": "T O Z", "acuity": "20/70", "size": 40.0},
    {"letters": "L P E D", "acuity": "20/50", "size": 30.0},
    {"letters": "P E C F D", "acuity": "20/40", "size": 24.0},
    {"letters": "E D F C Z P", "acuity": "20/30", "size": 18.0},
    {"letters": "F E L O P Z D", "acuity": "20/20", "size": 14.0},
  ];

  int _currentRowIndex = -1; // -1 means test hasn't started
  bool _showFullChart = false; // Toggle between single letter and full chart

  @override
  void initState() {
    super.initState();

    // Initialize test letters from VisionData optotypes
    _testLetters = List.generate(
      _totalTests,
      (index) => VisionData.optotypes[
          (DateTime.now().millisecondsSinceEpoch + index) %
              VisionData.optotypes.length],
    );
    _currentLetter = _testLetters[0];

    // Initialize speech recognition
    _speech = stt.SpeechToText();
    _initSpeech();

    // Estimate pixels per mm based on screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final diagonal =
          sqrt(size.width * size.width + size.height * size.height);
      // Assume ~96 DPI as default, adjust based on actual screen
      _pixelsPerMm = diagonal / 254; // Rough estimate
      setState(() {});
    });

    // Wave animation for listening state
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Pulse animation for the letter
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          if (error.errorMsg == 'not-allowed') {
            _showFeedback(
                'Microphone permission denied. Please allow microphone access in your browser.');
          } else {
            _showFeedback('Speech error: ${error.errorMsg}');
          }
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
          if (status == 'notListening' && _isListening && !_answerValidated) {
            // Speech stopped but no answer validated - might have timed out
            print('Speech stopped without validation');
          }
        },
      );
      setState(() {});

      if (_speechAvailable) {
        print('✅ Speech recognition initialized successfully');
      }
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      _speechAvailable = false;
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _startListening() {
    if (_showFullChart) {
      _startChartTest();
    } else {
      _startSingleLetterTest();
    }
  }

  void _startSingleLetterTest() {
    setState(() {
      _isListening = true;
      _testProgress = 0;
      _currentLetter = _testLetters[0];
      _testResponses = [];
      _correctAnswers = 0;
      _answerValidated = false;
    });

    _waveAnimationController.repeat();
    _startVoiceRecognition();
  }

  void _startVoiceRecognition() async {
    setState(() {
      _answerValidated = false;
    });

    if (!_speechAvailable) {
      // Try to re-initialize speech (might prompt for permission)
      await _initSpeech();

      if (!_speechAvailable) {
        _showFeedback(
            'Speech recognition not available. Please allow microphone access in your browser settings.');
        _stopAutoAdvanceMode();

        // Show permission dialog
        _showPermissionDialog();
        return;
      }
    }

    try {
      bool isListening = await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastRecognizedWords = result.recognizedWords.toUpperCase();
          });

          print('📢 Speech result: "${result.recognizedWords}"');
          print('   Final: ${result.finalResult}, Confident: ${result.hasConfidenceRating}, Confidence: ${result.confidence}');

          // Validate on final result OR if we have text
          if (!_answerValidated && _lastRecognizedWords.isNotEmpty) {
            // Validate immediately if: final result, or we have at least one letter heard
            bool isFinal = result.finalResult == true;
            if (isFinal || _lastRecognizedWords.length >= 1) {
              print('✓ Validating answer now...');
              _validateAnswer(_lastRecognizedWords);
            }
          }
        },
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      if (!isListening) {
        print('Failed to start listening - permission might be denied');
        _showPermissionDialog();
        _stopAutoAdvanceMode();
        return;
      }

      // Auto-advance timer after 8 seconds (matches listen duration)
      _autoAdvanceTimer?.cancel();
      _autoAdvanceTimer = Timer(const Duration(seconds: 8), () {
        if (!_answerValidated) {
          print('⏰ Auto-advance timeout');
          // Record no answer if nothing spoken
          if (_lastRecognizedWords.isEmpty) {
            print('❌ No speech detected');
            _recordResponse('', false);
          } else {
            // Validate whatever we heard
            print('⚠️ Validating partial result: "$_lastRecognizedWords"');
            _validateAnswer(_lastRecognizedWords);
          }
        }
      });
    } catch (e) {
      print('Error starting voice recognition: $e');
      _showFeedback('Error: $e');
    }
  }

  void _validateAnswer(String spokenText) {
    if (_answerValidated) return; // Prevent duplicate validation

    _answerValidated = true;
    _autoAdvanceTimer?.cancel(); // Cancel auto-advance timer

    print('🎤 Validating: "$spokenText" vs "$_currentLetter"');

    // Check if answer is correct using fuzzy matching
    bool isCorrect = _fuzzyMatchLetter(spokenText, _currentLetter);

    _recordResponse(spokenText, isCorrect);

    if (isCorrect) {
      _correctAnswers++;
      print('✅ Correct! Total: $_correctAnswers/${_testProgress + 1}');
      _showFeedback('Correct! ✓');
    } else {
      print('❌ Wrong. Expected: $_currentLetter');
      _showFeedback('You said: "$spokenText" (Expected: $_currentLetter)');
    }

    // Move to next letter after short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_testProgress < _totalTests - 1) {
        _moveToNextLetter();
      } else {
        _completeTest();
      }
    });
  }

  /// Fuzzy matching to handle speech variations (e.g., "See" for "C")
  bool _fuzzyMatchLetter(String spokenText, String targetLetter) {
    final spoken = spokenText.trim().toLowerCase();
    final target = targetLetter.toUpperCase();

    // Direct match
    if (spoken == target.toLowerCase() ||
        spoken.startsWith(target.toLowerCase())) {
      return true;
    }

    // Check variations map
    if (_letterVariations.containsKey(target)) {
      for (var variation in _letterVariations[target]!) {
        if (spoken == variation || spoken.startsWith(variation)) {
          return true;
        }
      }
    }

    // Check if first character matches
    if (spoken.isNotEmpty && spoken[0] == target.toLowerCase()[0]) {
      return true;
    }

    return false;
  }

  void _recordResponse(String spokenText, bool isCorrect) {
    _testResponses.add({
      'letter_shown': _currentLetter,
      'user_response': spokenText,
      'is_correct': isCorrect,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _moveToNextLetter() async {
    await _speech.stop();

    setState(() {
      _testProgress++;
      _currentLetter = _testLetters[_testProgress];
      _lastRecognizedWords = '';
    });

    print(
        '📝 Moving to letter ${_testProgress + 1}/$_totalTests: $_currentLetter');
    _startVoiceRecognition();
  }

  void _completeTest() async {
    await _speech.stop();
    _stopAutoAdvanceMode();

    // Calculate accuracy
    double accuracy = _testResponses.isEmpty
        ? 0
        : (_correctAnswers / _testResponses.length) * 100;

    print(
        'Test completed: $_correctAnswers correct out of ${_testResponses.length}');
    print('Accuracy: ${accuracy.toStringAsFixed(1)}%');
    print('Responses: $_testResponses');

    // Submit to backend
    _submitTestResults();
  }

  void _submitTestResults() async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Submit to backend
      final result = await ApiService.submitVisionTest(
        testMode: 'single_letter',
        totalQuestions: _totalTests,
        correctAnswers: _correctAnswers,
        responses: _testResponses,
      );

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Navigate to results with backend data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultSummaryScreen(
            visionTestResult: result,
          ),
        ),
      );
    } catch (e) {
      print('Error submitting test results: $e');

      // Close loading dialog if still open
      if (!mounted) return;
      Navigator.pop(context);

      // Show error and navigate with local results
      _showFeedback('Backend unavailable. Showing local results.');

      // Calculate local results as fallback
      double accuracy = _testResponses.isEmpty
          ? 0
          : (_correctAnswers / _testResponses.length) * 100;
      int healthScore = accuracy.toInt();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultSummaryScreen(
            visionTestResult: VisionTestResult(
              success: true,
              healthScore: healthScore,
              visionStatus: accuracy >= 80 ? 'Good' : 'Fair',
              acuityLevel: accuracy >= 80 ? '20/20' : '20/40',
              statusColor: 'yellow',
              analysis: {
                'total_tests': _totalTests,
                'correct_responses': _correctAnswers,
                'accuracy_percentage': accuracy,
              },
              recommendations: [
                'Schedule a comprehensive eye examination',
                'Follow the 20-20-20 rule for screen use',
              ],
            ),
          ),
        ),
      );
    }
  }

  void _startChartTest() {
    setState(() {
      _isListening = true;
      _currentRowIndex = 0; // Start at the top (Big E)
    });

    _waveAnimationController.repeat();

    // The 5-second rule: Move to the next ROW automatically
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentRowIndex < _chartRows.length - 1) {
        setState(() {
          _currentRowIndex++;
        });
      } else {
        _stopAutoAdvanceMode();
        _showCompletionDialog();
      }
    });
  }

  void _stopAutoAdvanceMode() {
    _autoAdvanceTimer?.cancel();
    _waveAnimationController.stop();
    _speech.stop();
    setState(() {
      _isListening = false;
      _currentRowIndex = -1;
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic_off, color: AppTheme.errorRed),
            const SizedBox(width: 12),
            const Text('Microphone Access Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To use the Voice Vision Test, please allow microphone access:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
                '1. Click the microphone icon in your browser address bar'),
            const SizedBox(height: 8),
            const Text('2. Select "Allow" for microphone permission'),
            const SizedBox(height: 8),
            const Text('3. Reload the page if needed'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.pastelBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppTheme.peachColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chrome blocks microphone on http://. Use https:// or localhost.',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              // Try to re-initialize
              await _initSpeech();
              if (_speechAvailable) {
                _showFeedback(
                    'Microphone access granted! You can start the test now.');
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.peachColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Test Completed"),
        content: const Text("You have finished the vision test."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResultSummaryScreen(),
                ),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Vision Test'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '$_testProgress / $_totalTests',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Microphone permission banner
              if (!_speechAvailable)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.warningOrange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic_off, color: AppTheme.warningOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Microphone Access Required',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please allow microphone access in your browser to use voice recognition.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.help_outline,
                            color: AppTheme.warningOrange),
                        onPressed: _showPermissionDialog,
                      ),
                    ],
                  ),
                ),

              // Progress Indicator
              _buildProgressIndicator(),

              // Instructions
              _buildInstructions(),

              // Letter Display
              _buildLetterDisplay(),

              // Voice Status Bar
              _buildVoiceStatusBar(),

              // Control Buttons
              _buildControlButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: _testProgress / _totalTests,
          minHeight: 8,
          backgroundColor: AppTheme.secondaryLightBlue,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.peachColor),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.peachColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.peachColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Test Instructions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.peachColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
              Icons.straighten, 'Distance: ~40cm (roughly arm\'s length)'),
          const SizedBox(height: 8),
          _buildInstructionItem(Icons.remove_red_eye_outlined,
              'Cover one eye with a cupped palm (do not press on eyeball)'),
          const SizedBox(height: 8),
          _buildInstructionItem(Icons.mic, 'Read the letters aloud clearly'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.peachColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildLetterDisplay() {
    if (_showFullChart) {
      return _buildSnellenChart();
    }

    // Calculate calibrated letter size based on Snellen scale
    final letterHeightPixels =
        VisionData.getLetterSizePixels(_currentScale, _pixelsPerMm);

    return Container(
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimationController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseAnimationController.value * 0.05);
            return Transform.scale(
              scale: scale,
              child: Text(
                _currentLetter,
                style: TextStyle(
                  fontSize: letterHeightPixels.clamp(
                      80.0, 180.0), // Clamp for screen size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  letterSpacing: 8,
                  height: 1.0,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSnellenChart() {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_chartRows.length, (index) {
            final row = _chartRows[index];
            final bool isActive = index == _currentRowIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.peachColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(color: AppTheme.peachColor, width: 2)
                    : Border.all(color: Colors.transparent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: The Vision Score (e.g., 20/20)
                  SizedBox(
                    width: 50,
                    child: Text(
                      row['acuity'],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? AppTheme.peachColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Center: The Snellen Letters
                  Expanded(
                    child: Text(
                      row['letters'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: row['size'],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        color: _isListening
                            ? (isActive ? Colors.black : Colors.grey.shade300)
                            : Colors.black,
                      ),
                    ),
                  ),

                  // Right Side: Indicator Arrow
                  SizedBox(
                    width: 50,
                    child: isActive
                        ? Icon(Icons.arrow_back,
                            color: AppTheme.peachColor, size: 20)
                        : null,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildVoiceStatusBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice Status Indicator
          _isListening ? _buildWaveform() : _buildMicrophoneIcon(),
          const SizedBox(height: 12),

          // Status Text
          Text(
            _isListening
                ? (_lastRecognizedWords.isEmpty
                    ? 'Listening...'
                    : 'You said: $_lastRecognizedWords')
                : 'Tap "Start Test" to begin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.peachColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMicrophoneIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.pastelPeach.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mic_none,
        size: 40,
        color: AppTheme.peachColor,
      ),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _waveAnimationController,
            builder: (context, child) {
              final waveValue = sin(
                  (_waveAnimationController.value * 2 * pi) + (index * 0.5));
              final height = 20 +
                  (30 * waveValue.abs()); // Use abs() to ensure positive values
              return Container(
                width: 6,
                height: height.clamp(
                    10.0, 80.0), // Clamp between min and max values
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppTheme.peachColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Toggle between Single Letter and Full Chart
          if (!_isListening)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.pastelBlue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFullChart = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showFullChart
                              ? AppTheme.peachColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Single Letter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_showFullChart
                                ? Colors.white
                                : AppTheme.peachColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFullChart = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showFullChart
                              ? AppTheme.peachColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Full Chart',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _showFullChart
                                ? Colors.white
                                : AppTheme.peachColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Visual indicator when testing
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                _showFullChart
                    ? "Read the highlighted line..."
                    : "Auto-changing in 5 seconds...",
                style: TextStyle(
                  color: AppTheme.peachColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Start/Stop Speaking Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _isListening ? _stopAutoAdvanceMode : _startListening,
              icon: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 24,
              ),
              label: Text(
                _isListening
                    ? 'Stop Test'
                    : (_speechAvailable
                        ? 'Start Test'
                        : 'Enable Microphone & Start'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isListening ? Colors.red.shade400 : AppTheme.peachColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // Microphone permission hint
          if (!_isListening && !_speechAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '🎤 Browser will ask for microphone permission when you start',
                style: TextStyle(
                  color: AppTheme.peachColor,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),

          // Info Text
          if (_isListening)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.pastelBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppTheme.peachColor),
                  const SizedBox(width: 8),
                  Text(
                    _showFullChart
                        ? 'Rows change every $_autoAdvanceSeconds seconds'
                        : 'Letters change every $_autoAdvanceSeconds seconds',
                    style: TextStyle(
                      color: AppTheme.peachColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Skip Button
          if (!_isListening && !_showFullChart)
            TextButton(
              onPressed: () {
                setState(() {
                  _testProgress++;
                  if (_testProgress < _totalTests) {
                    _currentLetter = _testLetters[_testProgress];
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ResultSummaryScreen(),
                      ),
                    );
                  }
                });
              },
              child: Text(
                'Skip this letter',
                style: TextStyle(
                  color: AppTheme.peachColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
