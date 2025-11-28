class VisionData {
  // --- SNELLEN DATA ---
  // Standard height of a 20/20 letter at 20ft (6m) is approx 8.87mm
  static const double base2020HeightMm = 8.87;
  static const double creditCardWidthMm = 85.6;

  static const List<String> optotypes = ["C", "D", "E", "F", "L", "O", "P", "T", "Z"];

  static const List<Map<String, dynamic>> snellenLines = [
    {"text": "20/200", "scale": 10.0, "mm": 88.7},
    {"text": "20/100", "scale": 5.0, "mm": 44.3},
    {"text": "20/70", "scale": 3.5, "mm": 31.0},
    {"text": "20/50", "scale": 2.5, "mm": 22.1},
    {"text": "20/40", "scale": 2.0, "mm": 17.7},
    {"text": "20/30", "scale": 1.5, "mm": 13.3},
    {"text": "20/20", "scale": 1.0, "mm": 8.87},
  ];

  // --- ISHIHARA COLORS ---
  // Confusion Lines for Protan/Deutan (Red-Green Blindness)

  // Colors for the Number/Shape (Red/Orange hues)
  static const List<int> patternColors = [
    0xFFE86A17,
    0xFFD95B43,
    0xFFC02942,
    0xFFB94A3E,
    0xFFA33B2E
  ];

  // Colors for the Background (Green/Teal hues)
  static const List<int> backgroundColors = [
    0xFF8BB174,
    0xFF53777A,
    0xFF456F74,
    0xFF6C8C74,
    0xFF5A7D7C
  ];

  // Additional test data
  static String generateRandomLine(int count) {
    final random = DateTime.now().millisecondsSinceEpoch;
    String res = "";
    for (int i = 0; i < count; i++) {
      final index = (random + i) % optotypes.length;
      res += optotypes[index];
      if (i < count - 1) res += " ";
    }
    return res;
  }

  // Get letter size in pixels based on calibration
  static double getLetterSizePixels(double scale, double pixelsPerMm) {
    return base2020HeightMm * scale * pixelsPerMm;
  }
}
