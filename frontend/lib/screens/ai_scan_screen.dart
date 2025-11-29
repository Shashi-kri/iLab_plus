import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AIScanScreen extends StatefulWidget {
  const AIScanScreen({super.key});

  @override
  State<AIScanScreen> createState() => _AIScanScreenState();
}

class _AIScanScreenState extends State<AIScanScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImage; // For web platform image bytes
  bool _isLoading = false;
  bool _isCapturing = false;
  PredictionResult? _result;
  String? _error;
  String _statusMessage = '';

  // Selected disease tab
  String _selectedDisease = 'Cataract';
  final List<String> _diseases = [
    'Cataract',
    'Pterygium',
    'Eyelid',
    'Conjunctivitis'
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  /// Check and request camera permissions
  Future<void> _checkPermissions() async {
    // Skip permission check on web
    if (kIsWeb) {
      setState(() {
        _statusMessage = 'Ready to capture or upload images';
      });
      return;
    }

    // For mobile/desktop - permissions would be handled by image_picker
    setState(() {
      _statusMessage = 'Camera ready. Tap to capture.';
    });
  }

  /// Request camera permission and open camera
  Future<void> _openCamera() async {
    setState(() {
      _isCapturing = true;
      _error = null;
      _statusMessage = 'Opening camera...';
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _statusMessage = 'Image captured, preparing...';
        });

        // Handle web vs mobile differently
        if (kIsWeb) {
          // For web, read the bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null; // Clear file reference
            _result = null;
            _error = null;
            _statusMessage = 'Image ready. Ready to analyze.';
            _isCapturing = false;
          });
        } else {
          // For mobile, use File
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null; // Clear web bytes
            _result = null;
            _error = null;
            _statusMessage = 'Image ready. Ready to analyze.';
            _isCapturing = false;
          });
        }

        // Auto-analyze after capture
        await Future.delayed(const Duration(milliseconds: 500));
        _analyzeImage();
      } else {
        setState(() {
          _statusMessage = '';
          _isCapturing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to capture image: $e';
        _statusMessage = '';
        _isCapturing = false;
      });
    }
  }

  /// Pick image from gallery
  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _statusMessage = 'Opening gallery...';
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _statusMessage = 'Image selected, preparing...';
        });

        // Handle web vs mobile differently
        if (kIsWeb) {
          // For web, read the bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
            _result = null;
            _error = null;
            _statusMessage = 'Image ready. Ready to analyze.';
          });
        } else {
          // For mobile, use File
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
            _result = null;
            _error = null;
            _statusMessage = 'Image ready. Ready to analyze.';
          });
        }
      } else {
        setState(() {
          _statusMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
        _statusMessage = '';
      });
    }
  }

  /// Analyze image through backend API
  Future<void> _analyzeImage() async {
    // Check if we have an image
    if (_selectedImage == null && _webImage == null) {
      setState(() {
        _error = 'Please capture or select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _statusMessage = 'Checking backend connection...';
    });

    try {
      // Step 1: Check backend health
      await ApiService.checkHealth();

      setState(() {
        _statusMessage = 'Backend connected. Uploading image...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Upload image and get prediction
      setState(() {
        _statusMessage = 'Image uploaded. AI model analyzing...';
      });

      // Use appropriate method based on platform
      PredictionResult result;
      if (kIsWeb && _webImage != null) {
        result = await ApiService.predictDiseaseFromBytes(_webImage!);
      } else if (_selectedImage != null) {
        result = await ApiService.predictDisease(_selectedImage!);
      } else {
        throw Exception('No image available');
      }

      setState(() {
        _statusMessage = 'Analysis complete!';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _result = result;
        _isLoading = false;
        _statusMessage = '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _statusMessage = '';
      });
    }
  }

  @override
  void dispose() {
    // Clean up cached images when leaving screen
    _selectedImage?.delete().catchError((_) => _selectedImage!);
    super.dispose();
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Select Disease & Capture',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a disease type and capture or upload an eye image',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Disease Tabs
            _buildDiseaseTabs(),

            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style:
                            TextStyle(color: AppTheme.accentBlue, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Image Selection Buttons
            if (_selectedImage == null && _webImage == null)
              _buildImageSourceButtons(),

            // Selected Image Preview
            if (_selectedImage != null || _webImage != null)
              _buildImagePreview(),

            const SizedBox(height: 24),

            // Analyze Button
            if ((_selectedImage != null || _webImage != null) &&
                _result == null &&
                !_isLoading)
              ElevatedButton(
                onPressed: _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Analyze for $_selectedDisease',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            // Loading Indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accentBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Error Display
            if (_error != null) _buildError(),

            // Results Display
            if (_result != null) _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: _diseases.map((disease) {
          final isSelected = disease == _selectedDisease;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDisease = disease;
                  _selectedImage = null;
                  _webImage = null;
                  _result = null;
                  _error = null;
                  _statusMessage = '';
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  disease,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageSourceButtons() {
    return Column(
      children: [
        // Disease-specific info card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getDiseaseInfo(_selectedDisease),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Live Capture Button
        InkWell(
          onTap: _isCapturing ? null : _openCamera,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentBlue.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppTheme.accentBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Capture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Use camera to capture eye image',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Upload Image Button
        InkWell(
          onTap: _isCapturing ? null : _pickFromGallery,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppTheme.accentGreen,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose from gallery or files',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDiseaseInfo(String disease) {
    switch (disease) {
      case 'Cataract':
        return 'Capture clear images of the eye lens showing cloudiness or opacity';
      case 'Pterygium':
        return 'Focus on the pinkish growth on the white part of the eye';
      case 'Eyelid':
        return 'Capture images showing eyelid abnormalities or conditions';
      case 'Conjunctivitis':
        return 'Show redness, swelling, or discharge in the eye';
      default:
        return 'Capture a clear, well-lit image of the affected eye';
    }
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb && _webImage != null
                ? Image.memory(
                    _webImage!,
                    fit: BoxFit.cover,
                  )
                : _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _webImage = null;
              _result = null;
              _error = null;
            });
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Choose Different Image'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentBlue,
            side: BorderSide(color: AppTheme.accentBlue),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorRed),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Demo Mode Warning
        if (_result!.isDemoMode)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Mode: ${_result!.message}',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

        // Main Result Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Predicted Class
              Text(
                'Diagnosis',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!.predictedClass,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Confidence
              Text(
                'Confidence',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!.confidencePercent,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(height: 24),

              // Severity Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getSeverityColor(_result!.severityLevel)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getSeverityColor(_result!.severityLevel)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${_result!.severityLevel} Risk',
                  style: TextStyle(
                    color: _getSeverityColor(_result!.severityLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recommendation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: AppTheme.accentBlue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _result!.recommendation,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scan Another Image Button
        OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _result = null;
              _error = null;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.accentBlue,
            side: BorderSide(color: AppTheme.accentBlue),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Scan Another Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Normal':
        return AppTheme.accentGreen;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}
