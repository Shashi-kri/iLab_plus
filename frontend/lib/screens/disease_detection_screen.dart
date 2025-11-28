import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import 'result_summary_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });
    _scanAnimationController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _scanAnimationController.stop();
        setState(() {
          _isScanning = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultSummaryScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('AI Disease Detection'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera View Area
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF2D2D2D),
            child: Stack(
              children: [
                // Eye Icon in Center
                Center(
                  child: Icon(
                    Icons.remove_red_eye,
                    size: 120,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),

                // Scanning Frame with Blue Brackets
                Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    child: Stack(
                      children: [
                        // Top Left Bracket
                        Positioned(
                          top: 0,
                          left: 0,
                          child: _buildBracket(topLeft: true),
                        ),
                        // Top Right Bracket
                        Positioned(
                          top: 0,
                          right: 0,
                          child: _buildBracket(topRight: true),
                        ),
                        // Bottom Left Bracket
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: _buildBracket(bottomLeft: true),
                        ),
                        // Bottom Right Bracket
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _buildBracket(bottomRight: true),
                        ),
                      ],
                    ),
                  ),
                ),

                // Info Banner at Top
                if (!_isScanning)
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Position your eye within the frame',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Scanning Status
                if (_isScanning)
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.peachColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom White Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        _isScanning
                            ? 'Please hold still...'
                            : 'Align your eye within the frame',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        _isScanning
                            ? 'AI is analyzing your eye health'
                            : 'Ensure good lighting for accurate results',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Start Scan Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isScanning ? null : _startScan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.peachColor,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isScanning ? Icons.hourglass_empty : Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _isScanning ? 'Scanning...' : 'Start Scan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? BorderSide(color: AppTheme.peachColor, width: 3)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? BorderSide(color: AppTheme.peachColor, width: 3)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? BorderSide(color: AppTheme.peachColor, width: 3)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? BorderSide(color: AppTheme.peachColor, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
