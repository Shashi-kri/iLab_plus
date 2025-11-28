import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// API Service for communicating with the iLab+ backend
class ApiService {
  // Backend server configuration
  static const String baseUrl = 'http://localhost:5000';

  // Endpoints
  static const String healthEndpoint = '/health';
  static const String predictEndpoint = '/predict';
  static const String classesEndpoint = '/classes';

  /// Check if the backend server is healthy
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$healthEndpoint'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend server unreachable: $e');
    }
  }

  /// Get list of disease classes from backend
  static Future<List<String>> getClasses() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$classesEndpoint'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['classes']);
      } else {
        throw Exception('Failed to get classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch classes: $e');
    }
  }

  /// Predict eye disease from image file
  static Future<PredictionResult> predictDisease(File imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$predictEndpoint'),
      );

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Prediction failed');
      }
    } catch (e) {
      throw Exception('Failed to predict disease: $e');
    }
  }

  /// Predict eye disease from image bytes (for web platform)
  static Future<PredictionResult> predictDiseaseFromBytes(
      Uint8List imageBytes) async {
    try {
      // Convert bytes to base64
      String base64Image = base64Encode(imageBytes);
      return await predictDiseaseBase64(base64Image);
    } catch (e) {
      throw Exception('Failed to predict from bytes: $e');
    }
  }

  /// Predict eye disease from base64 encoded image
  static Future<PredictionResult> predictDiseaseBase64(
      String base64Image) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$predictEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'image_base64': base64Image}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Prediction failed');
      }
    } catch (e) {
      throw Exception('Failed to predict disease: $e');
    }
  }
}

/// Model for prediction results
class PredictionResult {
  final bool success;
  final String predictedClass;
  final double confidence;
  final Map<String, double> probabilities;
  final bool isDemoMode;
  final String? message;

  PredictionResult({
    required this.success,
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    this.isDemoMode = false,
    this.message,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    // Parse probabilities
    Map<String, double> probs = {};
    if (json['probabilities'] != null) {
      (json['probabilities'] as Map<String, dynamic>).forEach((key, value) {
        probs[key] = (value as num).toDouble();
      });
    }

    return PredictionResult(
      success: json['success'] ?? false,
      predictedClass: json['predicted_class'] ?? 'Unknown',
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: probs,
      isDemoMode: json['demo_mode'] ?? false,
      message: json['message'],
    );
  }

  /// Get top N predictions sorted by probability
  List<MapEntry<String, double>> getTopPredictions(int n) {
    var sorted = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Get confidence percentage as string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Get severity level based on predicted class
  String get severityLevel {
    if (predictedClass.toLowerCase() == 'normal eye') {
      return 'Normal';
    } else if (predictedClass.toLowerCase().contains('cataract') ||
        predictedClass.toLowerCase().contains('pterygium')) {
      return 'High';
    } else {
      return 'Medium';
    }
  }

  /// Get color based on severity
  String get severityColor {
    switch (severityLevel) {
      case 'Normal':
        return '#10B981'; // Green
      case 'Medium':
        return '#F59E0B'; // Orange
      case 'High':
        return '#EF4444'; // Red
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Get recommendation based on prediction
  String get recommendation {
    if (predictedClass.toLowerCase() == 'normal eye') {
      return 'Your eye appears healthy. Continue regular checkups.';
    } else if (severityLevel == 'High') {
      return 'Please consult an ophthalmologist as soon as possible.';
    } else {
      return 'Consider scheduling an eye examination with a specialist.';
    }
  }
}
